import { Router } from 'express';
import { CalendarService } from '../services/calendar.service';
import { authenticate, AuthRequest } from '../middleware/auth';

const router = Router();

router.post('/events', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const event = await CalendarService.createEvent(req.body);
    res.status(201).json({ success: true, data: event });
  } catch (e) { next(e); }
});

router.post('/google-link', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const link = await CalendarService.generateGoogleCalendarLink(req.body);
    res.json({ success: true, data: { link } });
  } catch (e) { next(e); }
});

export { router as calendarRouter };
