import { Router } from 'express';
import { AuthService } from '../services/auth.service';
import { validate, schemas } from '../utils/validation';
import { authenticate, AuthRequest } from '../middleware/auth';

const router = Router();

/**
 * @swagger
 * tags:
 *   name: Auth
 *   description: Authentication endpoints
 */

/**
 * @swagger
 * /api/v1/auth/register:
 *   post:
 *     summary: Register a new user
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [email, password, role]
 *             properties:
 *               email:
 *                 type: string
 *                 example: user@example.com
 *               password:
 *                 type: string
 *                 example: StrongPass123!
 *               phone:
 *                 type: string
 *                 example: "+1234567890"
 *               role:
 *                 type: string
 *                 enum: [tenant, landlord, vendor]
 *                 example: tenant
 *               regionCode:
 *                 type: string
 *                 example: "US"
 *     responses:
 *       201:
 *         description: Successfully registered
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   type: object
 *                   properties:
 *                     id:
 *                       type: string
 *                       example: "123e4567-e89b-12d3-a456-426614174000"
 *                     email:
 *                       type: string
 *                       example: user@example.com
 *                     roles:
 *                       type: array
 *                       items:
 *                         type: string
 *                       example: ["tenant"]
 */
router.post('/register', validate(schemas.register), async (req, res, next) => {
  try {
    const user = await AuthService.register(req.body);
    res.status(201).json({ success: true, data: user });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/auth/login:
 *   post:
 *     summary: Login a user
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [email, password]
 *             properties:
 *               email:
 *                 type: string
 *                 example: landlord@example.com
 *               password:
 *                 type: string
 *                 example: Admin123!
 *     responses:
 *       200:
 *         description: Successfully logged in
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   type: object
 *                   properties:
 *                     accessToken:
 *                       type: string
 *                       example: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
 *                     refreshToken:
 *                       type: string
 *                       example: "def502005a3971936c..."
 *                     user:
 *                       type: object
 *                       properties:
 *                         id:
 *                           type: string
 *                           example: "uuid"
 *                         email:
 *                           type: string
 *                           example: landlord@example.com
 *                         roles:
 *                           type: array
 *                           items:
 *                             type: string
 *                           example: ["landlord"]
 */
router.post('/login', validate(schemas.login), async (req, res, next) => {
  try {
    const result = await AuthService.login(req.body.email, req.body.password);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/auth/refresh:
 *   post:
 *     summary: Refresh access token
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [refreshToken]
 *             properties:
 *               refreshToken:
 *                 type: string
 *                 example: "your-refresh-token-here"
 *     responses:
 *       200:
 *         description: New tokens generated
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   type: object
 *                   properties:
 *                     accessToken:
 *                       type: string
 *                     refreshToken:
 *                       type: string
 */
router.post('/refresh', async (req, res, next) => {
  try {
    const result = await AuthService.refresh(req.body.refreshToken);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/auth/switch-role:
 *   post:
 *     summary: Switch active role context
 *     tags: [Auth]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [role]
 *             properties:
 *               role:
 *                 type: string
 *                 example: "landlord"
 *     responses:
 *       200:
 *         description: Role switched successfully
 */
router.post('/switch-role', authenticate, async (req: AuthRequest, res, next) => {
  try {
    if (!req.body.role) return res.status(400).json({ error: 'role is required' });
    const result = await AuthService.switchRole(req.user!.id, req.body.role);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/auth/me:
 *   get:
 *     summary: Get current authenticated user details
 *     tags: [Auth]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Current user details
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   type: object
 *                   properties:
 *                     id:
 *                       type: string
 *                       example: "uuid"
 *                     email:
 *                       type: string
 *                       example: admin@propadmin.io
 *                     firstName:
 *                       type: string
 *                       example: Admin
 *                     lastName:
 *                       type: string
 *                       example: User
 *                     roles:
 *                       type: array
 *                       items:
 *                         type: string
 *                       example: ["super_admin"]
 *                     createdAt:
 *                       type: string
 *                       format: date-time
 */
router.get('/me', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const user = await AuthService.me(req.user!.id);
    res.json({ success: true, data: user });
  } catch (e) { next(e); }
});
/**
 * @swagger
 * /api/v1/auth/verify-otp:
 *   post:
 *     summary: Verify OTP
 *     tags: [Auth]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: OTP verified
 */
router.post('/verify-otp', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const result = await AuthService.verifyOtp(req.user!.id, req.body.code);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/auth/resend-otp:
 *   post:
 *     summary: Resend OTP
 *     tags: [Auth]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: OTP resent
 */
router.post('/resend-otp', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const result = await AuthService.resendOtp(req.user!.id);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

export { router as authRouter };
