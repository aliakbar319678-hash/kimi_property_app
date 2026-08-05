import { Router } from 'express';
import { TicketService } from '../services/ticket.service';
import { NotificationService } from '../services/notification.service';
import { AuditService } from '../services/audit.service';
import { authenticate, AuthRequest, requireRole } from '../middleware/auth';
import { requirePermission, requireStaffOrAdmin } from '../middleware/rolePermission';

const router = Router();

/**
 * GET /api/v1/tickets/stats  (admin only)
 */
router.get(
  '/stats',
  authenticate,
  requireRole('admin', 'super_admin'),
  async (req: AuthRequest, res, next) => {
    try {
      const stats = await TicketService.getStats();
      res.json({ success: true, data: stats });
    } catch (e) { next(e); }
  }
);

/**
 * POST /api/v1/tickets  (any authenticated user)
 */
router.post(
  '/',
  authenticate,
  async (req: AuthRequest, res, next) => {
    try {
      const { title, description, category, priority } = req.body;
      if (!title) return res.status(400).json({ success: false, error: 'title is required' });

      const ticket = await TicketService.create({
        title,
        description,
        category: category ? category.toLowerCase() : 'general',
        priority: priority ? priority.toLowerCase() : 'low',
        createdByUserId: req.user!.id,
      });
      await AuditService.logAction(req.user!.id, req.user!.roles?.[0], 'created_ticket', 'ticket', ticket.id, { title }, req);
      res.status(201).json({ success: true, data: ticket });
    } catch (e) { next(e); }
  }
);

/**
 * GET /api/v1/tickets  (role-scoped)
 */
router.get(
  '/',
  authenticate,
  async (req: AuthRequest, res, next) => {
    try {
      const result = await TicketService.list(req.user!.id, req.user!.roles, {
        status: req.query.status as string,
        category: req.query.category as string,
        page: parseInt(req.query.page as string) || 1,
        limit: parseInt(req.query.limit as string) || 20,
      });
      res.json({ success: true, ...result });
    } catch (e) { next(e); }
  }
);

/**
 * GET /api/v1/tickets/:id
 */
router.get(
  '/:id',
  authenticate,
  async (req: AuthRequest, res, next) => {
    try {
      const ticket = await TicketService.getById(req.params.id);
      res.json({ success: true, data: ticket });
    } catch (e) { next(e); }
  }
);

/**
 * PUT /api/v1/tickets/:id/assign  (staff / admin with permission)
 */
router.put(
  '/:id/assign',
  authenticate,
  requireStaffOrAdmin,
  requirePermission('can_resolve_tickets'),
  async (req: AuthRequest, res, next) => {
    try {
      const { staff_id } = req.body;
      if (!staff_id) return res.status(400).json({ success: false, error: 'staff_id is required' });
      const ticket = await TicketService.assign(req.params.id, staff_id);

      // Notify assigned staff
      await NotificationService.createTicketAssigned(staff_id, ticket.id, ticket.title);

      res.json({ success: true, data: ticket });
    } catch (e) { next(e); }
  }
);

/**
 * PUT /api/v1/tickets/:id/status
 */
router.put(
  '/:id/status',
  authenticate,
  requireStaffOrAdmin,
  async (req: AuthRequest, res, next) => {
    try {
      const { status, resolution_notes } = req.body;
      if (!status) return res.status(400).json({ success: false, error: 'status is required' });
      const ticket = await TicketService.updateStatus(req.params.id, status, resolution_notes);
      await AuditService.logAction(req.user!.id, req.user!.roles?.[0], 'updated_ticket_status', 'ticket', ticket.id, { status }, req);
      res.json({ success: true, data: ticket });
    } catch (e) { next(e); }
  }
);

/**
 * POST /api/v1/tickets/:id/comments
 */
router.post(
  '/:id/comments',
  authenticate,
  async (req: AuthRequest, res, next) => {
    try {
      const { message, is_internal } = req.body;
      if (!message) return res.status(400).json({ success: false, error: 'message is required' });

      const senderRole = req.user!.roles.includes('staff') || req.user!.roles.includes('admin')
        ? 'staff'
        : 'user';

      const comment = await TicketService.addComment({
        ticketId: req.params.id,
        senderId: req.user!.id,
        senderRole,
        message,
        isInternal: is_internal || false,
      });

      // Notify the ticket creator
      const ticket = await TicketService.getById(req.params.id);
      if (ticket.created_by && ticket.created_by !== req.user!.id) {
        await NotificationService.createNewComment(
          ticket.created_by,
          ticket.id,
          ticket.title
        );
      }

      res.status(201).json({ success: true, data: comment });
    } catch (e) { next(e); }
  }
);

export { router as ticketRouter };
