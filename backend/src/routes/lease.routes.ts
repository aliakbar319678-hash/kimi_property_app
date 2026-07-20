import { Router } from 'express';
import { LeaseService } from '../services/lease.service';
import { authenticate, AuthRequest, requireRole } from '../middleware/auth';
import { validate, schemas } from '../utils/validation';

const router = Router();

/**
 * @swagger
 * tags:
 *   name: Leases
 *   description: Lease management endpoints
 */

/**
 * @swagger
 * /api/v1/leases:
 *   post:
 *     summary: Create a new lease
 *     tags: [Leases]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [propertyId, unitId, tenantId, startDate, endDate, rentAmount, securityDeposit]
 *             properties:
 *               propertyId:
 *                 type: string
 *               unitId:
 *                 type: string
 *               tenantId:
 *                 type: string
 *               startDate:
 *                 type: string
 *                 format: date
 *               endDate:
 *                 type: string
 *                 format: date
 *               rentAmount:
 *                 type: number
 *               securityDeposit:
 *                 type: number
 *     responses:
 *       201:
 *         description: Lease created successfully
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
router.post('/', authenticate, requireRole('landlord', 'property_manager'), validate(schemas.leaseCreate), async (req: AuthRequest, res, next) => {
  try {
    const lease = await LeaseService.create(req.body, req.user!.id);
    res.status(201).json({ success: true, data: lease });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/leases/dashboard:
 *   get:
 *     summary: Get leases dashboard
 *     tags: [Leases]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Dashboard statistics and active leases
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
 */
router.get('/dashboard', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const leases = await LeaseService.getDashboard(req.user!.id, req.user!.activeRole!);
    res.json({ success: true, data: leases });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/leases/expiring-soon:
 *   get:
 *     summary: Get leases expiring soon
 *     tags: [Leases]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of leases expiring in the next 30/60 days
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
 */
router.get('/expiring-soon', authenticate, requireRole('landlord', 'property_manager'), async (req: AuthRequest, res, next) => {
  try {
    const leases = await LeaseService.getExpiringSoon(req.user!.id);
    res.json({ success: true, data: leases });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/leases/{id}/renew:
 *   post:
 *     summary: Renew a lease
 *     tags: [Leases]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Lease ID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [newEndDate]
 *             properties:
 *               newEndDate:
 *                 type: string
 *                 format: date
 *     responses:
 *       200:
 *         description: Lease renewed successfully
 */
router.post('/:id/renew', authenticate, requireRole('landlord'), async (req: AuthRequest, res, next) => {
  try {
    const lease = await LeaseService.renewLease(req.params.id, req.user!.id, req.body.newEndDate);
    res.json({ success: true, data: lease });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/leases/{id}/status:
 *   put:
 *     summary: Update lease status
 *     tags: [Leases]
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
 *             required: [status]
 *             properties:
 *               status:
 *                 type: string
 *                 enum: [draft, active, expiring, terminated, renewed]
 *     responses:
 *       200:
 *         description: Lease status updated
 */
router.put('/:id/status', authenticate, requireRole('landlord'), async (req: AuthRequest, res, next) => {
  try {
    const { id } = req.params;
    const { status } = req.body;
    const lease = await LeaseService.updateStatus(id, status, req.user!.id);
    res.json({ success: true, data: lease });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/leases:
 *   get:
 *     summary: Get all leases for the current user
 *     tags: [Leases]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: status
 *         schema:
 *           type: string
 *           enum: [draft, active, expiring, terminated, renewed]
 *     responses:
 *       200:
 *         description: List of leases
 */
router.get('/', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const userId = req.user!.id;
    const role = req.user!.activeRole || req.user!.roles[0];
    const leases = await LeaseService.getDashboard(userId, role);
    res.json({ success: true, data: leases });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/leases/{id}:
 *   get:
 *     summary: Get a lease by ID
 *     tags: [Leases]
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
 *         description: Lease detail
 *       404:
 *         description: Not found
 */
router.get('/:id', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const lease = await LeaseService.getById(req.params.id);
    res.json({ success: true, data: lease });
  } catch (e) { next(e); }
});

export { router as leaseRouter };
