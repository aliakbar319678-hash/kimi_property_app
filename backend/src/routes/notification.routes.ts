import { Router } from 'express';
import { NotificationService } from '../services/notification.service';
import { authenticate, AuthRequest } from '../middleware/auth';
import { adminOrJwtAuth } from '../middleware/adminKey';

const router = Router();

router.get('/', adminOrJwtAuth, async (req: AuthRequest, res, next) => {
  try {
    const notifs = await NotificationService.getAll(req.user!.id, parseInt(req.query.page as string) || 1, parseInt(req.query.limit as string) || 20);
    res.json({ success: true, ...notifs });
  } catch (e) { next(e); }
});

// New admin endpoint to fetch all notifications across users
router.get('/all', adminOrJwtAuth, async (req: AuthRequest, res, next) => {
  try {
    const notifs = await NotificationService.getAllForAdmin(parseInt(req.query.page as string) || 1, parseInt(req.query.limit as string) || 20);
    res.json({ success: true, ...notifs });
  } catch (e) { next(e); }
});

router.get('/unread', adminOrJwtAuth, async (req: AuthRequest, res, next) => {
  try {
    const notifs = await NotificationService.getUnread(req.user!.id);
    res.json({ success: true, data: notifs });
  } catch (e) { next(e); }
});

router.get('/unread-count', adminOrJwtAuth, async (req: AuthRequest, res, next) => {
  try {
    const count = await NotificationService.getUnreadCount(req.user!.id);
    res.json({ success: true, data: count });
  } catch (e) { next(e); }
});

router.put('/:id/read', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const notif = await NotificationService.markRead(req.user!.id, req.params.id);
    res.json({ success: true, data: notif });
  } catch (e) { next(e); }
});

router.put('/read-all', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const result = await NotificationService.markAllRead(req.user!.id);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

export { router as notificationRouter };
