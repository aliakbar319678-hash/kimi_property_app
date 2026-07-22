import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { v4 as uuidv4 } from 'uuid';
import { query, withTransaction } from '../db';
import { config } from '../config';
import { AppError } from '../middleware/errorHandler';

export class AuthService {
  static generateOtpCode(): string {
    return Math.floor(1000 + Math.random() * 9000).toString();
  }

  static async register(data: { email: string; password: string; phone?: string; role: string; regionCode?: string }) {
    return withTransaction(async (client) => {
      const existing = await client.query('SELECT id FROM users WHERE email = $1', [data.email]);
      if (existing.rows.length > 0) throw new AppError('Email already registered', 409);

      const regionRes = await client.query('SELECT id FROM regions WHERE code = $1', [data.regionCode || 'US-NYC']);
      const regionId = regionRes.rows[0]?.id;

      const hash = await bcrypt.hash(data.password, config.bcryptRounds);
      const userId = uuidv4();
      const otpCode = this.generateOtpCode();

      const displayName = (data as any).display_name || data.email.split('@')[0];
      let firstName = '';
      let lastName = '';
      if ((data as any).display_name) {
        const parts = (data as any).display_name.trim().split(' ');
        firstName = parts[0];
        lastName = parts.slice(1).join(' ');
      }

      const userRes = await client.query(
        `INSERT INTO users (id, email, phone, password_hash, region_id, display_name, legal_first_name, legal_last_name, kyc_status, otp_code, otp_expires_at)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, 'approved', $9, NOW() + INTERVAL '10 minutes') RETURNING id, email, kyc_status`,
        [userId, data.email, data.phone || null, hash, regionId, displayName, firstName || null, lastName || null, otpCode]
      );

      console.log(`\n[OTP] Generated verification code for ${data.email}: ${otpCode}\n`);

      await client.query(
        'INSERT INTO user_roles (user_id, role, is_primary) VALUES ($1, $2, true)',
        [userId, data.role]
      );

      await client.query(
        'INSERT INTO user_profiles (user_id, onboarding_step) VALUES ($1, 1)',
        [userId]
      );

      return userRes.rows[0];
    });
  }

  static async verifyOtp(userId: string, code: string) {
    const res = await query('SELECT otp_code, otp_expires_at FROM users WHERE id = $1', [userId]);
    if (res.rows.length === 0) throw new AppError('User not found', 404);
    
    const { otp_code, otp_expires_at } = res.rows[0];
    if (!otp_code) throw new AppError('No verification code requested', 400);
    if (new Date() > new Date(otp_expires_at)) throw new AppError('Verification code expired', 400);
    if (otp_code !== code) throw new AppError('Invalid verification code', 400);

    await query(`UPDATE users SET otp_code = NULL, otp_expires_at = NULL, email_verified = true WHERE id = $1`, [userId]);
    return { verified: true };
  }

  static async resendOtp(userId: string) {
    const otpCode = this.generateOtpCode();
    const res = await query(
      `UPDATE users SET otp_code = $1, otp_expires_at = NOW() + INTERVAL '10 minutes' WHERE id = $2 RETURNING email`,
      [otpCode, userId]
    );
    if (res.rows.length > 0) {
      console.log(`\n[OTP] Resent verification code for ${res.rows[0].email}: ${otpCode}\n`);
    }
    return { sent: true };
  }

  static async login(email: string, password: string) {
    const userRes = await query(
      `SELECT u.id, u.email, u.password_hash, u.kyc_status, u.is_active,
              COALESCE(up.onboarding_step, 1) as onboarding_step
       FROM users u
       LEFT JOIN user_profiles up ON up.user_id = u.id
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
      accessToken,
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
      return { accessToken, expiresIn: config.jwtExpiresIn };
    } catch (e) {
      throw new AppError('Invalid refresh token', 401);
    }
  }

  static async switchRole(userId: string, newRole: string) {
    const rolesRes = await query('SELECT role FROM user_roles WHERE user_id = $1', [userId]);
    const roles = rolesRes.rows.map((r: any) => r.role);
    if (!roles.includes(newRole)) {
      throw new AppError('User does not have the requested role', 403);
    }
    
    const accessToken = jwt.sign({ userId, roles, activeRole: newRole }, config.jwtSecret, { expiresIn: config.jwtExpiresIn });
    return { accessToken, activeRole: newRole, roles };
  }

  static async me(userId: string) {
    const userRes = await query('SELECT id, email, display_name, kyc_status, region_id FROM users WHERE id = $1', [userId]);
    if (userRes.rows.length === 0) throw new AppError('User not found', 404);
    const rolesRes = await query('SELECT role, entity_id, is_primary FROM user_roles WHERE user_id = $1', [userId]);
    const profileRes = await query('SELECT * FROM user_profiles WHERE user_id = $1', [userId]);
    return {
      ...userRes.rows[0],
      roles: rolesRes.rows,
      profile: profileRes.rows[0] || null,
      onboarding_step: profileRes.rows[0]?.onboarding_step || 1
    };
  }

}
