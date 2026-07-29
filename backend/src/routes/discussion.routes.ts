import { Router } from 'express';
import { DiscussionService } from '../services/discussion.service';
import { adminOrJwtAuth } from '../middleware/adminKey';

const router = Router();

router.post('/', adminOrJwtAuth, async (req: any, res, next) => {
  try {
    const disc = await DiscussionService.create(req.user!.id, req.body);
    res.status(201).json({ success: true, data: disc });
  } catch (e) { next(e); }
});

router.get('/', adminOrJwtAuth, async (req: any, res, next) => {
  try {
    const discs = await DiscussionService.list(req.query as any);
    res.json({ success: true, data: discs });
  } catch (e) { next(e); }
});

router.get('/:id', adminOrJwtAuth, async (req: any, res, next) => {
  try {
    const disc = await DiscussionService.getById(req.params.id);
    res.json({ success: true, data: disc });
  } catch (e) { next(e); }
});

router.post('/:id/replies', adminOrJwtAuth, async (req: any, res, next) => {
  try {
    const reply = await DiscussionService.addReply(req.user!.id, req.params.id, req.body.content, req.body.parentId);
    res.status(201).json({ success: true, data: reply });
  } catch (e) { next(e); }
});

router.post('/replies/:id/upvote', adminOrJwtAuth, async (req: any, res, next) => {
  try {
    const result = await DiscussionService.upvoteReply(req.params.id);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});
router.post('/:id/pin', adminOrJwtAuth, async (req: any, res, next) => {
  try {
    const result = await DiscussionService.togglePin(req.params.id);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

export { router as discussionRouter };
