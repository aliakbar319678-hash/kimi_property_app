import { Router } from 'express';
import { ApplicationService, CONDITIONAL_TAGS } from '../services/application.service';
import { authenticate, AuthRequest, requireRole } from '../middleware/auth';
import { adminOrJwtAuth } from '../middleware/adminKey';

const router = Router();

// ─────────────────────────────────────────────────────────
// TENANT ROUTES
// ─────────────────────────────────────────────────────────

/**
 * POST /applications/draft
 * Save a wizard step. Creates draft if first step, updates otherwise.
 * Auth required (tenant).
 */
router.post('/draft', authenticate, requireRole('tenant'), async (req: AuthRequest, res, next) => {
  try {
    const { unitId, propertyId, landlordId, step, personalInfo, incomeEmployment, referencesData, documents } = req.body;
    if (!unitId || !propertyId || !step) {
      return res.status(400).json({ success: false, message: 'unitId, propertyId and step are required' });
    }
    const app = await ApplicationService.createOrUpdateDraft(req.user!.id, {
      unitId, propertyId, landlordId, step, personalInfo, incomeEmployment, referencesData, documents,
    });
    res.json({ success: true, data: app });
  } catch (e) { next(e); }
});

/**
 * POST /applications/:id/submit
 * Final submission of completed application.
 */
router.post('/:id/submit', authenticate, requireRole('tenant'), async (req: AuthRequest, res, next) => {
  try {
    const app = await ApplicationService.submitApplication(req.params.id, req.user!.id);
    res.json({ success: true, data: app });
  } catch (e) { next(e); }
});

/**
 * POST /applications/:id/screening
 * Charge $50 screening fee and initiate background check.
 * Body: { paymentMethodId: string }
 */
router.post('/:id/screening', authenticate, requireRole('tenant'), async (req: AuthRequest, res, next) => {
  try {
    const { paymentMethodId } = req.body;
    if (!paymentMethodId) {
      return res.status(400).json({ success: false, message: 'paymentMethodId is required' });
    }
    const result = await ApplicationService.chargeScreeningFee(req.params.id, req.user!.id, paymentMethodId);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

/**
 * GET /applications/me
 * Tenant views their own applications.
 */
router.get('/me', authenticate, requireRole('tenant'), async (req: AuthRequest, res, next) => {
  try {
    const apps = await ApplicationService.getTenantApplications(req.user!.id);
    res.json({ success: true, data: apps });
  } catch (e) { next(e); }
});

/**
 * GET /applications/:id
 * Get a single application (accessible by the tenant or landlord on that application).
 */
router.get('/:id', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const app = await ApplicationService.getById(req.params.id, req.user!.id);
    res.json({ success: true, data: app });
  } catch (e) { next(e); }
});

// ─────────────────────────────────────────────────────────
// LANDLORD ROUTES
// ─────────────────────────────────────────────────────────

/**
 * GET /applications
 * Landlord views applications on their properties.
 * Query: ?status=pending|approved|rejected|conditional_approval
 */
router.get('/', authenticate, requireRole('landlord', 'property_manager'), async (req: AuthRequest, res, next) => {
  try {
    const apps = await ApplicationService.getLandlordApplications(req.user!.id, req.query.status as string);
    res.json({ success: true, data: apps });
  } catch (e) { next(e); }
});

/**
 * PATCH /applications/:id/status
 * Landlord updates application status.
 * Body: { status: 'approved'|'rejected'|'conditional_approval', conditionalTerms?: { tags: [], note: '' } }
 */
router.patch('/:id/status', authenticate, requireRole('landlord', 'property_manager'), async (req: AuthRequest, res, next) => {
  try {
    const { status, conditionalTerms } = req.body;
    const validStatuses = ['approved', 'rejected', 'conditional_approval'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({ success: false, message: `Status must be one of: ${validStatuses.join(', ')}` });
    }
    const app = await ApplicationService.updateStatus(req.params.id, req.user!.id, status, conditionalTerms);
    res.json({ success: true, data: app });
  } catch (e) { next(e); }
});

// ─────────────────────────────────────────────────────────
// ADMIN ROUTES
// ─────────────────────────────────────────────────────────

/**
 * GET /applications/admin/all
 * Admin views all applications across the platform.
 */
router.get('/admin/all', adminOrJwtAuth, async (req: AuthRequest, res, next) => {
  try {
    const isAdmin = req.user?.roles?.includes('admin') || req.user?.roles?.includes('super_admin');
    if (!isAdmin) return res.status(403).json({ success: false, message: 'Admin access required' });
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 20;
    const result = await ApplicationService.getAllForAdmin(page, limit);
    res.json({ success: true, ...result });
  } catch (e) { next(e); }
});

/**
 * GET /applications/meta/conditional-tags
 * Returns the list of valid conditional approval tags (for frontend dropdowns).
 */
router.get('/meta/conditional-tags', async (_req, res) => {
  res.json({ success: true, data: CONDITIONAL_TAGS });
});

export { router as applicationRouter };
