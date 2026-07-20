import { Router } from 'express';
import { query } from '../db';
import { authenticate, AuthRequest } from '../middleware/auth';
import { AppError } from '../middleware/errorHandler';

const router = Router();

/**
 * @swagger
 * tags:
 *   name: Tenant Screening
 *   description: Tenant application screening and verification APIs
 */

/**
 * @swagger
 * /api/v1/screening/applications:
 *   post:
 *     summary: Submit a tenant screening application
 *     tags: [Tenant Screening]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [propertyId, monthlyIncome]
 *             properties:
 *               propertyId:
 *                 type: string
 *                 format: uuid
 *               monthlyIncome:
 *                 type: number
 *               employmentStatus:
 *                 type: string
 *     responses:
 *       201:
 *         description: Screening application submitted
 */
router.post('/applications', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const { propertyId, monthlyIncome, employmentStatus } = req.body;
    const tenantId = req.user!.id;

    // Simulate getting credit score and background check status
    const creditScore = Math.floor(Math.random() * (850 - 500 + 1)) + 500;
    const backgroundStatus = 'APPROVED';

    const result = await query(
      `INSERT INTO screening_applications 
       (tenant_id, property_id, monthly_income, employment_status, credit_score_mock, background_status_mock, decision) 
       VALUES ($1, $2, $3, $4, $5, $6, 'PENDING') 
       RETURNING *`,
      [tenantId, propertyId, monthlyIncome || 0, employmentStatus || 'employed', creditScore, backgroundStatus]
    );

    res.status(201).json({ success: true, data: result.rows[0] });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/screening/applications/{id}:
 *   get:
 *     summary: Get screening application details
 *     tags: [Tenant Screening]
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
 *         description: Details retrieved
 */
router.get('/applications/:id', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const { id } = req.params;
    const result = await query('SELECT * FROM screening_applications WHERE id = $1', [id]);
    if (result.rows.length === 0) throw new AppError('Application not found', 404);
    res.json({ success: true, data: result.rows[0] });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/screening/applications/{id}/decision:
 *   post:
 *     summary: Make a decision on an application (Approve/Reject)
 *     tags: [Tenant Screening]
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
 *             required: [decision]
 *             properties:
 *               decision:
 *                 type: string
 *                 enum: [APPROVED, REJECTED, PENDING]
 *     responses:
 *       200:
 *         description: Decision updated
 */
router.post('/applications/:id/decision', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const { id } = req.params;
    const { decision } = req.body;

    const result = await query(
      `UPDATE screening_applications 
       SET decision = $1 
       WHERE id = $2 
       RETURNING *`,
      [decision, id]
    );

    if (result.rows.length === 0) throw new AppError('Application not found', 404);
    res.json({ success: true, data: result.rows[0] });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/screening/applications/{id}/credit-report:
 *   get:
 *     summary: Get mock credit report for screening
 *     tags: [Tenant Screening]
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
 *         description: Credit report retrieved
 */
router.get('/applications/:id/credit-report', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const { id } = req.params;
    const result = await query('SELECT credit_score_mock FROM screening_applications WHERE id = $1', [id]);
    if (result.rows.length === 0) throw new AppError('Application not found', 404);

    res.json({
      success: true,
      data: {
        score: result.rows[0].credit_score_mock,
        agency: 'TransUnion (Mock)',
        riskLevel: result.rows[0].credit_score_mock > 700 ? 'Low' : 'Medium-High',
        reportDate: new Date().toISOString()
      }
    });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/screening/applications/{id}/background-check:
 *   get:
 *     summary: Get mock background check results
 *     tags: [Tenant Screening]
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
 *         description: Background check retrieved
 */
router.get('/applications/:id/background-check', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const { id } = req.params;
    const result = await query('SELECT background_status_mock FROM screening_applications WHERE id = $1', [id]);
    if (result.rows.length === 0) throw new AppError('Application not found', 404);

    res.json({
      success: true,
      data: {
        checkId: id,
        agency: 'Checkr (Mock)',
        status: result.rows[0].background_status_mock,
        details: { criminal_record: false, evictions: 0 }
      }
    });
  } catch (e) { next(e); }
});

export { router as screeningRouter };
