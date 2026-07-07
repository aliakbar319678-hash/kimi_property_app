import { Router } from 'express';
import { VendorService } from '../services/vendor.service';
import { MaintenanceService } from '../services/maintenance.service';
import { authenticate, AuthRequest, requireRole } from '../middleware/auth';

const router = Router();

router.get('/my-bids', authenticate, requireRole('vendor'), async (req: AuthRequest, res, next) => {
  try {
    const bids = await VendorService.getMyBids(req.user!.id, req.query.status as string);
    res.json({ success: true, data: bids });
  } catch (e) { next(e); }
});

router.get('/stats', authenticate, requireRole('vendor'), async (req: AuthRequest, res, next) => {
  try {
    const stats = await VendorService.getVendorStats(req.user!.id);
    res.json({ success: true, data: stats });
  } catch (e) { next(e); }
});

router.get('/jobs', authenticate, requireRole('vendor'), async (req: AuthRequest, res, next) => {
  try {
    const jobs = await MaintenanceService.getVendorJobs(req.user!.id, req.query.status as string);
    res.json({ success: true, data: jobs });
  } catch (e) { next(e); }
});

export { router as vendorRouter };
