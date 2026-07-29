import { Router } from 'express';
import { LeaseService } from '../services/lease.service';
import { authenticate, AuthRequest, requireRole } from '../middleware/auth';
import { validate, schemas } from '../utils/validation';

const router = Router();

router.post('/', authenticate, requireRole('landlord', 'property_manager'), validate(schemas.leaseCreate), async (req: AuthRequest, res, next) => {
  try {
    const lease = await LeaseService.create(req.body, req.user!.id);
    res.status(201).json({ success: true, data: lease });
  } catch (e) { next(e); }
});

router.get('/dashboard', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const leases = await LeaseService.getDashboard(req.user!.id, req.user!.activeRole!);
    res.json({ success: true, data: leases });
  } catch (e) { next(e); }
});

router.get('/expiring-soon', authenticate, requireRole('landlord', 'property_manager'), async (req: AuthRequest, res, next) => {
  try {
    const leases = await LeaseService.getExpiringSoon(req.user!.id);
    res.json({ success: true, data: leases });
  } catch (e) { next(e); }
});

router.post('/:id/renew', authenticate, requireRole('landlord'), async (req: AuthRequest, res, next) => {
  try {
    const lease = await LeaseService.renewLease(req.params.id, req.user!.id, req.body);
    res.json({ success: true, data: lease });
  } catch (e) { next(e); }
});

router.get('/:id/inspections', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const inspections = await LeaseService.getInspections(req.params.id);
    // PDF expects exactly { lease_id, inspections: [...] }
    res.json({ lease_id: req.params.id, inspections });
  } catch (e) { next(e); }
});

router.post('/:id/inspections', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const inspection = await LeaseService.submitInspection(req.params.id, req.body, req.user!.id);
    res.status(201).json({ success: true, data: inspection });
  } catch (e) { next(e); }
});

export { router as leaseRouter };
