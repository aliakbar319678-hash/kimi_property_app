import { Server as SocketIOServer, Socket } from 'socket.io';
import jwt from 'jsonwebtoken';
import { config } from '../config';
import { query } from '../db';
import { ChatService } from '../services/chat.service';
import { NotificationService } from '../services/notification.service';

export function initializeSocketHandlers(io: SocketIOServer) {
  io.use(async (socket: Socket, next) => {
    try {
      const token = socket.handshake.auth.token || socket.handshake.headers['authorization']?.toString().replace('Bearer ', '');
      if (!token) return next(new Error('Authentication error'));
      const decoded: any = jwt.verify(token, config.jwtSecret);
      const userRes = await query('SELECT id, display_name FROM users WHERE id = $1 AND is_active = true', [decoded.userId]);
      if (userRes.rows.length === 0) return next(new Error('User not found'));
      socket.data.user = userRes.rows[0];
      next();
    } catch (err) {
      next(new Error('Authentication error'));
    }
  });

  io.on('connection', (socket: Socket) => {
    const userId = socket.data.user.id;
    console.log(`Socket connected: ${userId}`);

    // Join personal room for notifications
    socket.join(`user:${userId}`);

    socket.on('join-room', async ({ roomId }: { roomId: string }) => {
      const participantRes = await query('SELECT * FROM chat_participants WHERE room_id = $1 AND user_id = $2', [roomId, userId]);
      if (participantRes.rows.length === 0) {
        socket.emit('error', { message: 'Not authorized for this room' });
        return;
      }
      socket.join(`room:${roomId}`);
      socket.emit('joined', { roomId });
    });

    socket.on('send-message', async ({ roomId, content, attachments }: { roomId: string; content: string; attachments?: any[] }) => {
      try {
        const msg = await ChatService.sendMessage(roomId, userId, content, attachments);
        const enriched = { ...msg, sender_name: socket.data.user.display_name };
        io.to(`room:${roomId}`).emit('new-message', enriched);
      } catch (err: any) {
        socket.emit('error', { message: err.message });
      }
    });

    socket.on('typing', ({ roomId }: { roomId: string }) => {
      socket.to(`room:${roomId}`).emit('typing', { userId, roomId });
    });

    socket.on('disconnect', () => {
      console.log(`Socket disconnected: ${userId}`);
    });
  });
}

export function emitToUser(io: SocketIOServer, userId: string, event: string, data: any) {
  io.to(`user:${userId}`).emit(event, data);
}
