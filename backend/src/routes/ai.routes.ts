import { Router } from 'express';
import { AIService } from '../services/ai.service';
import { authenticate, AuthRequest } from '../middleware/auth';

const router = Router();

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

export { router as aiRouter };
