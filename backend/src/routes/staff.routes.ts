import { Router } from 'express';
import { StaffService } from '../services/staff.service';
import { NotificationService } from '../services/notification.service';
import { authenticate, AuthRequest, requireRole } from '../middleware/auth';
import { adminOrJwtAuth } from '../middleware/adminKey';
import { requirePermission } from '../middleware/rolePermission';

const router = Router();

/**
 * POST /api/v1/staff
 * Create a new staff member. Admin/super_admin only.
 */
router.post(
  '/',
  adminOrJwtAuth,
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
      await NotificationService.createStaffWelcome(staff.id, display_name, email, department, permissions);

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
  adminOrJwtAuth,
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
  adminOrJwtAuth,
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
  adminOrJwtAuth,
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
  adminOrJwtAuth,
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
  adminOrJwtAuth,
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
 * Staff self-service dashboard data with full profile and work history.
 */
router.get(
  '/me/dashboard',
  adminOrJwtAuth,
  requireRole('staff', 'admin', 'super_admin'),
  async (req: AuthRequest, res, next) => {
    try {
      const staffId = req.user!.id;
      const userRoles = req.user!.roles || [];
      const { query } = await import('../db');

      // --- 1. Fetch Staff Profile ---
      const profileResult = await query(
        `SELECT u.id, u.email, u.display_name, u.department, u.is_active, u.created_at,
                ur.permissions,
                up.legal_first_name, up.legal_last_name
         FROM users u
         LEFT JOIN user_roles ur ON ur.user_id = u.id AND ur.role = 'staff'
         LEFT JOIN user_profiles up ON up.user_id = u.id
         WHERE u.id = $1`,
        [staffId]
      );
      const profile = profileResult.rows[0] || {
        id: staffId,
        email: req.user!.email || '',
        display_name: 'Staff User',
        department: 'General',
        is_active: true,
        created_at: new Date().toISOString(),
        permissions: {},
      };

      const displayName = profile.display_name || 'Staff User';

      // --- 2. Ticket Stats (merged from tickets + support_tickets) ---
      const [openTickets, inProgressTickets, resolvedTickets, closedTickets] = await Promise.all([
        query(`SELECT
                (SELECT COUNT(*) FROM tickets WHERE assigned_staff_id = $1 AND status = 'open') +
                (SELECT COUNT(*) FROM support_tickets WHERE assigned_to LIKE $2 || '%' AND status = 'open') AS count`,
          [staffId, displayName]),
        query(`SELECT
                (SELECT COUNT(*) FROM tickets WHERE assigned_staff_id = $1 AND status = 'in_progress') +
                (SELECT COUNT(*) FROM support_tickets WHERE assigned_to LIKE $2 || '%' AND status = 'in_progress') AS count`,
          [staffId, displayName]),
        query(`SELECT
                (SELECT COUNT(*) FROM tickets WHERE assigned_staff_id = $1 AND status = 'resolved') +
                (SELECT COUNT(*) FROM support_tickets WHERE assigned_to LIKE $2 || '%' AND status = 'resolved') AS count`,
          [staffId, displayName]),
        query(`SELECT
                (SELECT COUNT(*) FROM tickets WHERE assigned_staff_id = $1 AND status = 'closed') +
                (SELECT COUNT(*) FROM support_tickets WHERE assigned_to LIKE $2 || '%' AND status = 'closed') AS count`,
          [staffId, displayName]),
      ]);

      // --- 3. Recent Comments (only from this staff's assigned tickets) ---
      const recentComments = await query(
        `SELECT tc.*, t.title AS ticket_title
         FROM ticket_comments tc
         JOIN tickets t ON t.id = tc.ticket_id
         WHERE t.assigned_staff_id = $1
         ORDER BY tc.created_at DESC LIMIT 5`,
        [staffId]
      );

      // --- 4. ALL tickets merged from both tables (current + history) ---
      const allTickets = await query(
        `SELECT t.id::text, t.title, t.description, t.status, t.priority, t.category, t.is_auto_generated, t.created_at, t.updated_at, u.display_name AS created_by_name
         FROM tickets t
         LEFT JOIN users u ON u.id = t.created_by
         WHERE t.assigned_staff_id = $1
         UNION ALL
         SELECT st.id::text, st.title, st.description, st.status, st.priority, COALESCE(st.reporter_role, 'Support') AS category, false AS is_auto_generated, st.created_at, st.updated_at, st.reporter AS created_by_name
         FROM support_tickets st
         WHERE st.assigned_to LIKE $2 || '%'
         ORDER BY updated_at DESC`,
        [staffId, displayName]
      );

      // Separate into active and completed
      const activeTickets = allTickets.rows.filter(
        (t: any) => ['open', 'in_progress', 'pending_response'].includes(t.status)
      );
      const completedTickets = allTickets.rows.filter(
        (t: any) => ['resolved', 'closed'].includes(t.status)
      );

      res.json({
        success: true,
        data: {
          profile: {
            id: profile.id,
            email: profile.email,
            display_name: profile.display_name,
            first_name: profile.legal_first_name || '',
            last_name: profile.legal_last_name || '',
            department: profile.department || 'General',
            is_active: profile.is_active,
            joined_at: profile.created_at,
            permissions: typeof profile.permissions === 'string' ? JSON.parse(profile.permissions) : (profile.permissions || {}),
            roles: userRoles,
          },
          stats: {
            open_tickets: parseInt(openTickets.rows[0].count, 10),
            in_progress_tickets: parseInt(inProgressTickets.rows[0].count, 10),
            resolved_tickets: parseInt(resolvedTickets.rows[0].count, 10),
            closed_tickets: parseInt(closedTickets.rows[0].count, 10),
            total_tickets: allTickets.rows.length,
          },
          my_tickets: activeTickets,
          completed_tickets: completedTickets,
          recent_comments: recentComments.rows,
        },
      });
    } catch (e) {
      next(e);
    }
  }
);

/**
 * GET /api/v1/staff/:id/dashboard-details
 * Detailed profile and work history for a specific staff member (used by admins in Staff Management).
 */
router.get(
  '/:id/dashboard-details',
  adminOrJwtAuth,
  requireRole('admin', 'super_admin'),
  async (req: AuthRequest, res, next) => {
    try {
      const staffId = req.params.id;
      const { query } = await import('../db');

      // --- 1. Fetch Staff Profile ---
      const profileResult = await query(
        `SELECT u.id, u.email, u.display_name, u.department, u.is_active, u.created_at,
                ur.permissions,
                up.legal_first_name, up.legal_last_name
         FROM users u
         LEFT JOIN user_roles ur ON ur.user_id = u.id AND ur.role = 'staff'
         LEFT JOIN user_profiles up ON up.user_id = u.id
         WHERE u.id = $1`,
        [staffId]
      );

      if (!profileResult.rows[0]) {
        return res.status(404).json({ success: false, error: 'Staff member not found' });
      }

      const profile = profileResult.rows[0];

      // --- 2. Ticket Stats ---
      const [openTickets, inProgressTickets, resolvedTickets, closedTickets] = await Promise.all([
        query(`SELECT 
                (SELECT COUNT(*) FROM tickets WHERE assigned_staff_id = $1 AND status = 'open') + 
                (SELECT COUNT(*) FROM support_tickets WHERE assigned_to LIKE $2 || '%' AND status = 'open') AS count`, [staffId, profile.display_name]),
        query(`SELECT 
                (SELECT COUNT(*) FROM tickets WHERE assigned_staff_id = $1 AND status = 'in_progress') + 
                (SELECT COUNT(*) FROM support_tickets WHERE assigned_to LIKE $2 || '%' AND status = 'in_progress') AS count`, [staffId, profile.display_name]),
        query(`SELECT 
                (SELECT COUNT(*) FROM tickets WHERE assigned_staff_id = $1 AND status = 'resolved') + 
                (SELECT COUNT(*) FROM support_tickets WHERE assigned_to LIKE $2 || '%' AND status = 'resolved') AS count`, [staffId, profile.display_name]),
        query(`SELECT 
                (SELECT COUNT(*) FROM tickets WHERE assigned_staff_id = $1 AND status = 'closed') + 
                (SELECT COUNT(*) FROM support_tickets WHERE assigned_to LIKE $2 || '%' AND status = 'closed') AS count`, [staffId, profile.display_name]),
      ]);

      // --- 3. ALL tickets (current + history) ---
      const allTickets = await query(
        `SELECT t.id::text, t.title, t.status, t.priority, t.category, t.created_at, t.updated_at, u.display_name AS created_by_name
         FROM tickets t
         LEFT JOIN users u ON u.id = t.created_by
         WHERE t.assigned_staff_id = $1
         UNION ALL
         SELECT st.id::text, st.title, st.status, st.priority, COALESCE(st.reporter_role, 'Support') AS category, st.created_at, st.updated_at, st.reporter AS created_by_name
         FROM support_tickets st
         WHERE st.assigned_to LIKE $2 || '%'
         ORDER BY updated_at DESC`,
        [staffId, profile.display_name]
      );

      // Separate into active and completed
      const activeTickets = allTickets.rows.filter(
        (t: any) => ['open', 'in_progress', 'pending_response'].includes(t.status)
      );
      const completedTickets = allTickets.rows.filter(
        (t: any) => ['resolved', 'closed'].includes(t.status)
      );

      res.json({
        success: true,
        data: {
          profile: {
            id: profile.id,
            email: profile.email,
            display_name: profile.display_name,
            first_name: profile.legal_first_name || '',
            last_name: profile.legal_last_name || '',
            department: profile.department || 'General',
            is_active: profile.is_active,
            joined_at: profile.created_at,
            permissions: typeof profile.permissions === 'string' ? JSON.parse(profile.permissions) : (profile.permissions || {}),
          },
          stats: {
            open_tickets: parseInt(openTickets.rows[0].count, 10),
            in_progress_tickets: parseInt(inProgressTickets.rows[0].count, 10),
            resolved_tickets: parseInt(resolvedTickets.rows[0].count, 10),
            closed_tickets: parseInt(closedTickets.rows[0].count, 10),
            total_tickets: allTickets.rows.length,
          },
          active_tickets: activeTickets,
          completed_tickets: completedTickets,
        },
      });
    } catch (e) {
      next(e);
    }
  }
);

export { router as staffRouter };
