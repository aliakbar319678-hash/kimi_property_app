import { Router } from 'express';
import { query } from '../db';
import { authenticate, requireRole } from '../middleware/auth';
import { adminOrJwtAuth } from '../middleware/adminKey';

const router = Router();

// Get Platform Configurations
router.get('/', adminOrJwtAuth, async (req, res, next) => {
  try {
    const configRes = await query('SELECT * FROM platform_configs LIMIT 1');
    res.json({ success: true, data: configRes.rows[0] });
  } catch (e) { next(e); }
});

// Update Platform Configurations (Admin Only)
router.put('/', adminOrJwtAuth, async (req: any, res, next) => {
  try {
    const { commission_percent, admin_fee, late_fee_percent, currency } = req.body;
    const configRes = await query(
      `UPDATE platform_configs 
       SET commission_percent = COALESCE($1, commission_percent),
           admin_fee = COALESCE($2, admin_fee),
           late_fee_percent = COALESCE($3, late_fee_percent),
           currency = COALESCE($4, currency),
           updated_by = $5,
           updated_at = NOW()
       RETURNING *`,
      [commission_percent, admin_fee, late_fee_percent, currency, req.user!.id]
    );
    res.json({ success: true, data: configRes.rows[0] });
  } catch (e) { next(e); }
});

export { router as configRouter };
