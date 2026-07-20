import { Router } from 'express';
import { DiscussionService } from '../services/discussion.service';
import { authenticate, AuthRequest } from '../middleware/auth';

const router = Router();

/**
 * @swagger
 * tags:
 *   name: Discussions
 *   description: Community forums and discussions
 */

/**
 * @swagger
 * /api/v1/discussions:
 *   post:
 *     summary: Create a new discussion
 *     tags: [Discussions]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [title, content, tags]
 *             properties:
 *               title:
 *                 type: string
 *               content:
 *                 type: string
 *               tags:
 *                 type: array
 *                 items:
 *                   type: string
 *     responses:
 *       201:
 *         description: Discussion created
 */
router.post('/', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const disc = await DiscussionService.create(req.user!.id, req.body);
    res.status(201).json({ success: true, data: disc });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/discussions:
 *   get:
 *     summary: List all discussions
 *     tags: [Discussions]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: tags
 *         schema:
 *           type: string
 *       - in: query
 *         name: sortBy
 *         schema:
 *           type: string
 *           enum: [recent, popular]
 *     responses:
 *       200:
 *         description: List of discussions
 */
router.get('/', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const discs = await DiscussionService.list(req.query as any);
    res.json({ success: true, data: discs });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/discussions/{id}:
 *   get:
 *     summary: Get discussion by ID
 *     tags: [Discussions]
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
 *         description: Discussion details
 */
router.get('/:id', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const disc = await DiscussionService.getById(req.params.id);
    res.json({ success: true, data: disc });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/discussions/{id}/replies:
 *   post:
 *     summary: Add a reply to a discussion
 *     tags: [Discussions]
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
 *               parentId:
 *                 type: string
 *     responses:
 *       201:
 *         description: Reply added
 */
router.post('/:id/replies', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const reply = await DiscussionService.addReply(req.user!.id, req.params.id, req.body.content, req.body.parentId);
    res.status(201).json({ success: true, data: reply });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/discussions/replies/{id}/upvote:
 *   post:
 *     summary: Upvote a reply
 *     tags: [Discussions]
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
 *         description: Reply upvoted
 */
router.post('/replies/:id/upvote', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const result = await DiscussionService.upvoteReply(req.params.id);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

export { router as discussionRouter };
