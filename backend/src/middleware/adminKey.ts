import { Request, Response, NextFunction } from 'express';
import { query } from '../db';

// Cache the real admin user UUID so we don't hit DB on every request
let cachedAdminId: string | null = null;

async function getRealAdminId(): Promise<string | null> {
  if (cachedAdminId) return cachedAdminId;
  try {
    // Find the first super_admin or admin user in the database
    const res = await query(
      `SELECT u.id FROM users u
       JOIN user_roles r ON r.user_id = u.id
       WHERE r.role IN ('super_admin', 'admin') AND u.is_active = true
       ORDER BY u.created_at ASC
       LIMIT 1`,
      []
    );
    if (res.rows.length > 0) {
      cachedAdminId = res.rows[0].id;
      return cachedAdminId;
    }
  } catch (e) {
    // If lookup fails, return null — callers must handle gracefully
  }
  return null;
}

/**
 * Middleware that allows requests from the Laravel admin panel
 * using a shared API key (X-Admin-Key header).
 * Falls through to normal JWT auth if key is not present.
 */
export const adminKeyAuth = async (req: Request & { user?: any }, res: Response, next: NextFunction) => {
  const adminKey = req.headers['x-admin-key'] as string;
  
  // If admin key matches, set a synthetic admin user and skip JWT auth
  const expectedKey = process.env.ADMIN_API_KEY || 'propadmin-internal-key-2024';
  
  if (adminKey && adminKey === expectedKey) {
    const realId = await getRealAdminId();
    req.user = {
      id: realId || 'admin-system',
      email: 'admin@propadmin.io',
      roles: ['admin', 'super_admin'],
      activeRole: 'super_admin',
      regionId: null,
    };
    return next();
  }
  
  // No admin key — fall through (let next middleware handle auth)
  next();
};

/**
 * Combined auth: accepts either X-Admin-Key OR JWT Bearer token.
 * Use this instead of `authenticate` on admin-facing routes.
 */
export const adminOrJwtAuth = async (req: Request & { user?: any }, res: Response, next: NextFunction) => {
  const token = req.headers.authorization?.replace('Bearer ', '');

  if (token && token.trim() !== '') {
    try {
      const jwt = require('jsonwebtoken');
      const { config } = require('../config');
      const decoded = jwt.verify(token, config.jwtSecret) as any;
      const userResult = await query(
        'SELECT id, email, region_id FROM users WHERE id = $1 AND is_active = true',
        [decoded.userId]
      );
      if (userResult.rows.length === 0) return res.status(401).json({ error: 'User not found' });

      const user = userResult.rows[0];
      const rolesResult = await query('SELECT role FROM user_roles WHERE user_id = $1', [user.id]);

      req.user = {
        id: user.id,
        email: user.email,
        roles: rolesResult.rows.map((r: any) => r.role),
        activeRole: req.headers['x-active-role'] as string || rolesResult.rows[0]?.role,
        regionId: user.region_id,
      };
      return next();
    } catch (err) {
      return res.status(401).json({ error: 'Invalid or expired token' });
    }
  }

  // Fallback to X-Admin-Key if NO Authorization header is provided
  const adminKey = req.headers['x-admin-key'] as string;
  const expectedKey = process.env.ADMIN_API_KEY || 'propadmin-internal-key-2024';

  if (adminKey && adminKey === expectedKey) {
    const realId = await getRealAdminId();
    req.user = {
      id: realId || 'admin-system',
      email: 'admin@propadmin.io',
      roles: ['admin', 'super_admin'],
      activeRole: 'super_admin',
      regionId: null,
    };
    return next();
  }

  return res.status(401).json({ error: 'Access token or admin key required' });
};
