import { Router } from 'express';
import { query } from '../db';
import { authenticate, AuthRequest } from '../middleware/auth';
import { AppError } from '../middleware/errorHandler';

const router = Router();

/**
 * @swagger
 * tags:
 *   name: Move Process
 *   description: Move-in checklist, move-out inspections, and deposit refunds
 */

/**
 * @swagger
 * /api/v1/move-in/checklists:
 *   post:
 *     summary: Create a move-in checklist (using combined inspections table)
 *     tags: [Move Process]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [leaseId]
 *             properties:
 *               leaseId: { type: string, format: uuid }
 *               conditionRatings: { type: object }
 *     responses:
 *       201:
 *         description: Checklist created
 */
router.post('/checklists', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const { leaseId, conditionRatings } = req.body;
    const inspectorId = req.user!.id;

    const result = await query(
      `INSERT INTO move_inspections (lease_id, type, inspector_id, condition_ratings, status)
       VALUES ($1, 'MOVE_IN', $2, $3, 'draft') RETURNING *`,
      [leaseId, inspectorId, JSON.stringify(conditionRatings || {})]
    );

    res.status(201).json({ success: true, data: result.rows[0] });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/move-in/checklists/{id}:
 *   get:
 *     summary: Get a move inspection checklist / report
 *     tags: [Move Process]
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
 *         description: Checklist data
 */
router.get('/checklists/:id', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const { id } = req.params;
    const result = await query('SELECT * FROM move_inspections WHERE id = $1', [id]);
    if (result.rows.length === 0) throw new AppError('Checklist/Inspection not found', 404);
    res.json({ success: true, data: result.rows[0] });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/move-in/checklists/{id}/sign:
 *   put:
 *     summary: Sign a move inspection
 *     tags: [Move Process]
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
 *             required: [role, signature]
 *             properties:
 *               role:
 *                 type: string
 *                 enum: [tenant, landlord]
 *               signature:
 *                 type: string
 *     responses:
 *       200:
 *         description: Checklist signed
 */
router.put('/checklists/:id/sign', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const { id } = req.params;
    const { role, signature } = req.body;

    const userRoles = req.user!.roles || [(req.user as any).role];

    if (!userRoles.includes('tenant') && !userRoles.includes('landlord')) {
        throw new AppError('Invalid signing role', 400);
    }

    let updateField = '';
    const signingRole = role || (userRoles.includes('tenant') ? 'tenant' : 'landlord');

    if (signingRole === 'tenant') updateField = 'tenant_signature = $1';
    else if (signingRole === 'landlord') updateField = 'landlord_signature = $1';
    else throw new AppError('Invalid signing role', 400);

    const result = await query(
      `UPDATE move_inspections 
       SET ${updateField}, signed_at = NOW(), updated_at = NOW() 
       WHERE id = $2 RETURNING *`,
      [signature || 'Signed', id]
    );

    if (result.rows.length === 0) throw new AppError('Checklist/Inspection not found', 404);
    res.json({ success: true, data: result.rows[0] });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/move-out/inspections:
 *   post:
 *     summary: Create a move-out inspection report
 *     tags: [Move Process]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [leaseId]
 *             properties:
 *               leaseId: { type: string, format: uuid }
 *               conditionRatings: { type: object }
 *               depositRefunded: { type: number }
 *     responses:
 *       201:
 *         description: Inspection recorded
 */
router.post('/inspections', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const { leaseId, conditionRatings, depositRefunded } = req.body;
    const inspectorId = req.user!.id;

    const status = req.body.status || 'draft';
    const result = await query(
      `INSERT INTO move_inspections 
       (lease_id, type, inspector_id, condition_ratings, deposit_refunded, status)
       VALUES ($1, 'MOVE_OUT', $2, $3, $4, $5) RETURNING *`,
      [leaseId, inspectorId, JSON.stringify(conditionRatings || {}), depositRefunded || 0, status]
    );

    res.status(201).json({ success: true, data: result.rows[0] });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/move-out/inspections/{id}:
 *   get:
 *     summary: Get a move-out inspection
 *     tags: [Move Process]
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
 *         description: Inspection retrieved
 */
router.get('/inspections/:id', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const { id } = req.params;
    const result = await query('SELECT * FROM move_inspections WHERE id = $1 AND type = \'MOVE_OUT\'', [id]);
    if (result.rows.length === 0) throw new AppError('Inspection not found', 404);
    res.json({ success: true, data: result.rows[0] });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/move-out/deposit-returns:
 *   post:
 *     summary: Return/Refund security deposit
 *     tags: [Move Process]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [inspectionId, amount]
 *             properties:
 *               inspectionId: { type: string, format: uuid }
 *               amount: { type: number }
 *     responses:
 *       200:
 *         description: Deposit return processed
 */
router.post('/deposit-returns', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const { inspectionId, leaseId, amount, transactionId = null } = req.body;

    let result;
    if (inspectionId) {
      result = await query(
        `UPDATE move_inspections 
         SET deposit_refunded = $1, transaction_id = $2, status = 'finalized'
         WHERE id = $3 RETURNING *`,
        [amount, transactionId, inspectionId]
      );
    } else if (leaseId) {
      result = await query(
        `UPDATE move_inspections 
         SET deposit_refunded = $1, transaction_id = $2, status = 'finalized'
         WHERE lease_id = $3 AND type = 'MOVE_OUT' RETURNING *`,
        [amount, transactionId, leaseId]
      );
    } else {
      throw new AppError('inspectionId or leaseId is required', 400);
    }

    if (!result || result.rows.length === 0) throw new AppError('Inspection report not found', 404);
    res.json({ success: true, message: 'Deposit refund successfully completed', data: result.rows[0] });
  } catch (e) { next(e); }
});

export { router as moveRouter };
