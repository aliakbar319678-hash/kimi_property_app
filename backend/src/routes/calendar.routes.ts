import { Router } from 'express';
import { CalendarService } from '../services/calendar.service';
import { authenticate, AuthRequest } from '../middleware/auth';
import { query } from '../db';

const router = Router();

/**
 * @swagger
 * tags:
 *   name: Calendar
 *   description: Calendar events and integrations
 */

/**
 * @swagger
 * /api/v1/calendar/events:
 *   get:
 *     summary: Get calendar events for the authenticated user
 *     tags: [Calendar]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of calendar events
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   type: array
 *                   items:
 *                     type: object
 */
router.get('/events', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const userId = req.user!.id;
    // Aggregate events from multiple sources: showings, lease expiries, work orders
    const showings = await query(
      `SELECT id, 'showing' as type, showing_date as start_date, notes as description, status
       FROM showings WHERE tenant_id = $1 ORDER BY showing_date ASC`,
      [userId]
    );
    const leases = await query(
      `SELECT id, 'lease_expiry' as type, end_date as start_date, 
              'Lease expiring' as description, status
       FROM leases WHERE tenant_id = $1 AND status IN ('active','expiring')`,
      [userId]
    );
    const workOrders = await query(
      `SELECT id, 'work_order' as type, scheduled_date as start_date,
              title as description, status
       FROM work_orders WHERE tenant_id = $1 AND scheduled_date IS NOT NULL`,
      [userId]
    );
    const events = [
      ...showings.rows,
      ...leases.rows,
      ...workOrders.rows,
    ].sort((a, b) => new Date(a.start_date).getTime() - new Date(b.start_date).getTime());
    res.json({ success: true, data: events });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/calendar/events:
 *   post:
 *     summary: Create a calendar event
 *     tags: [Calendar]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               title:
 *                 type: string
 *               startTime:
 *                 type: string
 *                 format: date-time
 *               endTime:
 *                 type: string
 *                 format: date-time
 *               description:
 *                 type: string
 *     responses:
 *       201:
 *         description: Event created
 */
router.post('/events', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const { title, description, startTime, endTime, startDate, endDate, attendees, location } = req.body;
    const event = await CalendarService.createEvent({
      title,
      description,
      startDate: startDate || startTime,
      endDate: endDate || endTime,
      attendees,
      location,
    });
    res.status(201).json({ success: true, data: event });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/calendar/google-link:
 *   post:
 *     summary: Generate Google Calendar integration link
 *     tags: [Calendar]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               title:
 *                 type: string
 *               startTime:
 *                 type: string
 *                 format: date-time
 *               endTime:
 *                 type: string
 *                 format: date-time
 *               description:
 *                 type: string
 *     responses:
 *       200:
 *         description: Generated link
 */
router.post('/google-link', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const { title, startTime, endTime, startDate, endDate, location } = req.body;
    const link = await CalendarService.generateGoogleCalendarLink({
      title,
      startDate: startDate || startTime,
      endDate: endDate || endTime,
      location,
    });
    res.json({ success: true, data: { link } });
  } catch (e) { next(e); }
});

export { router as calendarRouter };
