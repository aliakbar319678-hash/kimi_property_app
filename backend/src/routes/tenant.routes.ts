import { Router } from 'express';
import { authenticate, AuthRequest, requireRole } from '../middleware/auth';
import { pool } from '../db';

const router = Router();

/**
 * @swagger
 * /api/v1/tenant/active-lease:
 *   get:
 *     summary: Get active lease for the current tenant
 *     tags: [Tenant]
 *     security:
 *       - bearerAuth: []
 */
router.get('/active-lease', authenticate, requireRole('tenant'), async (req: AuthRequest, res, next) => {
  try {
    const leaseRes = await pool.query(
      `SELECT l.*, p.name as property_name, p.address_line1, p.city, un.unit_number, un.bedrooms, un.bathrooms, u.display_name as landlord_name, u.phone as landlord_phone
       FROM leases l
       JOIN properties p ON l.property_id = p.id
       JOIN units un ON l.unit_id = un.id
       JOIN users u ON l.landlord_id = u.id
       WHERE l.tenant_id = $1 AND l.status = 'active'
       ORDER BY l.created_at DESC LIMIT 1`,
      [req.user!.id]
    );
    
    if (leaseRes.rows.length === 0) {
       res.json({ success: true, data: null });
       return;
    }
    
    res.json({ success: true, data: leaseRes.rows[0] });
  } catch (e) {
    next(e);
  }
});

export { router as tenantRouter };
