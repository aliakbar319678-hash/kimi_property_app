import { Router } from 'express';
import { StaffService } from '../services/staff.service';
import { NotificationService } from '../services/notification.service';
import { authenticate, AuthRequest, requireRole } from '../middleware/auth';
import { requirePermission } from '../middleware/rolePermission';

const router = Router();

/**
 * POST /api/v1/staff
 * Create a new staff member. Admin/super_admin only.
 */
router.post(
  '/',
  authenticate,
  requireRole('admin', 'super_admin'),
  async (req: AuthRequest, res, next) => {
    try {
      const {
        email,
        password,
        display_name,
        first_name,
        last_name,
        department,
        permissions,
      } = req.body;

      if (!email || !password || !display_name) {
        return res.status(400).json({
          success: false,
          error: 'email, password, and display_name are required',
        });
      }

      const staff = await StaffService.create({
        email,
        password,
        display_name,
        first_name,
        last_name,
        department,
        permissions,
        createdByUserId: req.user!.id,
      });

      // Send welcome notification
      await NotificationService.createStaffWelcome(staff.id, display_name);

      res.status(201).json({ success: true, data: staff });
    } catch (e) {
      next(e);
    }
  }
);

/**
 * GET /api/v1/staff
 * List all staff members (with open ticket count).
 */
router.get(
  '/',
  authenticate,
  requireRole('admin', 'super_admin'),
  async (req: AuthRequest, res, next) => {
    try {
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 20;
      const result = await StaffService.list(page, limit);
      res.json({ success: true, ...result });
    } catch (e) {
      next(e);
    }
  }
);

/**
 * GET /api/v1/staff/:id
 * Get a specific staff member.
 */
router.get(
  '/:id',
  authenticate,
  requireRole('admin', 'super_admin'),
  async (req: AuthRequest, res, next) => {
    try {
      const staff = await StaffService.getById(req.params.id);
      res.json({ success: true, data: staff });
    } catch (e) {
      next(e);
    }
  }
);

/**
 * PUT /api/v1/staff/:id
 * Update staff details and/or permissions.
 */
router.put(
  '/:id',
  authenticate,
  requireRole('admin', 'super_admin'),
  async (req: AuthRequest, res, next) => {
    try {
      const { display_name, department, permissions, is_active } = req.body;
      const updated = await StaffService.update(req.params.id, {
        display_name,
        department,
        permissions,
        is_active,
      });
      res.json({ success: true, data: updated });
    } catch (e) {
      next(e);
    }
  }
);

/**
 * DELETE /api/v1/staff/:id
 * Soft-delete (deactivate) a staff member.
 */
router.delete(
  '/:id',
  authenticate,
  requireRole('admin', 'super_admin'),
  async (req: AuthRequest, res, next) => {
    try {
      const result = await StaffService.deactivate(req.params.id);
      res.json({ success: true, data: result, message: 'Staff member deactivated' });
    } catch (e) {
      next(e);
    }
  }
);

/**
 * POST /api/v1/staff/:id/reactivate
 * Re-activate a deactivated staff member.
 */
router.post(
  '/:id/reactivate',
  authenticate,
  requireRole('admin', 'super_admin'),
  async (req: AuthRequest, res, next) => {
    try {
      const result = await StaffService.reactivate(req.params.id);
      res.json({ success: true, data: result, message: 'Staff member reactivated' });
    } catch (e) {
      next(e);
    }
  }
);

/**
 * GET /api/v1/staff/me/dashboard
 * Staff self-service dashboard data.
 */
router.get(
  '/me/dashboard',
  authenticate,
  requireRole('staff', 'admin', 'super_admin'),
  async (req: AuthRequest, res, next) => {
    try {
      const staffId = req.user!.id;
      const { query } = await import('../db');

      const [openTickets, inProgressTickets, recentComments] = await Promise.all([
        query(
          `SELECT COUNT(*) FROM tickets WHERE assigned_staff_id = $1 AND status = 'open'`,
          [staffId]
        ),
        query(
          `SELECT COUNT(*) FROM tickets WHERE assigned_staff_id = $1 AND status = 'in_progress'`,
          [staffId]
        ),
        query(
          `SELECT tc.*, t.title AS ticket_title
           FROM ticket_comments tc
           JOIN tickets t ON t.id = tc.ticket_id
           WHERE t.assigned_staff_id = $1
           ORDER BY tc.created_at DESC LIMIT 5`,
          [staffId]
        ),
      ]);

      const myTickets = await query(
        `SELECT t.*, u.display_name AS created_by_name
         FROM tickets t
         LEFT JOIN users u ON u.id = t.created_by
         WHERE t.assigned_staff_id = $1
         ORDER BY
           CASE t.priority WHEN 'urgent' THEN 1 WHEN 'high' THEN 2 WHEN 'medium' THEN 3 ELSE 4 END,
           t.updated_at DESC
         LIMIT 20`,
        [staffId]
      );

      res.json({
        success: true,
        data: {
          stats: {
            open_tickets: parseInt(openTickets.rows[0].count, 10),
            in_progress_tickets: parseInt(inProgressTickets.rows[0].count, 10),
          },
          recent_comments: recentComments.rows,
          my_tickets: myTickets.rows,
        },
      });
    } catch (e) {
      next(e);
    }
  }
);

export { router as staffRouter };
