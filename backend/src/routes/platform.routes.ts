import { Router } from 'express';
import { PlatformService } from '../services/platform.service';
import { authenticate, AuthRequest, requireRole } from '../middleware/auth';

const router = Router();

/**
 * GET /api/v1/settings/platform-fee
 * Returns current platform fee % and hold period days.
 * Admin/super_admin only.
 */
router.get(
  '/platform-fee',
  authenticate,
  requireRole('admin', 'super_admin'),
  async (req: AuthRequest, res, next) => {
    try {
      const settings = await PlatformService.getSettings();
      res.json({ success: true, data: settings });
    } catch (e) {
      next(e);
    }
  }
);

/**
 * PUT /api/v1/settings/platform-fee
 * Body: { platform_fee_percentage: number, hold_period_days?: number }
 * Admin/super_admin only.
 */
router.put(
  '/platform-fee',
  authenticate,
  requireRole('admin', 'super_admin'),
  async (req: AuthRequest, res, next) => {
    try {
      const { platform_fee_percentage, hold_period_days } = req.body;

      let updated: any;
      if (platform_fee_percentage !== undefined) {
        updated = await PlatformService.updateFee(
          parseFloat(platform_fee_percentage),
          req.user!.id
        );
      }
      if (hold_period_days !== undefined) {
        updated = await PlatformService.updateHoldPeriod(
          parseInt(hold_period_days, 10),
          req.user!.id
        );
      }
      if (!updated) {
        return res.status(400).json({ success: false, error: 'No fields to update' });
      }

      res.json({ success: true, data: updated, message: 'Platform settings updated' });
    } catch (e) {
      next(e);
    }
  }
);

export { router as platformRouter };
