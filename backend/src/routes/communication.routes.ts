import { Router } from 'express';
import { query } from '../db';
import { authenticate, AuthRequest } from '../middleware/auth';
import { AppError } from '../middleware/errorHandler';

const router = Router();

/**
 * @swagger
 * tags:
 *   name: Communications
 *   description: SMS logging, Twilio mock interface, and email template managers
 */

/**
 * @swagger
 * /api/v1/communications/sms:
 *   post:
 *     summary: Send a mock SMS notification
 *     tags: [Communications]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [phone, message]
 *             properties:
 *               phone: { type: string }
 *               message: { type: string }
 *     responses:
 *       200:
 *         description: SMS logged
 */
router.post('/sms', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const phone = req.body.phone || req.body.phoneNumber;
    const message = req.body.message;
    const userId = req.user!.id;

    const result = await query(
      `INSERT INTO sms_logs (user_id, phone, message, status)
       VALUES ($1, $2, $3, 'sent') RETURNING *`,
      [userId, phone, message]
    );

    res.json({ success: true, message: 'SMS message successfully sent (Mocked Twilio)', data: result.rows[0] });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/communications/email-templates:
 *   get:
 *     summary: Fetch all email templates
 *     tags: [Communications]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of email templates
 */
router.get('/email-templates', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const result = await query('SELECT * FROM email_templates WHERE is_active = true');
    res.json({ success: true, data: result.rows });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/communications/email-templates:
 *   post:
 *     summary: Create/Register an email template
 *     tags: [Communications]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [name, subject, body]
 *             properties:
 *               name: { type: string }
 *               subject: { type: string }
 *               body: { type: string }
 *               variables: { type: array, items: { type: string } }
 *               type: { type: string }
 *     responses:
 *       201:
 *         description: Template created
 */
router.post('/email-templates', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const { name, subject, body, variables, type } = req.body;

    const result = await query(
      `INSERT INTO email_templates (name, subject, body, variables, type)
       VALUES ($1, $2, $3, $4, $5) RETURNING *`,
      [name, subject, body, JSON.stringify(variables || []), type || 'general']
    );

    res.status(201).json({ success: true, data: result.rows[0] });
  } catch (e) { next(e); }
});

export { router as communicationRouter };
