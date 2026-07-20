import { Router } from 'express';
import { query } from '../db';
import { authenticate, AuthRequest } from '../middleware/auth';
import { AppError } from '../middleware/errorHandler';

const router = Router();

/**
 * @swagger
 * tags:
 *   name: Advanced Vendors
 *   description: Vendor ratings, directory, quote comparisons, and insurance verification
 */

/**
 * @swagger
 * /api/v1/vendors/{id}/ratings:
 *   post:
 *     summary: Add review and rating for a vendor
 *     tags: [Advanced Vendors]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [rating, review]
 *             properties:
 *               rating: { type: integer, minimum: 1, maximum: 5 }
 *               review: { type: string }
 *     responses:
 *       201:
 *         description: Rating added
 */
router.post('/:id/ratings', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const { id } = req.params; // vendor_id
    const { rating, review, categories = [], workOrderId = null } = req.body;
    const ratedBy = req.user!.id;

    // Log rating in common ratings table
    await query(
      `INSERT INTO vendor_reviews (vendor_id, reviewer_id, rating, comment, categories, work_order_id)
       VALUES ($1, $2, $3, $4, $5, $6)`,
      [id, ratedBy, rating, review, JSON.stringify(categories), workOrderId]
    );

    // Calculate aggregate average rating
    const avgRes = await query('SELECT AVG(rating)::numeric(3,2) as avg_rating FROM vendor_reviews WHERE vendor_id = $1', [id]);
    const avgRating = avgRes.rows[0].avg_rating || 0.00;

    // Update in vendor_profiles_advanced
    const result = await query(
      `INSERT INTO vendor_profiles_advanced (vendor_id, average_rating)
       VALUES ($1, $2)
       ON CONFLICT (vendor_id) DO UPDATE SET average_rating = EXCLUDED.average_rating
       RETURNING *`,
      [id, avgRating]
    );

    res.status(201).json({ success: true, data: result.rows[0] });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/vendors/directory:
 *   get:
 *     summary: Get vendor directory with ratings
 *     tags: [Advanced Vendors]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of vendors
 */
router.get('/directory', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const result = await query(
      `SELECT u.id, u.display_name, u.email, COALESCE(vpa.average_rating, 0.00)::float as avg_rating
       FROM users u
       JOIN user_roles ur ON u.id = ur.user_id AND ur.role = 'vendor'
       LEFT JOIN vendor_profiles_advanced vpa ON u.id = vpa.vendor_id`
    );
    res.json({ success: true, data: result.rows });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/vendors/{id}/insurance:
 *   get:
 *     summary: Fetch vendor insurance verification details
 *     tags: [Advanced Vendors]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *     responses:
 *       200:
 *         description: Insurance details
 */
router.get('/:id/insurance', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const { id } = req.params;
    const result = await query('SELECT * FROM vendor_profiles_advanced WHERE vendor_id = $1', [id]);
    res.json({ success: true, data: result.rows });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/vendors/{id}/insurance:
 *   post:
 *     summary: Add or update vendor insurance details
 *     tags: [Advanced Vendors]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [insurancePolicyNumber, insuranceExpiry]
 *             properties:
 *               insurancePolicyNumber: { type: string }
 *               insuranceExpiry: { type: string, format: date }
 *     responses:
 *       200:
 *         description: Insurance details set
 */
router.post('/:id/insurance', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const { id } = req.params; // vendor_id
    const { insurancePolicyNumber, insuranceExpiry } = req.body;

    const result = await query(
      `INSERT INTO vendor_profiles_advanced (vendor_id, insurance_policy_number, insurance_expiry, is_insurance_verified)
       VALUES ($1, $2, $3, true)
       ON CONFLICT (vendor_id) DO UPDATE 
       SET insurance_policy_number = EXCLUDED.insurance_policy_number, insurance_expiry = EXCLUDED.insurance_expiry, is_insurance_verified = true
       RETURNING *`,
      [id, insurancePolicyNumber, insuranceExpiry]
    );

    res.json({ success: true, data: result.rows[0] });
  } catch (e) { next(e); }
});

export { router as vendorAdvancedRouter };
