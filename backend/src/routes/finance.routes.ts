import { Router } from 'express';
import { FinanceService } from '../services/finance.service';
import { authenticate, AuthRequest, requireRole } from '../middleware/auth';

const router = Router();

/**
 * @swagger
 * tags:
 *   name: Finance
 *   description: Finance and payment management endpoints
 */

/**
 * @swagger
 * /api/v1/finance/dashboard:
 *   get:
 *     summary: Get finance dashboard statistics
 *     tags: [Finance]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: period
 *         schema:
 *           type: string
 *           enum: [daily, weekly, monthly, yearly]
 *         description: Time period for statistics
 *     responses:
 *       200:
 *         description: Finance statistics
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
router.get('/dashboard', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const stats = await FinanceService.getDashboardStats(req.user!.id, req.user!.activeRole!, req.query.period as string);
    res.json({ success: true, data: stats });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/finance/payments/initiate:
 *   post:
 *     summary: Initiate a rent or fee payment
 *     tags: [Finance]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [leaseId, amount, paymentMethod]
 *             properties:
 *               leaseId:
 *                 type: string
 *               amount:
 *                 type: number
 *               paymentMethod:
 *                 type: string
 *                 example: "card"
 *     responses:
 *       201:
 *         description: Payment initiated successfully
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
 *                     paymentIntentId:
 *                       type: string
 *                     clientSecret:
 *                       type: string
 */
router.post('/payments/initiate', authenticate, requireRole('tenant'), async (req: AuthRequest, res, next) => {
  try {
    const payment = await FinanceService.initiatePayment(req.body.leaseId, req.user!.id, req.body.amount, req.body.paymentMethod);
    res.status(201).json({ success: true, data: payment });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/finance/vendor/earnings:
 *   get:
 *     summary: Get vendor earnings and transaction history
 *     tags: [Finance]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Vendor earnings data
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
 *                     totalEarnings:
 *                       type: number
 *                     pendingPayments:
 *                       type: number
 *                     history:
 *                       type: array
 *                       items:
 *                         type: object
 */
router.get('/vendor/earnings', authenticate, requireRole('vendor'), async (req: AuthRequest, res, next) => {
  try {
    const earnings = await FinanceService.getVendorEarnings(req.user!.id);
    res.json({ success: true, data: earnings });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/finance/invoices:
 *   post:
 *     summary: Generate a vendor invoice for a work order
 *     tags: [Finance]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [workOrderId, items]
 *             properties:
 *               workOrderId:
 *                 type: string
 *               items:
 *                 type: array
 *                 items:
 *                   type: object
 *                   properties:
 *                     description:
 *                       type: string
 *                     amount:
 *                       type: number
 *     responses:
 *       201:
 *         description: Invoice generated
 */
router.post('/invoices', authenticate, requireRole('vendor'), async (req: AuthRequest, res, next) => {
  try {
    const workOrderId = req.body.workOrderId ?? req.body.work_order_id;
    const dueDate = req.body.dueDate ?? req.body.due_date;
    const invoice = await FinanceService.generateInvoice(req.user!.id, workOrderId, req.body.items, dueDate);
    res.status(201).json({ success: true, data: invoice });
  } catch (e) { next(e); }
});

router.get('/payout-account', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const account = await FinanceService.getPayoutAccount(req.user!.id);
    res.json({ success: true, data: account });
  } catch (e) { next(e); }
});

router.post('/payout-account', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const { bankName, accountHolder, ibanAccountNo } = req.body;
    const account = await FinanceService.upsertPayoutAccount(req.user!.id, { bankName, accountHolder, ibanAccountNo });
    res.json({ success: true, data: account });
  } catch (e) { next(e); }
});

router.get('/invoices', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const data = await FinanceService.getLandlordInvoices(req.user!.id);
    res.json({ success: true, data });
  } catch (e) { next(e); }
});

router.post('/invoices/record-manual', authenticate, async (req: AuthRequest, res, next) => {
  try {
    console.log('[FINANCE] Record manual payment payload:', req.body);
    const payment = await FinanceService.recordManualPayment(req.user!.id, req.body);
    res.status(201).json({ success: true, data: payment });
  } catch (e: any) { 
    console.error('[FINANCE] Error recording manual payment:', e.message || e);
    if (e.statusCode) {
      res.status(e.statusCode).json({ success: false, error: e.message });
    } else {
      res.status(400).json({ success: false, error: e.message || 'Failed to record payment' });
    }
  }
});

export { router as financeRouter };
