import { Router } from 'express';
import { UserService } from '../services/user.service';
import { authenticate, AuthRequest, requireRole } from '../middleware/auth';
import { validate, schemas } from '../utils/validation';
import { query } from '../db';

const router = Router();

/**
 * @swagger
 * tags:
 *   name: Users
 *   description: User profile and role management
 */

/**
 * @swagger
 * /api/v1/users/profile:
 *   get:
 *     summary: Get current authenticated user profile
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: User profile data
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
 */
/**
 * @swagger
 * /api/v1/users/tenants:
 *   get:
 *     summary: Get all tenants (for landlord selection)
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 */
router.get('/tenants', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const tenants = await query(
      `SELECT u.id, u.first_name, u.last_name, u.email 
       FROM users u 
       JOIN user_roles ur ON u.id = ur.user_id 
       WHERE ur.role = 'tenant' AND u.is_active = true`
    );
    // map to match what the frontend expects
    const formatted = tenants.rows.map(t => ({
      tenant: {
        id: t.id,
        first_name: t.first_name,
        last_name: t.last_name,
        email: t.email
      },
      status: 'active'
    }));
    res.json({ success: true, data: formatted });
  } catch (e) { next(e); }
});

router.get('/profile', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const userRes = await query(
      `SELECT u.id, u.email, u.phone, u.legal_first_name, u.legal_last_name,
              u.display_name, u.avatar_url, u.kyc_status, u.email_verified,
              u.phone_verified, u.is_active, u.created_at, u.updated_at,
              up.date_of_birth, up.current_address, up.emergency_contact,
              up.employment_data, up.preferences, up.onboarding_step,
              up.onboarding_completed
       FROM users u
       LEFT JOIN user_profiles up ON u.id = up.user_id
       WHERE u.id = $1`,
      [req.user!.id]
    );
    if (userRes.rows.length === 0) {
      return res.status(404).json({ success: false, error: 'User not found' });
    }
    const rolesRes = await query('SELECT role FROM user_roles WHERE user_id = $1', [req.user!.id]);
    res.json({
      success: true,
      data: {
        ...userRes.rows[0],
        roles: rolesRes.rows.map(r => r.role)
      }
    });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/users/me/profile:
 *   put:
 *     summary: Update current user profile
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               firstName:
 *                 type: string
 *               lastName:
 *                 type: string
 *               phoneNumber:
 *                 type: string
 *     responses:
 *       200:
 *         description: Profile updated
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
 */
router.put('/me/profile', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const result = await UserService.updateProfile(req.user!.id, req.body);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/users/me/onboarding/{step}:
 *   post:
 *     summary: Complete onboarding step
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: step
 *         required: true
 *         schema:
 *           type: integer
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               data:
 *                 type: object
 *     responses:
 *       200:
 *         description: Onboarding step saved
 */
router.post('/me/onboarding/:step', authenticate, validate(schemas.onboardingStep), async (req: AuthRequest, res, next) => {
  try {
    const step = parseInt(req.params.step, 10);
    const result = await UserService.updateOnboarding(req.user!.id, step, req.body.data);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/users/me/documents:
 *   post:
 *     summary: Upload user document
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               docType:
 *                 type: string
 *               fileUrl:
 *                 type: string
 *     responses:
 *       200:
 *         description: Document uploaded
 */
router.post('/me/documents', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const { docType, fileUrl } = req.body;
    const result = await UserService.uploadDocument(req.user!.id, docType, fileUrl);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/users/{id}/roles:
 *   get:
 *     summary: Get user roles
 *     tags: [Users]
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
 *         description: List of roles
 */
router.get('/:id/roles', authenticate, requireRole('admin', 'super_admin'), async (req: AuthRequest, res, next) => {
  try {
    const roles = await UserService.getRoles(req.params.id);
    res.json({ success: true, data: roles });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/users/{id}/roles:
 *   post:
 *     summary: Add role to user
 *     tags: [Users]
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
 *             properties:
 *               role:
 *                 type: string
 *               entityId:
 *                 type: string
 *     responses:
 *       200:
 *         description: Role added
 */
router.post('/:id/roles', authenticate, requireRole('super_admin'), async (req: AuthRequest, res, next) => {
  try {
    const result = await UserService.addRole(req.params.id, req.body.role, req.body.entityId);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

export { router as userRouter };
