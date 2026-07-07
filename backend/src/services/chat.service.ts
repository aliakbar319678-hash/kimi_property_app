import { query, withTransaction } from '../db';
import { AppError } from '../middleware/errorHandler';

export class ChatService {
  static async createRoom(data: { type: string; title?: string; entityId?: string; participants: any[] }) {
    return withTransaction(async (client) => {
      const roomRes = await client.query(
        'INSERT INTO chat_rooms (type, title, entity_id, bid_visibility) VALUES ($1, $2, $3, $4) RETURNING *',
        [data.type, data.title || null, data.entityId || null, data.type === 'job' ? 'landlord_vendor_only' : 'full']
      );
      const room = roomRes.rows[0];
      for (const p of data.participants) {
        await client.query(
          'INSERT INTO chat_participants (room_id, user_id, role, can_view_bids, can_view_costs) VALUES ($1, $2, $3, $4, $5)',
          [room.id, p.userId, p.role, p.canViewBids || false, p.canViewCosts || false]
        );
      }
      return room;
    });
  }

  static async getRooms(userId: string) {
    const res = await query(
      `SELECT cr.*, 
              (SELECT COUNT(*) FROM messages m WHERE m.room_id = cr.id AND NOT (m.read_by @> $2::jsonb)) as unread_count,
              (SELECT content FROM messages m WHERE m.room_id = cr.id ORDER BY m.created_at DESC LIMIT 1) as last_message
       FROM chat_rooms cr
       JOIN chat_participants cp ON cp.room_id = cr.id
       WHERE cp.user_id = $1
       ORDER BY last_message DESC NULLS LAST`,
      [userId, JSON.stringify([{ user_id: userId }])]
    );
    return res.rows;
  }

  static async getMessages(roomId: string, userId: string, page: number = 1, limit: number = 50) {
    const participantRes = await query('SELECT * FROM chat_participants WHERE room_id = $1 AND user_id = $2', [roomId, userId]);
    if (participantRes.rows.length === 0) throw new AppError('Not a participant in this room', 403);

    const offset = (page - 1) * limit;
    const res = await query(
      `SELECT m.*, u.display_name as sender_name, u.avatar_url as sender_avatar
       FROM messages m
       JOIN users u ON u.id = m.sender_id
       WHERE m.room_id = $1
       ORDER BY m.created_at DESC
       LIMIT $2 OFFSET $3`,
      [roomId, limit, offset]
    );
    return res.rows;
  }

  static async sendMessage(roomId: string, senderId: string, content: string, attachments?: any[]) {
    const res = await query(
      'INSERT INTO messages (room_id, sender_id, content, attachments) VALUES ($1, $2, $3, $4) RETURNING *',
      [roomId, senderId, content, JSON.stringify(attachments || [])]
    );
    return res.rows[0];
  }

  static async markRead(roomId: string, userId: string) {
    await query(
      'UPDATE chat_participants SET last_read_at = NOW() WHERE room_id = $1 AND user_id = $2',
      [roomId, userId]
    );
    return { marked: true };
  }
}
