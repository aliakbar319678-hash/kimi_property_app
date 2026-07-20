import { Router } from 'express';
import { NotificationService } from '../services/notification.service';
import { authenticate, AuthRequest } from '../middleware/auth';

const router = Router();

/**
 * @swagger
 * tags:
 *   name: Notifications
 *   description: User notifications
 */

/**
 * @swagger
 * /api/v1/notifications:
 *   get:
 *     summary: Get all notifications
 *     tags: [Notifications]
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
 *         description: List of notifications
 */
router.get('/', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const notifs = await NotificationService.getAll(req.user!.id, parseInt(req.query.page as string) || 1, parseInt(req.query.limit as string) || 20);
    res.json({ success: true, ...notifs });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/notifications/unread:
 *   get:
 *     summary: Get unread notifications
 *     tags: [Notifications]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of unread notifications
 */
router.get('/unread', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const notifs = await NotificationService.getUnread(req.user!.id);
    res.json({ success: true, data: notifs });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/notifications/unread-count:
 *   get:
 *     summary: Get unread notifications count
 *     tags: [Notifications]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Unread count
 */
router.get('/unread-count', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const count = await NotificationService.getUnreadCount(req.user!.id);
    res.json({ success: true, data: count });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/notifications/{id}/read:
 *   put:
 *     summary: Mark notification as read
 *     tags: [Notifications]
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
 *         description: Notification marked as read
 */
router.put('/:id/read', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const notif = await NotificationService.markRead(req.user!.id, req.params.id);
    res.json({ success: true, data: notif });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/notifications/read-all:
 *   put:
 *     summary: Mark all notifications as read
 *     tags: [Notifications]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: All notifications marked as read
 */
router.put('/read-all', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const result = await NotificationService.markAllRead(req.user!.id);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

export { router as notificationRouter };
