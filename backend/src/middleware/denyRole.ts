import { Request, Response, NextFunction } from 'express';
import { AuthRequest } from './auth';

/**
 * denyRole middleware
 * Blocks access for specified roles and returns 403 Forbidden.
 * Use AFTER `authenticate` or `adminOrJwtAuth` middleware.
 *
 * Example:
 *   router.get('/courses', authenticate, denyRole('vendor'), handler)
 */
export const denyRole = (...blockedRoles: string[]) => {
  return (req: AuthRequest, res: Response, next: NextFunction): void => {
    // If not authenticated, skip — let the auth middleware handle it
    if (!req.user) {
      next();
      return;
    }
    const isBlocked = req.user.roles.some((r) => blockedRoles.includes(r));
    if (isBlocked) {
      res.status(403).json({
        success: false,
        error: 'Forbidden',
        message: `Role '${req.user.roles.join(', ')}' does not have access to this resource.`,
      });
      return;
    }
    next();
  };
};
