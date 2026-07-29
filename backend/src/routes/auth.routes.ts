import { Router } from 'express';
import { AuthService } from '../services/auth.service';
import { validate, schemas } from '../utils/validation';
import { authenticate, AuthRequest } from '../middleware/auth';
import { AppError } from '../middleware/errorHandler';

const router = Router();

router.post('/register', validate(schemas.register), async (req, res, next) => {
  try {
    const user = await AuthService.register(req.body);
    res.status(201).json({ success: true, data: user });
  } catch (e) { next(e); }
});

router.post('/login', validate(schemas.login), async (req, res, next) => {
  try {
    const result = await AuthService.login(
      req.body.email, 
      req.body.password,
      req.body.username,
      req.body.full_name,
      req.body.phone
    );
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

router.post('/forgot-password', async (req, res, next) => {
  try {
    const { email } = req.body;
    if (!email) throw new AppError('Email is required', 400);
    const result = await AuthService.forgotPassword(email);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

router.post('/verify-otp', async (req, res, next) => {
  try {
    const { email, otp } = req.body;
    if (!email || !otp) throw new AppError('Email and OTP are required', 400);
    const result = await AuthService.verifyOtp(email, otp);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

router.post('/reset-password', async (req, res, next) => {
  try {
    const { resetToken, newPassword } = req.body;
    if (!resetToken || !newPassword) throw new AppError('Token and new password are required', 400);
    const result = await AuthService.resetPassword(resetToken, newPassword);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

export { router as authRouter };
