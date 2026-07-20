import { Router } from 'express';
import { VendorService } from '../services/vendor.service';
import { MaintenanceService } from '../services/maintenance.service';
import { authenticate, AuthRequest, requireRole } from '../middleware/auth';

const router = Router();

/**
 * @swagger
 * tags:
 *   name: Vendors
 *   description: Vendor specific endpoints (Bids, Stats, Jobs)
 */

/**
 * @swagger
 * /api/v1/vendors/my-bids:
 *   get:
 *     summary: Get vendor's bids
 *     tags: [Vendors]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: status
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: List of vendor bids
 */
router.get('/my-bids', authenticate, requireRole('vendor'), async (req: AuthRequest, res, next) => {
  try {
    const bids = await VendorService.getMyBids(req.user!.id, req.query.status as string);
    res.json({ success: true, data: bids });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/vendors/stats:
 *   get:
 *     summary: Get vendor statistics
 *     tags: [Vendors]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Vendor stats
 */
router.get('/stats', authenticate, requireRole('vendor'), async (req: AuthRequest, res, next) => {
  try {
    const stats = await VendorService.getVendorStats(req.user!.id);
    res.json({ success: true, data: stats });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/vendors/jobs:
 *   get:
 *     summary: Get vendor jobs
 *     tags: [Vendors]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: status
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Vendor jobs list
 */
router.get('/jobs', authenticate, requireRole('vendor'), async (req: AuthRequest, res, next) => {
  try {
    const jobs = await MaintenanceService.getVendorJobs(req.user!.id, req.query.status as string);
    res.json({ success: true, data: jobs });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/vendors/{id}:
 *   get:
 *     summary: Get vendor profile by ID
 *     tags: [Vendors]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Vendor user ID
 *     responses:
 *       200:
 *         description: Vendor profile with ratings and stats
 *       404:
 *         description: Vendor not found
 */
router.get('/:id', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const { query: dbQuery } = require('../db');
    const vendorRes = await dbQuery(
      `SELECT u.id, u.email, u.display_name, u.avatar_url, u.created_at,
              COALESCE(AVG(vr.rating), 0) as avg_rating,
              COUNT(vr.id) as total_reviews,
              COUNT(DISTINCT ja.id) as jobs_completed
       FROM users u
       LEFT JOIN vendor_reviews vr ON vr.vendor_id = u.id
       LEFT JOIN job_assignments ja ON ja.vendor_id = u.id AND ja.status = 'completed'
       JOIN user_roles ur ON ur.user_id = u.id AND ur.role = 'vendor'
       WHERE u.id = $1
       GROUP BY u.id`,
      [req.params.id]
    );
    if (vendorRes.rows.length === 0) { res.status(404).json({ success: false, message: 'Vendor not found' }); return; }
    const reviewsRes = await dbQuery(
      `SELECT vr.rating, vr.comment, vr.created_at, u.display_name as reviewer_name
       FROM vendor_reviews vr
       JOIN users u ON u.id = vr.reviewer_id
       WHERE vr.vendor_id = $1
       ORDER BY vr.created_at DESC LIMIT 10`,
      [req.params.id]
    );
    res.json({ success: true, data: { ...vendorRes.rows[0], reviews: reviewsRes.rows } });
  } catch (e) { next(e); }
});

export { router as vendorRouter };
