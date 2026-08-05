import { Router } from 'express';
import { AdminService } from '../services/admin.service';
import { authenticate, AuthRequest, requireRole } from '../middleware/auth';
import { adminOrJwtAuth } from '../middleware/adminKey';
import { query } from '../db';

const router = Router();

router.get('/dashboard', adminOrJwtAuth, async (req: AuthRequest, res, next) => {
  try {
    const period = req.query.period as string | undefined;
    const stats = await AdminService.getDashboardStats(period);
    res.json({ success: true, data: stats });
  } catch (e) { next(e); }
});

router.get('/audit-logs', adminOrJwtAuth, async (req: AuthRequest, res, next) => {
  try {
    const logs = await AdminService.getAuditLogs(req.query);
    res.json({ success: true, data: logs });
  } catch (e) { next(e); }
});

router.get('/audit-stats', adminOrJwtAuth, async (req: AuthRequest, res, next) => {
  try {
    const stats = await AdminService.getAuditStats();
    res.json({ success: true, data: stats });
  } catch (e) { next(e); }
});

router.get('/verification-queue', adminOrJwtAuth, async (req: AuthRequest, res, next) => {
  try {
    const queue = await AdminService.getVerificationQueue(req.query.status as string);
    res.json({ success: true, data: queue });
  } catch (e) { next(e); }
});

router.post('/verification-queue/:id/approve', adminOrJwtAuth, async (req: AuthRequest, res, next) => {
  try {
    const result = await AdminService.reviewVerification(req.params.id, req.user!.id, 'approved', req.body.notes);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

router.post('/verification-queue/:id/reject', adminOrJwtAuth, async (req: AuthRequest, res, next) => {
  try {
    const result = await AdminService.reviewVerification(req.params.id, req.user!.id, 'rejected', req.body.notes);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

router.post('/properties/:id/approve', adminOrJwtAuth, async (req: AuthRequest, res, next) => {
  try {
    if (req.body.resubmit) {
      await query("UPDATE properties SET verification_status = 'pending', status = 'pending_verification' WHERE id = $1", [req.params.id]);
      res.json({ success: true, data: { status: 'pending' } });
    } else {
      await query("UPDATE properties SET verification_status = 'approved', status = 'active' WHERE id = $1", [req.params.id]);
      res.json({ success: true, data: { status: 'approved' } });
    }
  } catch (e) { next(e); }
});

router.post('/properties/:id/reject', adminOrJwtAuth, async (req: AuthRequest, res, next) => {
  try {
    const reason = req.body.notes || 'No reason provided';
    const entry = JSON.stringify([{ reason, rejected_at: new Date().toISOString() }]);
    await query(
      `UPDATE properties SET verification_status = 'rejected', status = 'inactive',
       rejection_history = COALESCE(rejection_history, '[]'::jsonb) || $1::jsonb
       WHERE id = $2`,
      [entry, req.params.id]
    );
    res.json({ success: true, data: { status: 'rejected' } });
  } catch (e) { next(e); }
});

router.put('/users/:id/suspend', adminOrJwtAuth, async (req: AuthRequest, res, next) => {
  try {
    const result = await AdminService.suspendUser(req.params.id, req.user!.id, req.body.reason);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

router.get('/system-health', adminOrJwtAuth, async (req: AuthRequest, res, next) => {
  try {
    const health = await AdminService.getSystemHealth();
    res.json({ success: true, data: health });
  } catch (e) { next(e); }
});

// Notifications Route
router.get('/notifications/all', adminOrJwtAuth, async (req: AuthRequest, res, next) => {
  try {
    const limit = parseInt(req.query.limit as string) || 50;
    const offset = parseInt(req.query.offset as string) || 0;
    const result = await query('SELECT * FROM notifications ORDER BY created_at DESC LIMIT $1 OFFSET $2', [limit, offset]);
    res.json({ success: true, data: result.rows });
  } catch (e) { next(e); }
});

router.put('/notifications/mark-all-read', adminOrJwtAuth, async (req: AuthRequest, res, next) => {
  try {
    // For admin context, marking all as read. We can mark all notifications where is_read = false
    await query('UPDATE notifications SET is_read = true WHERE is_read = false');
    res.json({ success: true, message: 'All notifications marked as read' });
  } catch (e) { next(e); }
});

router.delete('/notifications/:id', adminOrJwtAuth, async (req: AuthRequest, res, next) => {
  try {
    await query('DELETE FROM notifications WHERE id = $1', [req.params.id]);
    res.json({ success: true, message: 'Notification dismissed' });
  } catch (e) { next(e); }
});

// Support Tickets Routes
router.get('/tickets', adminOrJwtAuth, async (req: AuthRequest, res, next) => {
  try {
    const result = await query(`
      SELECT st.*, 
             COALESCE((SELECT json_agg(u ORDER BY u.created_at ASC) 
              FROM support_ticket_updates u 
              WHERE u.ticket_id = st.id), '[]'::json) as updates
      FROM support_tickets st
      ORDER BY st.created_at DESC
    `);
    res.json({ success: true, data: result.rows });
  } catch (e) { next(e); }
});

router.post('/tickets', adminOrJwtAuth, async (req: AuthRequest, res, next) => {
  try {
    const { title, priority, status, description, reporter, reporter_role, reporter_detail } = req.body;
    // Use authenticated admin as reporter if not supplied
    const finalReporter = reporter ?? req.user!.id;
    const finalReporterRole = reporter_role ?? (req.user!.roles?.[0] ?? 'admin');
    const finalReporterDetail = reporter_detail ?? null;
    const result = await query(
      `INSERT INTO support_tickets (title, priority, status, description, reporter, reporter_role, reporter_detail)
       VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
      [title, priority, status || 'open', description, finalReporter, finalReporterRole, finalReporterDetail]
    );
    const newTicket = result.rows[0];
    await query(`INSERT INTO support_ticket_updates (ticket_id, user_name, action, note) VALUES ($1, 'System', 'created', 'Ticket automatically routed to support queue')`, [newTicket.id]);
    res.status(201).json({ success: true, data: newTicket });
  } catch (e) { next(e); }
});

router.put('/tickets/:id', adminOrJwtAuth, async (req: AuthRequest, res, next) => {
  try {
    const { id } = req.params;
    const { priority, status, assigned_to, resolution_notes, update_note } = req.body;

    const result = await query(
      `UPDATE support_tickets 
       SET priority = COALESCE($1, priority), 
           status = COALESCE($2, status),
           assigned_to = COALESCE($3, assigned_to),
           resolution_notes = COALESCE($4, resolution_notes),
           updated_at = NOW()
       WHERE id = $5 RETURNING *`,
      [priority, status, assigned_to, resolution_notes, id]
    );

    // Determine action and insert update
    let action = 'note';
    let user_name = 'Admin';
    if (assigned_to) {
      action = 'assigned';
      user_name = assigned_to;
    } else if (status === 'resolved') {
      action = 'resolved';
    } else if (status === 'escalated') {
      action = 'escalated';
    } else if (status) {
      action = 'status_change';
    }

    const note = update_note || resolution_notes || (assigned_to ? `Assigned to ${assigned_to}` : `Status changed to ${status}`);
    await query(`INSERT INTO support_ticket_updates (ticket_id, user_name, action, note) VALUES ($1, $2, $3, $4)`, [id, user_name, action, note]);

    res.json({ success: true, data: result.rows[0] });
  } catch (e) { next(e); }
});

export { router as adminRouter };
