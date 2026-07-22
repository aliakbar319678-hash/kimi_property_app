import { Router } from 'express';
import { PropertyService } from '../services/property.service';
import { authenticate, AuthRequest, requireRole } from '../middleware/auth';
import { validate, schemas } from '../utils/validation';

const router = Router();

/**
 * @swagger
 * tags:
 *   name: Properties
 *   description: Property management endpoints
 */

/**
 * @swagger
 * /api/v1/properties:
 *   post:
 *     summary: Create a new property
 *     tags: [Properties]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [title, address, type]
 *             properties:
 *               title:
 *                 type: string
 *                 example: "Luxury Apartment"
 *               description:
 *                 type: string
 *                 example: "A beautiful apartment in the city center"
 *               address:
 *                 type: string
 *                 example: "123 Main St, New York, NY 10001"
 *               type:
 *                 type: string
 *                 example: "apartment"
 *               price:
 *                 type: number
 *                 example: 2500
 *     responses:
 *       201:
 *         description: Property created successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   type: object
 *                   properties:
 *                     id:
 *                       type: string
 *                     title:
 *                       type: string
 */
router.post('/', authenticate, requireRole('landlord', 'property_manager', 'admin'), validate(schemas.propertyCreate), async (req: AuthRequest, res, next) => {
  try {
    const property = await PropertyService.create(req.body, req.user!.id);
    res.status(201).json({ success: true, data: property });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/properties:
 *   get:
 *     summary: Get properties for the current user based on role
 *     tags: [Properties]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of properties
 */
router.get('/', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const role = req.user!.activeRole || req.user!.roles[0];
    if (role === 'landlord' || role === 'property_manager') {
      const properties = await PropertyService.getByLandlordId(req.user!.id);
      res.json({ success: true, data: properties });
    } else if (role === 'tenant') {
      const db = require('../db');
      const properties = await db.query(
        `SELECT DISTINCT p.* FROM properties p
         JOIN leases l ON l.property_id = p.id
         WHERE l.tenant_id = $1`,
        [req.user!.id]
      );
      res.json({ success: true, data: properties.rows });
    } else {
      const db = require('../db');
      const properties = await db.query('SELECT * FROM properties');
      res.json({ success: true, data: properties.rows });
    }
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/properties/search:
 *   get:
 *     summary: Search for properties
 *     tags: [Properties]
 *     parameters:
 *       - in: query
 *         name: q
 *         schema:
 *           type: string
 *         description: Search query
 *       - in: query
 *         name: type
 *         schema:
 *           type: string
 *         description: Property type
 *       - in: query
 *         name: minPrice
 *         schema:
 *           type: number
 *       - in: query
 *         name: maxPrice
 *         schema:
 *           type: number
 *     responses:
 *       200:
 *         description: Search results
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   type: array
 *                   items:
 *                     type: object
 *                 total:
 *                   type: number
 */
router.get('/search', async (req: AuthRequest, res, next) => {
  try {
    const result = await PropertyService.search(req.query);
    res.json({ success: true, ...result });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/properties/vacant:
 *   get:
 *     summary: Get vacant properties (Public)
 *     tags: [Properties]
 *     responses:
 *       200:
 *         description: List of vacant properties
 */
router.get('/vacant', async (req, res, next) => {
  try {
    const db = require('../db');
    // Fetch properties that have status available or vacant units
    const propertiesRes = await db.query(
      `SELECT p.*, COALESCE(
        (SELECT json_agg(u.*) FROM units u WHERE u.property_id = p.id AND u.status = 'vacant'),
        '[]'::json
      ) as units
      FROM properties p
      WHERE EXISTS (SELECT 1 FROM units u WHERE u.property_id = p.id AND u.status = 'vacant')
         OR p.status = 'available'
      ORDER BY p.created_at DESC`
    );
    res.json({ success: true, data: propertiesRes.rows });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/properties/{id}:
 *   get:
 *     summary: Get a property by ID
 *     tags: [Properties]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Property ID
 *     responses:
 *       200:
 *         description: Property details
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   type: object
 */
router.get('/:id', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const property = await PropertyService.getById(req.params.id);
    res.json({ success: true, data: property });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/properties/{id}/units:
 *   get:
 *     summary: Get all units for a property
 *     tags: [Properties]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Property ID
 *     responses:
 *       200:
 *         description: List of units
 */
router.get('/:id/units', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const db = require('../db');
    const unitsRes = await db.query('SELECT * FROM units WHERE property_id = $1', [req.params.id]);
    res.json({ success: true, data: unitsRes.rows });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/properties/{id}/units:
 *   post:
 *     summary: Create a unit within a property
 *     tags: [Properties]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Property ID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [unitNumber, price]
 *             properties:
 *               unitNumber:
 *                 type: string
 *               price:
 *                 type: number
 *     responses:
 *       201:
 *         description: Unit created
 */
router.post('/:id/units', authenticate, requireRole('landlord', 'property_manager'), async (req: AuthRequest, res, next) => {
  try {
    const unit = await PropertyService.createUnit(req.params.id, req.body);
    res.status(201).json({ success: true, data: unit });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/properties/{id}/save:
 *   post:
 *     summary: Save a property for a tenant
 *     tags: [Properties]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Property ID
 *     responses:
 *       200:
 *         description: Property saved successfully
 */
router.post('/:id/save', authenticate, requireRole('tenant'), async (req: AuthRequest, res, next) => {
  try {
    const result = await PropertyService.saveProperty(req.user!.id, req.params.id);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/properties/saved/me:
 *   get:
 *     summary: Get user's saved properties
 *     tags: [Properties]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of saved properties
 */
router.get('/saved/me', authenticate, requireRole('tenant'), async (req: AuthRequest, res, next) => {
  try {
    const saved = await PropertyService.getSaved(req.user!.id);
    res.json({ success: true, data: saved });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/properties/{id}:
 *   put:
 *     summary: Update an existing property
 *     tags: [Properties]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Property ID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               status:
 *                 type: string
 *                 enum: [active, inactive, pending_verification, rejected, archived, available, pending, rented, maintenance, published]
 *                 example: "available"
 *               verification_status:
 *                 type: string
 *                 enum: [pending, approved, rejected]
 *                 example: "approved"
 *               name:
 *                 type: string
 *               description:
 *                 type: string
 *     responses:
 *       200:
 *         description: Property updated successfully
 */
router.put('/:id', authenticate, requireRole('landlord', 'property_manager', 'admin', 'super_admin'), async (req: AuthRequest, res, next) => {
  try {
    const property = await PropertyService.update(req.params.id, req.body, req.user!.id, req.user!.roles);
    res.json({ success: true, data: property });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/properties/{id}:
 *   delete:
 *     summary: Delete a property
 *     tags: [Properties]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Property deleted
 */
router.delete('/:id', authenticate, requireRole('landlord', 'property_manager', 'admin', 'super_admin'), async (req: AuthRequest, res, next) => {
  try {
    const propRes = await require('../db').query('SELECT landlord_id FROM properties WHERE id = $1', [req.params.id]);
    if (propRes.rows.length === 0) { res.status(404).json({ success: false, message: 'Property not found' }); return; }
    const isOwner = propRes.rows[0].landlord_id === req.user!.id;
    const isAdmin = req.user!.roles.includes('admin') || req.user!.roles.includes('super_admin');
    if (!isOwner && !isAdmin) { res.status(403).json({ success: false, message: 'Unauthorized' }); return; }
    await require('../db').query('DELETE FROM properties WHERE id = $1', [req.params.id]);
    res.json({ success: true, message: 'Property deleted successfully' });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/properties/{id}/units/{unitId}:
 *   put:
 *     summary: Update a unit within a property
 *     tags: [Properties]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *       - in: path
 *         name: unitId
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               unitNumber: { type: string }
 *               bedrooms: { type: integer }
 *               bathrooms: { type: integer }
 *               squareFeet: { type: integer }
 *               rentAmount: { type: number }
 *               depositAmount: { type: number }
 *               status: { type: string, enum: [vacant, occupied, maintenance, reserved] }
 *               availableDate: { type: string, format: date }
 *     responses:
 *       200:
 *         description: Unit updated
 */
router.put('/:id/units/:unitId', authenticate, requireRole('landlord', 'property_manager'), async (req: AuthRequest, res, next) => {
  try {
    const { unitId } = req.params;
    const { unitNumber, bedrooms, bathrooms, squareFeet, rentAmount, depositAmount, status, availableDate } = req.body;
    const db = require('../db');
    const unitRes = await db.query('SELECT * FROM units WHERE id = $1 AND property_id = $2', [unitId, req.params.id]);
    if (unitRes.rows.length === 0) { res.status(404).json({ success: false, message: 'Unit not found' }); return; }
    const updated = await db.query(
      `UPDATE units SET
         unit_number = COALESCE($1, unit_number),
         bedrooms = COALESCE($2, bedrooms),
         bathrooms = COALESCE($3, bathrooms),
         square_feet = COALESCE($4, square_feet),
         rent_amount = COALESCE($5, rent_amount),
         deposit_amount = COALESCE($6, deposit_amount),
         status = COALESCE($7, status),
         available_date = COALESCE($8, available_date)
       WHERE id = $9 RETURNING *`,
      [unitNumber, bedrooms, bathrooms, squareFeet, rentAmount, depositAmount, status, availableDate, unitId]
    );
    res.json({ success: true, data: updated.rows[0] });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/properties/{id}/units/{unitId}:
 *   delete:
 *     summary: Delete a unit from a property
 *     tags: [Properties]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *       - in: path
 *         name: unitId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Unit deleted
 */
router.delete('/:id/units/:unitId', authenticate, requireRole('landlord', 'property_manager'), async (req: AuthRequest, res, next) => {
  try {
    const db = require('../db');
    const unitRes = await db.query('SELECT id FROM units WHERE id = $1 AND property_id = $2', [req.params.unitId, req.params.id]);
    if (unitRes.rows.length === 0) { res.status(404).json({ success: false, message: 'Unit not found' }); return; }
    await db.query('DELETE FROM units WHERE id = $1', [req.params.unitId]);
    res.json({ success: true, message: 'Unit deleted successfully' });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/properties/{id}/resubmit:
 *   post:
 *     summary: Resubmit a property for verification
 *     tags: [Properties]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Resubmitted successfully
 */
router.post('/:id/resubmit', authenticate, requireRole('landlord', 'property_manager'), async (req: AuthRequest, res, next) => {
  try {
    const result = await PropertyService.resubmitProperty(req.params.id, req.user!.id);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

export { router as propertyRouter };
