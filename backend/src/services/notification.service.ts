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
}
