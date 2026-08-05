import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { v4 as uuidv4 } from 'uuid';
import { query, withTransaction } from '../db';
import { config } from '../config';
import { AppError } from '../middleware/errorHandler';

export class AuthService {
  static async register(data: { email: string; password: string; phone?: string; role: string; regionCode?: string; display_name?: string; first_name?: string; last_name?: string; avatar_url?: string; username?: string }) {
    return withTransaction(async (client) => {
      const existing = await client.query('SELECT id FROM users WHERE email = $1', [data.email]);
      if (existing.rows.length > 0) throw new AppError('Email already registered', 409);

      if (data.username) {
        if (data.role !== 'tenant') throw new AppError('Only tenants can have a username', 400);
        const existingUsername = await client.query('SELECT id FROM users WHERE username = $1', [data.username]);
        if (existingUsername.rows.length > 0) throw new AppError('Username already taken', 409);
      }

      const regionRes = await client.query('SELECT id FROM regions WHERE code = $1', [data.regionCode || 'US-NYC']);
      const regionId = regionRes.rows[0]?.id;

      const hash = await bcrypt.hash(data.password, config.bcryptRounds);
      const userId = uuidv4();
      const displayName = data.display_name || data.email.split('@')[0];

      const userRes = await client.query(
        `INSERT INTO users (id, email, phone, password_hash, region_id, display_name, username)
         VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING id, email, kyc_status`,
        [userId, data.email, data.phone || null, hash, regionId, displayName, data.username || null]
      );

      await client.query(
        'INSERT INTO user_roles (user_id, role, is_primary) VALUES ($1, $2, true)',
        [userId, data.role]
      );

      await client.query(
        'INSERT INTO user_profiles (user_id, legal_first_name, legal_last_name, avatar_url) VALUES ($1, $2, $3, $4)',
        [userId, data.first_name || null, data.last_name || null, data.avatar_url || null]
      );

      return userRes.rows[0];
    });
  }

  static async login(identifier: string, password: string, username?: string, full_name?: string, phone?: string) {
    const userRes = await query(
      `SELECT u.id, u.email, u.password_hash, u.kyc_status, up.onboarding_step, u.is_active, u.username, u.display_name, u.phone, up.legal_first_name, up.legal_last_name 
       FROM users u 
       LEFT JOIN user_profiles up ON u.id = up.user_id 
       WHERE u.email = $1 OR u.username = $1`,
      [identifier]
    );
    if (userRes.rows.length === 0) throw new AppError('Invalid credentials', 401);
    const user = userRes.rows[0];
    if (!user.is_active) throw new AppError('Account suspended', 403);

    const valid = await bcrypt.compare(password, user.password_hash);
    if (!valid) throw new AppError('Invalid credentials', 401);

    const rolesRes = await query('SELECT role FROM user_roles WHERE user_id = $1', [user.id]);
    const roles = rolesRes.rows.map((r: any) => r.role);

    // Standard validation (password and identifier are already validated above)

    const accessToken = jwt.sign({ userId: user.id, roles }, config.jwtSecret, { expiresIn: config.jwtExpiresIn });
    const refreshToken = jwt.sign({ userId: user.id, type: 'refresh' }, config.jwtSecret, { expiresIn: config.refreshTokenExpiresIn });

    return {
      token: accessToken,
      refreshToken,
      expiresIn: config.jwtExpiresIn,
      user: {
        id: user.id,
        email: user.email,
        username: user.username,
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
    const userRes = await query('SELECT id, email, phone, display_name, username, kyc_status, region_id FROM users WHERE id = $1', [userId]);
    if (userRes.rows.length === 0) throw new AppError('User not found', 404);
    const rolesRes = await query('SELECT role, entity_id, is_primary FROM user_roles WHERE user_id = $1', [userId]);
    const profileRes = await query('SELECT * FROM user_profiles WHERE user_id = $1', [userId]);
    const user = userRes.rows[0];
    const prof = profileRes.rows[0] || {};
    return {
      ...user,
      first_name: prof.legal_first_name || '',
      last_name: prof.legal_last_name || '',
      avatar_url: prof.avatar_url || null,
      phone: user.phone || prof.phone || '',
      roles: rolesRes.rows,
      profile: prof,
    };
  }
  static async forgotPassword(email: string) {
    const userRes = await query('SELECT id FROM users WHERE email = $1', [email]);
    if (userRes.rows.length === 0) throw new AppError('User not found', 404);

    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = new Date(Date.now() + 10 * 60000); // 10 minutes from now

    // We can assume the migration has run, but to be safe we can use a query that ignores error if column is missing, or just rely on it.
    await query(
      'UPDATE users SET reset_otp = $1, reset_otp_expires_at = $2 WHERE email = $3',
      [otp, expiresAt.toISOString(), email]
    );

    // Mock sending email
    console.log(`[MOCK EMAIL] Password reset OTP for ${email} is: ${otp}`);
    return { message: 'OTP sent successfully (check console)' };
  }

  static async verifyOtp(email: string, otp: string) {
    const userRes = await query(
      'SELECT id, reset_otp_expires_at FROM users WHERE email = $1 AND reset_otp = $2',
      [email, otp]
    );
    if (userRes.rows.length === 0) throw new AppError('Invalid OTP', 400);
    
    const user = userRes.rows[0];
    if (new Date(user.reset_otp_expires_at) < new Date()) {
      throw new AppError('OTP has expired', 400);
    }

    const resetToken = jwt.sign({ email: email, purpose: 'password_reset' }, config.jwtSecret, { expiresIn: '15m' });
    
    return { resetToken };
  }

  static async resetPassword(resetToken: string, newPassword: string) {
    let decoded: any;
    try {
      decoded = jwt.verify(resetToken, config.jwtSecret);
      if (decoded.purpose !== 'password_reset') throw new Error();
    } catch (e) {
      throw new AppError('Invalid or expired reset token', 400);
    }

    const hash = await bcrypt.hash(newPassword, config.bcryptRounds);
    
    await query(
      'UPDATE users SET password_hash = $1, reset_otp = NULL, reset_otp_expires_at = NULL WHERE email = $2',
      [hash, decoded.email]
    );

    return { message: 'Password updated successfully' };
  }
}
