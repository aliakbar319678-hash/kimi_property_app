import { Response, NextFunction } from 'express';
import { AuthRequest } from './auth';

/**
 * Permission-based RBAC middleware factory.
 *
 * Usage:
 *   router.post('/staff', authenticate, requirePermission('can_manage_staff'), handler)
 *
 * Super-admins and admins bypass all permission checks (they have full access).
 * All other roles must have the specific flag set to `true` in their permissions JSONB.
 */
export const requirePermission = (...requiredPermissions: string[]) => {
  return (req: AuthRequest, res: Response, next: NextFunction) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Unauthorized' });
    }

    // Super-admins and admins bypass all granular checks
    if (
      req.user.roles.includes('super_admin') ||
      req.user.roles.includes('admin')
    ) {
      return next();
    }

    // Check each required permission
    const missing = requiredPermissions.filter(
      (p) => !req.user!.permissions[p]
    );

    if (missing.length > 0) {
      return res.status(403).json({
        error: 'Insufficient permissions',
        missing,
      });
    }

    next();
  };
};

/**
 * Convenience: require the user to be staff (any staff role or admin).
 */
export const requireStaffOrAdmin = (
  req: AuthRequest,
  res: Response,
  next: NextFunction
) => {
  if (!req.user) return res.status(401).json({ error: 'Unauthorized' });
  const allowed = ['super_admin', 'admin', 'staff'];
  if (!req.user.roles.some((r) => allowed.includes(r))) {
    return res.status(403).json({ error: 'Staff or Admin access required' });
  }
  next();
};
