import { query } from '../db';
import { AppError } from '../middleware/errorHandler';

export class NotificationService {
  static async create(data: { userId: string; type: string; title: string; message: string; actionUrl?: string; actionType?: string; priority?: string; channels?: string[] }) {
    const res = await query(
      `INSERT INTO notifications (user_id, type, title, message, action_url, action_type, priority, channels, sent_at)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, NOW()) RETURNING *`,
      [data.userId, data.type, data.title, data.message, data.actionUrl || null, data.actionType || null, data.priority || 'normal', JSON.stringify(data.channels || ['in_app'])]
    );
    return res.rows[0];
  }

  static async getUnread(userId: string) {
    const res = await query(
      'SELECT * FROM notifications WHERE user_id = $1 AND is_read = false ORDER BY created_at DESC',
      [userId]
    );
    return res.rows;
  }

  static async getAll(userId: string, page: number = 1, limit: number = 20) {
    const offset = (page - 1) * limit;
    const res = await query(
      'SELECT * FROM notifications WHERE user_id = $1 ORDER BY created_at DESC LIMIT $2 OFFSET $3',
      [userId, limit, offset]
    );
    const countRes = await query('SELECT COUNT(*) FROM notifications WHERE user_id = $1', [userId]);
    return { data: res.rows, meta: { total: parseInt(countRes.rows[0].count, 10), page, limit } };
  }

  // New method to fetch all notifications for admin view
  static async getAllForAdmin(page: number = 1, limit: number = 20) {
    const offset = (page - 1) * limit;
    const res = await query(
      'SELECT * FROM notifications ORDER BY created_at DESC LIMIT $1 OFFSET $2',
      [limit, offset]
    );
    const countRes = await query('SELECT COUNT(*) FROM notifications');
    return { data: res.rows, meta: { total: parseInt(countRes.rows[0].count, 10), page, limit } };
  }

  static async markRead(userId: string, notificationId: string) {
    const res = await query(
      'UPDATE notifications SET is_read = true, read_at = NOW() WHERE id = $1 AND user_id = $2 RETURNING *',
      [notificationId, userId]
    );
    if (res.rows.length === 0) throw new AppError('Notification not found', 404);
    return res.rows[0];
  }

  static async markAllRead(userId: string) {
    await query('UPDATE notifications SET is_read = true, read_at = NOW() WHERE user_id = $1 AND is_read = false', [userId]);
    return { marked: true };
  }

  static async getUnreadCount(userId: string) {
    const res = await query('SELECT COUNT(*) FROM notifications WHERE user_id = $1 AND is_read = false', [userId]);
    return { count: parseInt(res.rows[0].count, 10) };
  }

  // ─── Domain-specific helpers ────────────────────────────────────────────────

  /** Staff account created (welcome) */
  static async createStaffWelcome(staffId: string, displayName: string) {
    return this.create({
      userId: staffId,
      type: 'system',
      title: 'Welcome to the Team!',
      message: `Hi ${displayName}, your staff account has been created. You can now log in and manage tickets.`,
      priority: 'normal',
      channels: ['in_app', 'email'],
    });
  }

  /** Ticket assigned to staff */
  static async createTicketAssigned(staffId: string, ticketId: string, ticketTitle: string) {
    return this.create({
      userId: staffId,
      type: 'maintenance',
      title: 'New Ticket Assigned',
      message: `You have been assigned ticket: "${ticketTitle}"`,
      actionUrl: `/staff/tickets/${ticketId}`,
      actionType: 'navigate',
      priority: 'high',
      channels: ['in_app', 'email'],
    });
  }

  /** New comment on a ticket */
  static async createNewComment(userId: string, ticketId: string, ticketTitle: string) {
    return this.create({
      userId,
      type: 'maintenance',
      title: 'New Comment on Your Ticket',
      message: `A new reply was posted on ticket: "${ticketTitle}"`,
      actionUrl: `/tickets/${ticketId}`,
      actionType: 'navigate',
      priority: 'normal',
      channels: ['in_app'],
    });
  }

  /** Payment entered hold */
  static async createPaymentHeld(vendorId: string, amount: number, releaseDate: Date, ticketId: string) {
    return this.create({
      userId: vendorId,
      type: 'payment',
      title: 'Payment on Hold',
      message: `$${amount.toFixed(2)} has been placed on a 5-day hold and will be released on ${releaseDate.toDateString()}.`,
      actionUrl: `/vendor/wallet`,
      actionType: 'navigate',
      priority: 'high',
      channels: ['in_app', 'email'],
    });
  }

  /** 1 day before payment release reminder */
  static async createHoldReleaseReminder(vendorId: string, amount: number, releaseDate: Date) {
    return this.create({
      userId: vendorId,
      type: 'payment',
      title: 'Payment Releasing Tomorrow',
      message: `$${amount.toFixed(2)} will be released to your available balance tomorrow (${releaseDate.toDateString()}).`,
      actionUrl: `/vendor/wallet`,
      actionType: 'navigate',
      priority: 'normal',
      channels: ['in_app', 'email'],
    });
  }

  /** Payment released from hold */
  static async createPaymentReleased(vendorId: string, netAmount: number) {
    return this.create({
      userId: vendorId,
      type: 'payment',
      title: 'Payment Released',
      message: `$${netAmount.toFixed(2)} has been added to your available balance.`,
      actionUrl: `/vendor/wallet`,
      actionType: 'navigate',
      priority: 'high',
      channels: ['in_app', 'email'],
    });
  }

  /** Hold cancelled */
  static async createHoldCancelled(vendorId: string, amount: number) {
    return this.create({
      userId: vendorId,
      type: 'payment',
      title: 'Payment Hold Cancelled',
      message: `The $${amount.toFixed(2)} payment hold has been cancelled.`,
      priority: 'high',
      channels: ['in_app', 'email'],
    });
  }

  /** Ticket auto-resolved/closed by cron */
  static async createTicketAutoClosed(vendorId: string, ticketTitle: string) {
    return this.create({
      userId: vendorId,
      type: 'maintenance',
      title: 'Ticket Auto-Closed',
      message: `Your ticket "${ticketTitle}" has been automatically closed after payment release.`,
      priority: 'low',
      channels: ['in_app'],
    });
  }
}

