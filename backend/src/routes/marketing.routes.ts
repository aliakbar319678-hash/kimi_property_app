import { Router } from 'express';
import { query } from '../db';
import { authenticate, AuthRequest } from '../middleware/auth';
import { AppError } from '../middleware/errorHandler';

const router = Router();

/**
 * @swagger
 * tags:
 *   name: Marketing & Showings
 *   description: Property listings, pre-leasing, showing scheduling, and virtual tour options
 */

/**
 * @swagger
 * /api/v1/marketing/listings:
 *   post:
 *     summary: Set marketing info for a property
 *     tags: [Marketing & Showings]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [propertyId]
 *             properties:
 *               propertyId: { type: string, format: uuid }
 *               publicDescription: { type: string }
 *               virtualTourUrl: { type: string }
 *               isFeatured: { type: boolean }
 *               amenities: { type: array, items: { type: string } }
 *     responses:
 *       201:
 *         description: Marketing profile created/updated
 */
router.post('/listings', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const { propertyId, publicDescription, virtualTourUrl, isFeatured, amenities } = req.body;

    // Verify property status and verification status first
    const propRes = await query('SELECT status, verification_status FROM properties WHERE id = $1', [propertyId]);
    if (propRes.rows.length === 0) throw new AppError('Property not found', 404);
    
    const prop = propRes.rows[0];
    if (prop.verification_status !== 'approved' || prop.status === 'rejected') {
      throw new AppError('Cannot create marketing profile for unverified or rejected properties', 400);
    }

    const result = await query(
      `INSERT INTO property_marketing 
       (property_id, public_description, virtual_tour_url, is_featured, amenities)
       VALUES ($1, $2, $3, $4, $5)
       ON CONFLICT (property_id) DO UPDATE 
       SET public_description = EXCLUDED.public_description, virtual_tour_url = EXCLUDED.virtual_tour_url,
           is_featured = EXCLUDED.is_featured, amenities = EXCLUDED.amenities
       RETURNING *`,
      [propertyId, publicDescription, virtualTourUrl, isFeatured || false, amenities || []]
    );

    res.status(201).json({ success: true, data: result.rows[0] });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/marketing/listings/{propertyId}:
 *   get:
 *     summary: Fetch marketing profile for a property
 *     tags: [Marketing & Showings]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: propertyId
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *     responses:
 *       200:
 *         description: Marketing profile retrieved
 */
router.get('/listings/:propertyId', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const { propertyId } = req.params;
    const result = await query('SELECT * FROM property_marketing WHERE property_id = $1', [propertyId]);
    if (result.rows.length === 0) throw new AppError('Marketing info not found', 404);
    res.json({ success: true, data: result.rows[0] });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/marketing/showings:
 *   post:
 *     summary: Schedule a property showing/viewing
 *     tags: [Marketing & Showings]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [propertyId, showingDate]
 *             properties:
 *               propertyId: { type: string, format: uuid }
 *               showingDate: { type: string, format: date-time }
 *               notes: { type: string }
 *     responses:
 *       201:
 *         description: Showing scheduled
 */
router.post('/showings', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const { propertyId } = req.body;
    const showingDate = req.body.showingDate || req.body.showing_date;
    const notes = req.body.notes || req.body.note;
    const tenantId = req.user!.id;

    // Verify property status first
    const propRes = await query('SELECT status, verification_status FROM properties WHERE id = $1', [propertyId]);
    if (propRes.rows.length === 0) throw new AppError('Property not found', 404);
    
    const prop = propRes.rows[0];
    if (prop.verification_status !== 'approved' || prop.status === 'rejected') {
      throw new AppError('Cannot schedule showings for unverified or rejected properties', 400);
    }

    const result = await query(
      `INSERT INTO showings (property_id, tenant_id, showing_date, status, notes)
       VALUES ($1, $2, $3, 'SCHEDULED', $4) RETURNING *`,
      [propertyId, tenantId, showingDate, notes]
    );

    res.status(201).json({ success: true, data: result.rows[0] });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/marketing/showings:
 *   get:
 *     summary: List all scheduled showings
 *     tags: [Marketing & Showings]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of scheduled showings
 */
router.get('/showings', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const result = await query('SELECT * FROM showings ORDER BY showing_date ASC');
    res.json({ success: true, data: result.rows });
  } catch (e) { next(e); }
});

export { router as marketingRouter };
