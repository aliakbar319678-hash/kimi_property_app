import { Router } from 'express';
import { UserService } from '../services/user.service';
import { AuditService } from '../services/audit.service';
import { authenticate, AuthRequest, requireRole } from '../middleware/auth';
import { adminOrJwtAuth } from '../middleware/adminKey';
import { validate, schemas } from '../utils/validation';
import { query } from '../db';

const router = Router();

// ─── Admin: List all users ────────────────────────────────────────
router.get('/', adminOrJwtAuth, async (req: AuthRequest, res, next) => {
  try {
    const result = await query(`
      SELECT 
        u.id, u.email, u.phone, u.kyc_status, u.is_active, u.created_at, u.display_name,
        p.legal_first_name as first_name, p.legal_last_name as last_name, p.avatar_url,
        (SELECT string_agg(ur.role, ', ') FROM user_roles ur WHERE ur.user_id = u.id) as role
      FROM users u
      LEFT JOIN user_profiles p ON u.id = p.user_id
      ORDER BY u.created_at DESC
    `);
    res.json({ success: true, data: result.rows });
  } catch (e) { next(e); }
});

// ─── Admin: Get single user by ID ────────────────────────────────
router.get('/:id', adminOrJwtAuth, async (req: AuthRequest, res, next) => {
  try {
    const { id } = req.params;
    const userRes = await query(
      `SELECT u.id, u.email, u.phone, u.display_name, u.kyc_status, u.is_active, u.created_at,
              up.legal_first_name, up.legal_last_name, up.avatar_url, up.current_address,
              (SELECT string_agg(ur.role, ', ') FROM user_roles ur WHERE ur.user_id = u.id) as role
       FROM users u
       LEFT JOIN user_profiles up ON up.user_id = u.id
       WHERE u.id = $1`,
      [id]
    );
    if (userRes.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }
    const user = userRes.rows[0];
    // Map fields for frontend
    res.json({
      success: true,
      data: {
        id: user.id,
        display_name: user.display_name,
        first_name: user.legal_first_name || '',
        last_name: user.legal_last_name || '',
        email: user.email,
        phone: user.phone,
        role: user.role || 'tenant',
        kyc_status: user.kyc_status,
        is_active: user.is_active,
        avatar_url: user.avatar_url,
        address: user.current_address || '',
        created_at: user.created_at,
      }
    });
  } catch (e) { next(e); }
});

// ─── Admin: Update user ──────────────────────────────────────────
router.put('/:id', adminOrJwtAuth, async (req: AuthRequest, res, next) => {
  try {
    const { id } = req.params;
    const data = req.body;

    // Update users table fields
    const userUpdates: string[] = [];
    const userValues: any[] = [];
    let idx = 1;

    if (data.display_name !== undefined) { userUpdates.push(`display_name = $${idx++}`); userValues.push(data.display_name); }
    if (data.email !== undefined) { userUpdates.push(`email = $${idx++}`); userValues.push(data.email); }
    if (data.phone !== undefined) { userUpdates.push(`phone = $${idx++}`); userValues.push(data.phone); }
    if (data.kyc_status !== undefined) { userUpdates.push(`kyc_status = $${idx++}`); userValues.push(data.kyc_status); }
    if (data.is_active !== undefined) { userUpdates.push(`is_active = $${idx++}`); userValues.push(data.is_active); }
    
    if (data.password && data.password.trim() !== '') {
      userUpdates.push(`password_hash = $${idx++}`); 
      userValues.push(data.password); // In a real app, hash this using bcrypt
    }

    if (userUpdates.length > 0) {
      userValues.push(id);
      await query(`UPDATE users SET ${userUpdates.join(', ')}, updated_at = NOW() WHERE id = $${idx}`, userValues);
    }

    // Update role if provided
    if (data.role) {
      await query(`DELETE FROM user_roles WHERE user_id = $1`, [id]);
      await query(`INSERT INTO user_roles (user_id, role) VALUES ($1, $2)`, [id, data.role]);
    }

    // Update user_profiles table
    const profileUpdates: string[] = [];
    const profileValues: any[] = [];
    let pidx = 1;

    if (data.first_name !== undefined) { profileUpdates.push(`legal_first_name = $${pidx++}`); profileValues.push(data.first_name); }
    if (data.last_name !== undefined) { profileUpdates.push(`legal_last_name = $${pidx++}`); profileValues.push(data.last_name); }
    if (data.avatar_url !== undefined) { profileUpdates.push(`avatar_url = $${pidx++}`); profileValues.push(data.avatar_url); }
    
    if (data.address !== undefined) { 
      profileUpdates.push(`current_address = $${pidx++}`); 
      let addressJson = data.address;
      if (typeof data.address === 'string') {
        try {
          addressJson = JSON.parse(data.address);
        } catch(e) {
          addressJson = { formatted: data.address };
        }
      }
      profileValues.push(addressJson); 
    }

    if (profileUpdates.length > 0) {
      profileValues.push(id);
      // Ensure profile exists first, or just try to update
      const existingProfile = await query(`SELECT user_id FROM user_profiles WHERE user_id = $1`, [id]);
      if (existingProfile.rows.length === 0) {
         await query(`INSERT INTO user_profiles (user_id) VALUES ($1)`, [id]);
      }
      await query(`UPDATE user_profiles SET ${profileUpdates.join(', ')}, updated_at = NOW() WHERE user_id = $${pidx}`, profileValues);
    }

    res.json({ success: true, message: 'User updated successfully' });
  } catch (e) { next(e); }
});

