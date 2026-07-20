import { Router } from 'express';
import { ChatService } from '../services/chat.service';
import { authenticate, AuthRequest } from '../middleware/auth';

const router = Router();

/**
 * @swagger
 * tags:
 *   name: Chat
 *   description: Real-time messaging and chat rooms
 */

/**
 * @swagger
 * /api/v1/chat/rooms:
 *   post:
 *     summary: Create a chat room
 *     tags: [Chat]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [name, participants, contextType, contextId]
 *             properties:
 *               name:
 *                 type: string
 *               participants:
 *                 type: array
 *                 items:
 *                   type: string
 *               contextType:
 *                 type: string
 *               contextId:
 *                 type: string
 *     responses:
 *       201:
 *         description: Chat room created
 */
router.post('/rooms', authenticate, async (req: AuthRequest, res, next) => {
  try {
    // Normalize body — frontend sends { name, participants: [userId,...], contextType, contextId }
    // ChatService expects { type, title, entityId, participants: [{userId, role, ...}] }
    // DB CHECK: role IN ('landlord','vendor','tenant','admin','system')
    const body = req.body;
    const creatorId = req.user!.id;
    const creatorRole = req.user!.activeRole || req.user!.roles[0] || 'admin';

    // Map a role string to valid DB enum
    const normalizeRole = (r?: string): string => {
      const valid = ['landlord', 'vendor', 'tenant', 'admin', 'system'];
      return valid.includes(r || '') ? r! : 'tenant';
    };

    let participants: any[] = Array.isArray(body.participants)
      ? body.participants.map((p: any) =>
          typeof p === 'string'
            ? { userId: p, role: 'tenant', canViewBids: false, canViewCosts: false }
            : { userId: p.userId || p.id, role: normalizeRole(p.role), canViewBids: p.canViewBids || false, canViewCosts: p.canViewCosts || false }
        )
      : [];

    // Always include creator as admin participant if not already present
    const creatorAlreadyIncluded = participants.some((p: any) => p.userId === creatorId);
    if (!creatorAlreadyIncluded) {
      participants = [{ userId: creatorId, role: normalizeRole(creatorRole), canViewBids: true, canViewCosts: true }, ...participants];
    }

    // DB CHECK: type IN ('direct','job','group','support')
    const normalizeType = (t?: string): string => {
      const valid = ['direct', 'job', 'group', 'support'];
      return valid.includes(t || '') ? t! : 'group';
    };

    const serviceData = {
      type: normalizeType(body.contextType || body.type),
      title: body.name || body.title || null,
      entityId: body.contextId || body.entityId || null,
      participants,
    };
    const room = await ChatService.createRoom(serviceData);
    res.status(201).json({ success: true, data: room });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/chat/rooms:
 *   get:
 *     summary: Get all chat rooms for user
 *     tags: [Chat]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of chat rooms
 */
router.get('/rooms', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const rooms = await ChatService.getRooms(req.user!.id);
    res.json({ success: true, data: rooms });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/chat/rooms/{id}/messages:
 *   get:
 *     summary: Get messages in a room
 *     tags: [Chat]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
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
 *         description: List of messages
 */
router.get('/rooms/:id/messages', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const messages = await ChatService.getMessages(req.params.id, req.user!.id, parseInt(req.query.page as string) || 1, parseInt(req.query.limit as string) || 50);
    res.json({ success: true, data: messages });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/chat/rooms/{id}/messages:
 *   post:
 *     summary: Send a message to a room
 *     tags: [Chat]
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
 *             required: [content]
 *             properties:
 *               content:
 *                 type: string
 *               attachments:
 *                 type: array
 *                 items:
 *                   type: object
 *     responses:
 *       201:
 *         description: Message sent
 */
router.post('/rooms/:id/messages', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const msg = await ChatService.sendMessage(req.params.id, req.user!.id, req.body.content, req.body.attachments);
    res.status(201).json({ success: true, data: msg });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/chat/rooms/{id}/read:
 *   put:
 *     summary: Mark messages as read
 *     tags: [Chat]
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
 *         description: Messages marked as read
 */
router.put('/rooms/:id/read', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const result = await ChatService.markRead(req.params.id, req.user!.id);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

export { router as chatRouter };
