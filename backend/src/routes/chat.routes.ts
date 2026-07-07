import { Router } from 'express';
import { ChatService } from '../services/chat.service';
import { authenticate, AuthRequest } from '../middleware/auth';

const router = Router();

router.post('/rooms', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const room = await ChatService.createRoom(req.body);
    res.status(201).json({ success: true, data: room });
  } catch (e) { next(e); }
});

router.get('/rooms', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const rooms = await ChatService.getRooms(req.user!.id);
    res.json({ success: true, data: rooms });
  } catch (e) { next(e); }
});

router.get('/rooms/:id/messages', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const messages = await ChatService.getMessages(req.params.id, req.user!.id, parseInt(req.query.page as string) || 1, parseInt(req.query.limit as string) || 50);
    res.json({ success: true, data: messages });
  } catch (e) { next(e); }
});

router.post('/rooms/:id/messages', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const msg = await ChatService.sendMessage(req.params.id, req.user!.id, req.body.content, req.body.attachments);
    res.status(201).json({ success: true, data: msg });
  } catch (e) { next(e); }
});

router.put('/rooms/:id/read', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const result = await ChatService.markRead(req.params.id, req.user!.id);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

export { router as chatRouter };
