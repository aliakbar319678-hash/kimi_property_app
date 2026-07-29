import { query } from '../db';
import { AppError } from '../middleware/errorHandler';

export class DiscussionService {
  static async create(userId: string, data: { title: string; content: string; category: string; tags?: string[] }) {
    const res = await query(
      `INSERT INTO discussions (user_id, category, title, content, tags)
       VALUES ($1, $2, $3, $4, $5) RETURNING id`,
      [userId, data.category, data.title, data.content, JSON.stringify(data.tags || [])]
    );
    return await this.getById(res.rows[0].id);
  }

  static async list(filters: { category?: string; page?: number; limit?: number }) {
    let sql = `SELECT d.*, u.display_name as author_name, u.avatar_url as author_avatar,
                      (SELECT COUNT(*) FROM discussion_replies WHERE discussion_id = d.id) as reply_count
               FROM discussions d
               JOIN users u ON u.id = d.user_id
               WHERE 1=1`;
    const params: any[] = [];
    let idx = 1;
    if (filters.category) { sql += ` AND d.category = $${idx++}`; params.push(filters.category); }
    sql += ` ORDER BY d.is_pinned DESC, d.created_at DESC LIMIT $${idx++} OFFSET $${idx++}`;
    params.push(filters.limit || 20, ((filters.page || 1) - 1) * (filters.limit || 20));
    const res = await query(sql, params);
    return res.rows;
  }

  static async getById(id: string) {
    const discRes = await query(`
      SELECT d.*, u.display_name as author_name, u.avatar_url as author_avatar
      FROM discussions d
      JOIN users u ON u.id = d.user_id
      WHERE d.id = $1
    `, [id]);
    if (discRes.rows.length === 0) throw new AppError('Discussion not found', 404);
    await query('UPDATE discussions SET views_count = views_count + 1 WHERE id = $1', [id]);
    const repliesRes = await query(
      `SELECT r.*, u.display_name as author_name, u.avatar_url as author_avatar
       FROM discussion_replies r
       JOIN users u ON u.id = r.user_id
       WHERE r.discussion_id = $1
       ORDER BY r.created_at ASC`,
      [id]
    );
    return { ...discRes.rows[0], replies: repliesRes.rows };
  }

  static async addReply(userId: string, discussionId: string, content: string, parentId?: string) {
    const res = await query(
      `INSERT INTO discussion_replies (discussion_id, user_id, parent_id, content)
       VALUES ($1, $2, $3, $4) RETURNING id`,
      [discussionId, userId, parentId || null, content]
    );
    const replyRes = await query(
      `SELECT r.*, u.display_name as author_name, u.avatar_url as author_avatar
       FROM discussion_replies r
       JOIN users u ON u.id = r.user_id
       WHERE r.id = $1`,
      [res.rows[0].id]
    );
    return replyRes.rows[0];
  }

  static async upvoteReply(replyId: string) {
    await query('UPDATE discussion_replies SET upvotes = upvotes + 1 WHERE id = $1', [replyId]);
    return { upvoted: true };
  }

  static async togglePin(id: string) {
    const res = await query('UPDATE discussions SET is_pinned = NOT is_pinned WHERE id = $1 RETURNING is_pinned', [id]);
    if (res.rows.length === 0) throw new AppError('Discussion not found', 404);
    return res.rows[0];
  }
}
