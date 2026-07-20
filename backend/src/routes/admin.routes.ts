import { Router } from 'express';
import { AdminService } from '../services/admin.service';
import { authenticate, AuthRequest, requireRole } from '../middleware/auth';
import { validate, schemas } from '../utils/validation';

const router = Router();

/**
 * @swagger
 * tags:
 *   name: Admin
 *   description: System administration and moderation
 */

/**
 * @swagger
 * /api/v1/admin/dashboard:
 *   get:
 *     summary: Get admin dashboard statistics
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Dashboard stats
 */
router.get('/dashboard', authenticate, requireRole('admin', 'super_admin'), async (req: AuthRequest, res, next) => {
  try {
    const stats = await AdminService.getDashboardStats();
    res.json({ success: true, data: stats });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/admin/audit-logs:
 *   get:
 *     summary: Get system audit logs
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: List of audit logs
 */
router.get('/audit-logs', authenticate, requireRole('admin', 'super_admin'), async (req: AuthRequest, res, next) => {
  try {
    const logs = await AdminService.getAuditLogs(req.query);
    res.json({ success: true, data: logs });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/admin/verification-queue:
 *   get:
 *     summary: Get user verification queue
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: status
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Verification queue
 */
router.get('/verification-queue', authenticate, requireRole('admin', 'super_admin'), async (req: AuthRequest, res, next) => {
  try {
    const queue = await AdminService.getVerificationQueue(req.query.status as string);
    res.json({ success: true, data: queue });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/admin/verification-queue/{id}/approve:
 *   post:
 *     summary: Approve a verification request
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               notes:
 *                 type: string
 *     responses:
 *       200:
 *         description: Approved successfully
 */
router.post('/verification-queue/:id/approve', authenticate, requireRole('admin', 'super_admin'), async (req: AuthRequest, res, next) => {
  try {
    const result = await AdminService.reviewVerification(req.params.id, req.user!.id, 'approved', req.body.notes);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/admin/verification-queue/{id}/reject:
 *   post:
 *     summary: Reject a verification request
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               notes:
 *                 type: string
 *     responses:
 *       200:
 *         description: Rejected successfully
 */
router.post('/verification-queue/:id/reject', authenticate, requireRole('admin', 'super_admin'), async (req: AuthRequest, res, next) => {
  try {
    const result = await AdminService.reviewVerification(req.params.id, req.user!.id, 'rejected', req.body.notes);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/admin/users/{id}/suspend:
 *   put:
 *     summary: Suspend a user
 *     tags: [Admin]
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
 *             properties:
 *               reason:
 *                 type: string
 *     responses:
 *       200:
 *         description: User suspended
 */
router.put('/users/:id/suspend', authenticate, requireRole('super_admin'), async (req: AuthRequest, res, next) => {
  try {
    const result = await AdminService.suspendUser(req.params.id, req.user!.id, req.body.reason);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/admin/system-health:
 *   get:
 *     summary: Get detailed system health metrics
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: System health details
 */
router.get('/system-health', authenticate, requireRole('admin', 'super_admin'), async (req: AuthRequest, res, next) => {
  try {
    const health = await AdminService.getSystemHealth();
    res.json({ success: true, data: health });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/admin/properties/{id}/reject:
 *   post:
 *     summary: Reject a property verification request
 *     tags: [Admin]
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
 *             required: [reason, deadline]
 *             properties:
 *               reason:
 *                 type: string
 *                 example: "Property images are blurry."
 *               deadline:
 *                 type: string
 *                 format: date-time
 *                 example: "2026-06-20T17:00:00Z"
 *     responses:
 *       200:
 *         description: Rejected successfully
 */
router.post('/properties/:id/reject', authenticate, requireRole('admin', 'super_admin'), validate(schemas.propertyReject), async (req: AuthRequest, res, next) => {
  try {
    const { reason, deadline } = req.body;
    const result = await AdminService.rejectProperty(req.params.id, req.user!.id, reason, new Date(deadline));
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/admin/users:
 *   get:
 *     summary: Get all users (Admin only)
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: role
 *         schema:
 *           type: string
 *         description: Filter by role
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: List of all users
 */
router.get('/users', authenticate, requireRole('admin', 'super_admin'), async (req: AuthRequest, res, next) => {
  try {
    const { role, page = 1, limit = 20, search } = req.query as any;
    const offset = (parseInt(page) - 1) * parseInt(limit);
    let sql = `SELECT u.id, u.email, u.display_name, u.phone, u.kyc_status, u.is_active, u.created_at,
                      array_agg(ur.role) as roles
               FROM users u
               LEFT JOIN user_roles ur ON ur.user_id = u.id`;
    const params: any[] = [];
    let idx = 1;
    const conditions: string[] = [];
    if (role) { conditions.push(`ur.role = $${idx++}`); params.push(role); }
    if (search) { conditions.push(`(u.email ILIKE $${idx} OR u.display_name ILIKE $${idx++})`); params.push(`%${search}%`); }
    if (conditions.length > 0) sql += ` WHERE ${conditions.join(' AND ')}`;
    sql += ` GROUP BY u.id ORDER BY u.created_at DESC LIMIT $${idx++} OFFSET $${idx++}`;
    params.push(parseInt(limit), offset);
    const { query: dbQuery } = require('../db');
    const res2 = await dbQuery(sql, params);
    res.json({ success: true, data: res2.rows, meta: { page: parseInt(page), limit: parseInt(limit) } });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/admin/users/{id}:
 *   get:
 *     summary: Get user by ID (Admin only)
 *     tags: [Admin]
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
 *         description: User detail
 *       404:
 *         description: User not found
 */
router.get('/users/:id', authenticate, requireRole('admin', 'super_admin'), async (req: AuthRequest, res, next) => {
  try {
    const { query: dbQuery } = require('../db');
    const userRes = await dbQuery(
      `SELECT u.*, array_agg(ur.role) as roles FROM users u
       LEFT JOIN user_roles ur ON ur.user_id = u.id
       WHERE u.id = $1 GROUP BY u.id`,
      [req.params.id]
    );
    if (userRes.rows.length === 0) { res.status(404).json({ success: false, message: 'User not found' }); return; }
    const user = { ...userRes.rows[0] };
    delete user.password_hash;
    res.json({ success: true, data: user });
  } catch (e) { next(e); }
});

export { router as adminRouter };
