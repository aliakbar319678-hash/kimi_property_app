import { Router } from 'express';
import { AuthService } from '../services/auth.service';
import { validate, schemas } from '../utils/validation';
import { authenticate, AuthRequest } from '../middleware/auth';

const router = Router();

router.post('/register', validate(schemas.register), async (req, res, next) => {
  const { email, password, role, display_name } = req.body;
  try {
    const user = await AuthService.register(req.body);
    res.status(201).json({ success: true, data: user });
  } catch (e) { next(e); }
});

router.post('/login', validate(schemas.login), async (req, res, next) => {
  try {
    const result = await AuthService.login(req.body.email, req.body.password);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

router.post('/refresh', async (req, res, next) => {
  try {
    const result = await AuthService.refresh(req.body.refreshToken);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

router.get('/me', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const user = await AuthService.me(req.user!.id);
    res.json({ success: true, data: user });
  } catch (e) { next(e); }
});

router.post('/verify-otp', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const result = await AuthService.verifyOtp(req.user!.id, req.body.code);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

router.post('/resend-otp', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const result = await AuthService.resendOtp(req.user!.id);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

export { router as authRouter };
