import { Router } from 'express';
import { MaintenanceService } from '../services/maintenance.service';
import { authenticate, AuthRequest, requireRole } from '../middleware/auth';
import { validate, schemas } from '../utils/validation';

const router = Router();

/**
 * @swagger
 * tags:
 *   name: Maintenance
 *   description: Maintenance work orders and bids
 */

/**
 * @swagger
 * /api/v1/maintenance/work-orders:
 *   post:
 *     summary: Create a new work order
 *     tags: [Maintenance]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [propertyId, title, description, category, priority]
 *             properties:
 *               propertyId:
 *                 type: string
 *               unitId:
 *                 type: string
 *               title:
 *                 type: string
 *               description:
 *                 type: string
 *               category:
 *                 type: string
 *                 example: "plumbing"
 *               priority:
 *                 type: string
 *                 example: "high"
 *     responses:
 *       201:
 *         description: Work order created
 */
router.post('/work-orders', authenticate, requireRole('landlord', 'property_manager'), validate(schemas.workOrderCreate), async (req: AuthRequest, res, next) => {
  try {
    const wo = await MaintenanceService.createWorkOrder(req.body, req.user!.id);
    res.status(201).json({ success: true, data: wo });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/maintenance/work-orders:
 *   get:
 *     summary: Get work orders
 *     tags: [Maintenance]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: status
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: List of work orders
 */
router.get('/work-orders', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const orders = await MaintenanceService.getWorkOrders(req.user!.id, req.user!.activeRole!, req.query);
    res.json({ success: true, data: orders });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/maintenance/work-orders/{id}:
 *   get:
 *     summary: Get work order by ID
 *     tags: [Maintenance]
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
 *         description: Work order details
 */
router.get('/work-orders/:id', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const order = await MaintenanceService.getById(req.params.id);
    res.json({ success: true, data: order });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/maintenance/work-orders/{id}/bids:
 *   post:
 *     summary: Submit a bid for a work order
 *     tags: [Maintenance]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [amount, estimatedDays, proposal]
 *             properties:
 *               amount:
 *                 type: number
 *               estimatedDays:
 *                 type: number
 *               proposal:
 *                 type: string
 *     responses:
 *       201:
 *         description: Bid submitted
 */
router.post('/work-orders/:id/bids', authenticate, requireRole('vendor'), validate(schemas.bidCreate), async (req: AuthRequest, res, next) => {
  try {
    const bid = await MaintenanceService.submitBid(req.params.id, req.user!.id, req.body);
    res.status(201).json({ success: true, data: bid });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/maintenance/bids/{id}/accept:
 *   post:
 *     summary: Accept a vendor bid
 *     tags: [Maintenance]
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
 *         description: Bid accepted
 */
router.post('/bids/:id/accept', authenticate, requireRole('landlord', 'property_manager'), async (req: AuthRequest, res, next) => {
  try {
    const result = await MaintenanceService.acceptBid(req.params.id, req.user!.id);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/maintenance/work-orders/{id}/status:
 *   put:
 *     summary: Update work order status
 *     tags: [Maintenance]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [status]
 *             properties:
 *               status:
 *                 type: string
 *                 enum: [open, assigned, in_progress, completed, cancelled]
 *     responses:
 *       200:
 *         description: Status updated
 */
router.put('/work-orders/:id/status', authenticate, requireRole('landlord', 'property_manager', 'vendor'), async (req: AuthRequest, res, next) => {
  try {
    const result = await MaintenanceService.updateStatus(req.params.id, req.body.status, req.user!.id);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/maintenance/vendor/jobs:
 *   get:
 *     summary: Get jobs assigned to vendor
 *     tags: [Maintenance]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: status
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: List of vendor jobs
 */
router.get('/vendor/jobs', authenticate, requireRole('vendor'), async (req: AuthRequest, res, next) => {
  try {
    const jobs = await MaintenanceService.getVendorJobs(req.user!.id, req.query.status as string);
    res.json({ success: true, data: jobs });
  } catch (e) { next(e); }
});

export { router as maintenanceRouter };
