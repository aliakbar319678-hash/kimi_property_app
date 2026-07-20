import { Router } from 'express';
import { query } from '../db';
import { authenticate, AuthRequest } from '../middleware/auth';
import { AppError } from '../middleware/errorHandler';

const router = Router();

/**
 * @swagger
 * tags:
 *   name: Late Payments
 *   description: Late rent payments notices and automation
 */

/**
 * @swagger
 * /api/v1/payments/late-notices:
 *   post:
 *     summary: Create a late payment notice
 *     tags: [Late Payments]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [leaseId, tenantId, amountDue, daysLate]
 *             properties:
 *               leaseId: { type: string, format: uuid }
 *               tenantId: { type: string, format: uuid }
 *               amountDue: { type: number }
 *               lateFeeApplied: { type: number }
 *               daysLate: { type: integer }
 *     responses:
 *       201:
 *         description: Notice created
 */
router.post('/late-notices', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const { leaseId, tenantId, amountDue, lateFeeApplied, daysLate, legalCaseReference = null, courtHearingDate = null, legalDocuments = [] } = req.body;

    const result = await query(
      `INSERT INTO late_payment_notices (lease_id, tenant_id, amount_due, late_fee_applied, days_late, notice_status, legal_case_reference, court_hearing_date, legal_documents)
       VALUES ($1, $2, $3, $4, $5, 'SENT', $6, $7, $8) RETURNING *`,
      [leaseId, tenantId, amountDue, lateFeeApplied || 0, daysLate || 1, legalCaseReference, courtHearingDate, JSON.stringify(legalDocuments)]
    );

    res.status(201).json({ success: true, data: result.rows[0] });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/payments/late-notices:
 *   get:
 *     summary: Fetch all late payment notices
 *     tags: [Late Payments]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of late notices
 */
router.get('/late-notices', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const result = await query('SELECT * FROM late_payment_notices ORDER BY created_at DESC');
    res.json({ success: true, data: result.rows });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/payments/late-notices/{id}/send:
 *   post:
 *     summary: Send mock late notice notification (SMS/Email)
 *     tags: [Late Payments]
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
 *         description: Notice notification dispatched
 */
router.post('/late-notices/:id/send', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const { id } = req.params;

    const result = await query('SELECT * FROM late_payment_notices WHERE id = $1', [id]);
    if (result.rows.length === 0) throw new AppError('Notice not found', 404);

    const notice = result.rows[0];

    // Mock logging the SMS/Email
    await query(
      `INSERT INTO sms_logs (user_id, phone, message, status) 
       VALUES ($1, $2, $3, 'sent')`,
      [notice.tenant_id, '+1000000000', `Late notice (Days late: ${notice.days_late}): Rent is late. Due: $${notice.amount_due}. Please pay immediately.`]
    );

    res.json({
      success: true,
      message: 'Late notice sent successfully via Twilio/SendGrid mock client.',
      data: notice
    });
  } catch (e) { next(e); }
});

export { router as lateRouter };