// ─── Admin: Delete user ──────────────────────────────────────────
router.delete('/:id', adminOrJwtAuth, async (req: AuthRequest, res, next) => {
  try {
    const { id } = req.params;
    // Hard delete
    await query('DELETE FROM user_roles WHERE user_id = $1', [id]);
    await query('DELETE FROM user_profiles WHERE user_id = $1', [id]);
    await query('DELETE FROM users WHERE id = $1', [id]);
    res.json({ success: true, message: 'User permanently deleted' });
  } catch (e) { next(e); }
});

// ─── Existing routes ─────────────────────────────────────────────

router.get('/me/history', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const limit = parseInt(req.query.limit as string) || 50;
    const offset = parseInt(req.query.offset as string) || 0;
    const history = await AuditService.getUserHistory(req.user!.id, limit, offset);
    res.json({ success: true, data: history });
  } catch (e) { next(e); }
});

router.get('/:id/history', authenticate, requireRole('admin', 'super_admin'), async (req: AuthRequest, res, next) => {
  try {
    const limit = parseInt(req.query.limit as string) || 50;
    const offset = parseInt(req.query.offset as string) || 0;
    const history = await AuditService.getUserHistory(req.params.id, limit, offset);
    res.json({ success: true, data: history });
  } catch (e) { next(e); }
});

router.put('/me/profile', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const result = await UserService.updateProfile(req.user!.id, req.body);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

router.post('/me/onboarding/:step', authenticate, validate(schemas.onboardingStep), async (req: AuthRequest, res, next) => {
  try {
    const step = parseInt(req.params.step, 10);
    const result = await UserService.updateOnboarding(req.user!.id, step, req.body.data);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

router.post('/me/documents', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const docType = req.body.docType || req.body.doc_type;
    const fileUrl = req.body.fileUrl || req.body.file_url;
    if (!docType || !fileUrl) {
      return res.status(400).json({ success: false, message: 'doc_type and file_url are required' });
    }
    const result = await UserService.uploadDocument(req.user!.id, docType, fileUrl);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

router.get('/:id/roles', authenticate, requireRole('admin', 'super_admin'), async (req: AuthRequest, res, next) => {
  try {
    const roles = await UserService.getRoles(req.params.id);
    res.json({ success: true, data: roles });
  } catch (e) { next(e); }
});

router.post('/:id/roles', authenticate, requireRole('super_admin'), async (req: AuthRequest, res, next) => {
  try {
    const result = await UserService.addRole(req.params.id, req.body.role, req.body.entityId);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

// Get all users (Admin)
router.get('/', adminOrJwtAuth, async (req: AuthRequest, res, next) => {
  try {
    const result = await query('SELECT id, email, display_name, phone, status, kyc_status, fraud_score, created_at FROM users ORDER BY created_at DESC');
    res.json({ success: true, data: result.rows });
  } catch (e) { next(e); }
});

// Create User (Admin)
router.post('/', adminOrJwtAuth, async (req: AuthRequest, res, next) => {
  try {
    const { display_name, email, phone, role, password } = req.body;
    // For simplicity in this demo, insert into users directly
    // Ideally we should hash the password
    const result = await query(
      `INSERT INTO users (email, display_name, phone, password_hash, is_active) 
       VALUES ($1, $2, $3, $4, true) RETURNING *`,
      [email, display_name, phone, password || 'default_hash']
    );
    if (role) {
      await query(
        `INSERT INTO user_roles (user_id, role) VALUES ($1, $2)`,
        [result.rows[0].id, role]
      );
    }
    res.status(201).json({ success: true, data: result.rows[0] });
  } catch (e) { next(e); }
});

export { router as userRouter };
