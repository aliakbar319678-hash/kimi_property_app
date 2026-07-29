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
    const { title, startDate, endDate, location } = req.body;
    if (!title || !startDate || !endDate) {
      return res.status(400).json({ 
        success: false, 
        message: 'title, startDate, and endDate are required. Please provide event details to generate the link.' 
      });
    }
    const link = await CalendarService.generateGoogleCalendarLink({ title, startDate, endDate, location });
    res.json({ success: true, data: { link } });
  } catch (e) { next(e); }
});

export { router as calendarRouter };
