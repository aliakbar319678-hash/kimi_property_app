import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { v4 as uuidv4 } from 'uuid';
import { query, withTransaction } from '../db';
import { config } from '../config';
import { AppError } from '../middleware/errorHandler';

export class AuthService {
  static async register(data: { email: string; password: string; phone?: string; role: string; regionCode?: string; display_name?: string; first_name?: string; last_name?: string; avatar_url?: string }) {
    return withTransaction(async (client) => {
      const existing = await client.query('SELECT id FROM users WHERE email = $1', [data.email]);
      if (existing.rows.length > 0) throw new AppError('Email already registered', 409);

      if (data.phone) {
        const existingPhone = await client.query('SELECT id FROM users WHERE phone = $1', [data.phone]);
        if (existingPhone.rows.length > 0) throw new AppError('Phone number already registered', 409);
      }

      const regionRes = await client.query('SELECT id FROM regions WHERE code = $1', [data.regionCode || 'US-NYC']);
      const regionId = regionRes.rows[0]?.id;

      const hash = await bcrypt.hash(data.password, config.bcryptRounds);
      const userId = uuidv4();
      const displayName = data.display_name || data.email.split('@')[0];

      const userRes = await client.query(
        `INSERT INTO users (id, email, phone, password_hash, region_id, display_name, legal_first_name, legal_last_name, avatar_url)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING id, email, kyc_status`,
        [userId, data.email, data.phone || null, hash, regionId, displayName, data.first_name || null, data.last_name || null, data.avatar_url || null]
      );

      await client.query(
        'INSERT INTO user_roles (user_id, role, is_primary) VALUES ($1, $2, true)',
        [userId, data.role]
      );

      await client.query(
        'INSERT INTO user_profiles (user_id) VALUES ($1)',
        [userId]
      );

      // Generate initial verification code
      const code = Math.floor(1000 + Math.random() * 9000).toString();
      await client.query(
        `INSERT INTO verification_codes (user_id, code, expires_at) 
         VALUES ($1, $2, NOW() + INTERVAL '10 minutes')`,
        [userId, code]
      );
      console.log(`[OTP] Generated verification code for user ${data.email} (${userId}): ${code}`);

      return userRes.rows[0];
    });
  }

  static async login(email: string, password: string) {
    const userRes = await query(
      `SELECT u.id, u.email, u.password_hash, u.kyc_status, u.is_active, p.onboarding_step 
       FROM users u
       LEFT JOIN user_profiles p ON p.user_id = u.id 
       WHERE u.email = $1`,
      [email]
    );
    if (userRes.rows.length === 0) throw new AppError('Invalid credentials', 401);
    const user = userRes.rows[0];
    if (!user.is_active) throw new AppError('Account suspended', 403);

    const valid = await bcrypt.compare(password, user.password_hash);
    if (!valid) throw new AppError('Invalid credentials', 401);

    const rolesRes = await query('SELECT role FROM user_roles WHERE user_id = $1', [user.id]);
    const roles = rolesRes.rows.map((r: any) => r.role);

    const accessToken = jwt.sign({ userId: user.id, roles }, config.jwtSecret, { expiresIn: config.jwtExpiresIn });
    const refreshToken = jwt.sign({ userId: user.id, type: 'refresh' }, config.jwtSecret, { expiresIn: config.refreshTokenExpiresIn });

    return {
      token: accessToken,
      refreshToken,
      expiresIn: config.jwtExpiresIn,
      user: {
        id: user.id,
        email: user.email,
        roles,
        kycStatus: user.kyc_status,
        onboardingStep: user.onboarding_step,
      },
      requiresOnboarding: user.onboarding_step < 5,
    };
  }

  static async refresh(token: string) {
    try {
      const decoded: any = jwt.verify(token, config.jwtSecret);
      if (decoded.type !== 'refresh') throw new Error('Invalid token type');
      const userRes = await query('SELECT id, email FROM users WHERE id = $1 AND is_active = true', [decoded.userId]);
      if (userRes.rows.length === 0) throw new AppError('User not found', 401);
      const rolesRes = await query('SELECT role FROM user_roles WHERE user_id = $1', [decoded.userId]);
      const accessToken = jwt.sign({ userId: decoded.userId, roles: rolesRes.rows.map((r: any) => r.role) }, config.jwtSecret, { expiresIn: config.jwtExpiresIn });
      return { token: accessToken, expiresIn: config.jwtExpiresIn };
    } catch (e) {
      throw new AppError('Invalid refresh token', 401);
    }
  }

  static async me(userId: string) {
    const userRes = await query(
      `SELECT u.id, u.email, u.display_name, u.kyc_status, u.region_id, p.onboarding_step 
       FROM users u
       LEFT JOIN user_profiles p ON p.user_id = u.id 
       WHERE u.id = $1`,
      [userId]
    );
    if (userRes.rows.length === 0) throw new AppError('User not found', 404);
    const rolesRes = await query('SELECT role, entity_id, is_primary FROM user_roles WHERE user_id = $1', [userId]);
    const profileRes = await query('SELECT * FROM user_profiles WHERE user_id = $1', [userId]);
    return {
      ...userRes.rows[0],
      roles: rolesRes.rows,
      profile: profileRes.rows[0] || null,
    };
  }

  static async verifyOtp(userId: string, code: string) {
    const res = await query(
      `SELECT * FROM verification_codes 
       WHERE user_id = $1 AND code = $2 AND expires_at > NOW()`,
      [userId, code]
    );
    if (res.rows.length === 0) {
      throw new AppError('Invalid or expired verification code', 400);
    }
    
    // Valid code! Mark user as email_verified
    await query('UPDATE users SET email_verified = true WHERE id = $1', [userId]);
    // Delete the code so it cannot be reused
    await query('DELETE FROM verification_codes WHERE user_id = $1', [userId]);
    
    return { success: true };
  }

  static async resendOtp(userId: string) {
    // Delete any old codes
    await query('DELETE FROM verification_codes WHERE user_id = $1', [userId]);
    
    // Generate new code
    const code = Math.floor(1000 + Math.random() * 9000).toString();
    await query(
      `INSERT INTO verification_codes (user_id, code, expires_at) 
       VALUES ($1, $2, NOW() + INTERVAL '10 minutes')`,
      [userId, code]
    );
    
    // Retrieve email to log it nicely
    const userRes = await query('SELECT email FROM users WHERE id = $1', [userId]);
    const email = userRes.rows[0]?.email || userId;
    console.log(`[OTP] Generated NEW verification code for user ${email} (${userId}): ${code}`);
    
    return { success: true };
  }
}
