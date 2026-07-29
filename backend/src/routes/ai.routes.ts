import { Router, Request } from 'express';
import { AIService } from '../services/ai.service';
import { query } from '../db';

const router = Router();

router.post('/chat', async (req: Request, res, next) => {
  try {
    const user = (req as any).user;
    const userId = req.body.userId || user?.id || 'guest';
    const role = req.body.role || user?.activeRole || 'guest';
    const sessionId = req.body.sessionId || `session_${Date.now()}`;
    const offset = parseInt(req.body.offset || '0', 10);
    const location = req.body.location || '';

    const result = await AIService.chat(req.body.message, {
      userId,
      role,
      sessionId,
      offset,
      location,
      propertyId: req.body.propertyId,
      leaseId: req.body.leaseId,
    });

    res.json({ success: true, data: { ...result, sessionId } });
  } catch (e) { next(e); }
});

router.get('/sessions', async (req: Request, res, next) => {
  try {
    const user = (req as any).user;
    const userId = (req.query.userId as string) || user?.id || 'guest';

    const sql = `
      SELECT DISTINCT ON (COALESCE(session_id, 'default_session'))
        COALESCE(session_id, 'default_session') as session_id,
        user_message as title_snippet,
        created_at
      FROM ai_chat_logs
      WHERE user_id = $1 OR user_id = 'guest'
      ORDER BY COALESCE(session_id, 'default_session'), created_at ASC
    `;
    const sessions = await query(sql, [userId]);
    res.json({ success: true, data: sessions.rows });
  } catch (e) { next(e); }
});

router.get('/sessions/:sessionId', async (req: Request, res, next) => {
  try {
    const sessionId = req.params.sessionId;
    const sql = `
      SELECT id, session_id, role, user_message, ai_response, source, created_at 
      FROM ai_chat_logs 
      WHERE session_id = $1 
      ORDER BY created_at ASC
    `;
    const logs = await query(sql, [sessionId]);
    res.json({ success: true, data: logs.rows });
  } catch (e) { next(e); }
});

router.get('/history', async (req: Request, res, next) => {
  try {
    const user = (req as any).user;
    const userId = (req.query.userId as string) || user?.id || 'guest';
    const role = (req.query.role as string) || 'guest';

    const sql = `
      SELECT id, session_id, role, user_message, ai_response, source, created_at 
      FROM ai_chat_logs 
      WHERE (user_id = $1 OR role = $2) 
      ORDER BY created_at DESC 
      LIMIT 20
    `;
    const logs = await query(sql, [userId, role]);
    res.json({ success: true, data: logs.rows });
  } catch (e) { next(e); }
});

export { router as aiRouter };
