import { Router } from 'express';
import { AIService } from '../services/ai.service';
import { authenticate, AuthRequest } from '../middleware/auth';

const router = Router();

/**
 * @swagger
 * tags:
 *   name: AI Assistant
 *   description: AI property management assistant
 */

/**
 * @swagger
 * /api/v1/ai/chat:
 *   post:
 *     summary: Chat with AI assistant
 *     tags: [AI Assistant]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [message]
 *             properties:
 *               message:
 *                 type: string
 *               propertyId:
 *                 type: string
 *               leaseId:
 *                 type: string
 *     responses:
 *       200:
 *         description: AI response
 */
router.post('/chat', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const result = await AIService.chat(req.body.message, {
      userId: req.user!.id,
      role: req.user!.activeRole!,
      propertyId: req.body.propertyId,
      leaseId: req.body.leaseId,
    });
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

router.post('/landlord-chat', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const result = await AIService.landlordChat(req.user!.id, req.body.message || req.body.prompt || '');
    res.status(200).json({ success: true, reply: result.reply });
  } catch (e) { next(e); }
});

export { router as aiRouter };
