import { Router } from 'express';
import { MaintenanceService } from '../services/maintenance.service';
import { authenticate, AuthRequest, requireRole } from '../middleware/auth';
import { validate, schemas } from '../utils/validation';

const router = Router();

router.post('/work-orders', authenticate, requireRole('landlord', 'property_manager'), validate(schemas.workOrderCreate), async (req: AuthRequest, res, next) => {
  try {
    const wo = await MaintenanceService.createWorkOrder(req.body, req.user!.id);
    res.status(201).json({ success: true, data: wo });
  } catch (e) { next(e); }
});

router.get('/work-orders', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const orders = await MaintenanceService.getWorkOrders(req.user!.id, req.user!.activeRole!, req.query);
    res.json({ success: true, data: orders });
  } catch (e) { next(e); }
});

router.get('/work-orders/:id', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const order = await MaintenanceService.getById(req.params.id);
    res.json({ success: true, data: order });
  } catch (e) { next(e); }
});

router.post('/work-orders/:id/bids', authenticate, requireRole('vendor'), validate(schemas.bidCreate), async (req: AuthRequest, res, next) => {
  try {
    const bid = await MaintenanceService.submitBid(req.params.id, req.user!.id, req.body);
    res.status(201).json({ success: true, data: bid });
  } catch (e) { next(e); }
});

router.post('/bids/:id/accept', authenticate, requireRole('landlord', 'property_manager'), async (req: AuthRequest, res, next) => {
  try {
    const result = await MaintenanceService.acceptBid(req.params.id, req.user!.id);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

router.put('/work-orders/:id/status', authenticate, requireRole('landlord', 'property_manager', 'vendor'), async (req: AuthRequest, res, next) => {
  try {
    const result = await MaintenanceService.updateStatus(req.params.id, req.body.status, req.user!.id);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

router.get('/vendor/jobs', authenticate, requireRole('vendor'), async (req: AuthRequest, res, next) => {
  try {
    const jobs = await MaintenanceService.getVendorJobs(req.user!.id, req.query.status as string);
    res.json({ success: true, data: jobs });
  } catch (e) { next(e); }
});

router.post('/work-orders/:id/rate', authenticate, requireRole('landlord', 'property_manager'), async (req: AuthRequest, res, next) => {
  try {
    const result = await MaintenanceService.submitVendorRating(req.params.id, req.body, req.user!.id);
    res.status(201).json(result);
  } catch (e) { next(e); }
});

export { router as maintenanceRouter };
