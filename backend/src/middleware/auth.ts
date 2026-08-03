import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { config } from '../config';
import { query } from '../db';

export interface AuthRequest extends Request {
  user?: {
    id: string;
    email: string;
    roles: string[];
    permissions: Record<string, boolean>;
    activeRole?: string;
    regionId?: string;
  };
}

export const authenticate = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const token = req.headers.authorization?.replace('Bearer ', '');
    if (!token) return res.status(401).json({ error: 'Access token required' });

    const decoded = jwt.verify(token, config.jwtSecret) as any;
    const userResult = await query(
      'SELECT id, email, region_id FROM users WHERE id = $1 AND is_active = true',
      [decoded.userId]
    );
    if (userResult.rows.length === 0) {
      console.error('[Auth Error] User not found or inactive:', decoded.userId);
      return res.status(401).json({ error: 'User not found' });
    }

    const user = userResult.rows[0];
    const rolesResult = await query('SELECT role, permissions FROM user_roles WHERE user_id = $1', [user.id]);

    // Merge all permission objects across roles into a single flat map
    const mergedPermissions: Record<string, boolean> = {};
    for (const row of rolesResult.rows) {
      if (row.permissions && typeof row.permissions === 'object') {
        Object.assign(mergedPermissions, row.permissions);
      }
    }

    req.user = {
      id: user.id,
      email: user.email,
      roles: rolesResult.rows.map((r: any) => r.role),
      permissions: mergedPermissions,
      activeRole: req.headers['x-active-role'] as string || rolesResult.rows[0]?.role,
      regionId: user.region_id,
    };
    next();
  } catch (err: any) {
    console.error('[Auth Error] Token validation failed:', err.message, err.stack);
    return res.status(401).json({ error: 'Invalid or expired token' });
  }
};

export const requireRole = (...allowedRoles: string[]) => {
  return (req: AuthRequest, res: Response, next: NextFunction) => {
    if (!req.user) return res.status(401).json({ error: 'Unauthorized' });
    const hasRole = req.user.roles.some((r) => allowedRoles.includes(r));
    if (!hasRole) return res.status(403).json({ error: 'Insufficient permissions' });
    next();
  };
};

export const requireOwnership = (resourceTable: string, resourceIdParam: string = 'id') => {
  return async (req: AuthRequest, res: Response, next: NextFunction) => {
    if (!req.user) return res.status(401).json({ error: 'Unauthorized' });
    const resourceId = req.params[resourceIdParam];
    const result = await query(
      `SELECT landlord_id, tenant_id, manager_id, vendor_id FROM ${resourceTable} WHERE id = $1`,
      [resourceId]
    );
    if (result.rows.length === 0) return res.status(404).json({ error: 'Resource not found' });

    const resource = result.rows[0];
    const isOwner = resource.landlord_id === req.user.id || 
                    resource.tenant_id === req.user.id || 
                    resource.manager_id === req.user.id ||
                    resource.vendor_id === req.user.id;

    if (!isOwner && !req.user.roles.includes('admin') && !req.user.roles.includes('super_admin')) {
      return res.status(403).json({ error: 'Not resource owner' });
    }
    next();
  };
};
