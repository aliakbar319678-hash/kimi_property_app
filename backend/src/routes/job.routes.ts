import { Router } from 'express';
import { JobService, PROMOTION_TYPES } from '../services/job.service';
import { authenticate, AuthRequest, requireRole } from '../middleware/auth';
import { adminOrJwtAuth } from '../middleware/adminKey';

const router = Router();

// ─────────────────────────────────────────────────────────
// LANDLORD — Post & Manage Jobs
// ─────────────────────────────────────────────────────────

/**
 * POST /jobs
 * Landlord creates a new job posting.
 */
router.post('/', authenticate, requireRole('landlord', 'property_manager'), async (req: AuthRequest, res, next) => {
  try {
    const { propertyId, unitId, title, description, category, subCategory, urgency,
            budgetMin, budgetMax, preferredTimeline, bidDeadline, photos, specialNotes } = req.body;

    if (!propertyId || !title || !category) {
      return res.status(400).json({ success: false, message: 'propertyId, title and category are required' });
    }

    const job = await JobService.createJob(req.user!.id, {
      propertyId, unitId, title, description, category, subCategory, urgency,
      budgetMin, budgetMax, preferredTimeline, bidDeadline, photos, specialNotes,
    });
    res.status(201).json({ success: true, data: job });
  } catch (e) { next(e); }
});

/**
 * GET /jobs
 * Landlord views their own job postings.
 * Query: ?status=open|in_progress|completed|cancelled
 */
router.get('/', authenticate, requireRole('landlord', 'property_manager'), async (req: AuthRequest, res, next) => {
  try {
    const jobs = await JobService.getLandlordJobs(req.user!.id, req.query.status as string);
    res.json({ success: true, data: jobs });
  } catch (e) { next(e); }
});

/**
 * GET /jobs/:id/bids
 * Landlord reviews all bids on a specific job.
 */
router.get('/:id/bids', authenticate, requireRole('landlord', 'property_manager'), async (req: AuthRequest, res, next) => {
  try {
    const result = await JobService.getJobBids(req.params.id, req.user!.id);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

/**
 * PATCH /jobs/:id/bids/:bidId/accept
 * Landlord accepts a bid. Trigger auto-rejects others + sets job to in_progress.
 */
router.patch('/:id/bids/:bidId/accept', authenticate, requireRole('landlord', 'property_manager'), async (req: AuthRequest, res, next) => {
  try {
    const result = await JobService.acceptBid(req.params.bidId, req.user!.id);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

/**
 * PATCH /jobs/:id/bids/:bidId/reject
 * Landlord rejects a specific bid.
 */
router.patch('/:id/bids/:bidId/reject', authenticate, requireRole('landlord', 'property_manager'), async (req: AuthRequest, res, next) => {
  try {
    const result = await JobService.rejectBid(req.params.bidId, req.user!.id);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

// ─────────────────────────────────────────────────────────
// VENDOR — Browse & Bid on Jobs
// ─────────────────────────────────────────────────────────

/**
 * GET /jobs/open
 * Vendor views all open job postings matching their service categories.
 */
router.get('/open', authenticate, requireRole('vendor'), async (req: AuthRequest, res, next) => {
  try {
    const { query: queryModule } = await import('../db');
    const res2 = await queryModule(
      `SELECT jp.*,
         p.name as property_name,
         json_build_object('id', u.id, 'display_name', u.display_name) as landlord,
         (SELECT COUNT(*) FROM vendor_job_bids vjb WHERE vjb.job_id = jp.id AND vjb.status = 'pending') as bid_count,
         (SELECT COUNT(*) FROM vendor_job_bids vjb WHERE vjb.job_id = jp.id AND vjb.vendor_id = $1) as my_bid_count
       FROM jobs_posted jp
       LEFT JOIN properties p ON p.id = jp.property_id
       JOIN users u ON u.id = jp.landlord_id
       WHERE jp.status = 'open'
         AND (jp.bid_deadline IS NULL OR jp.bid_deadline > NOW())
       ORDER BY
         CASE jp.urgency WHEN 'emergency' THEN 1 WHEN 'urgent' THEN 2 ELSE 3 END,
         jp.created_at DESC`,
      [req.user!.id]
    );
    res.json({ success: true, data: res2.rows });
  } catch (e) { next(e); }
});

/**
 * POST /jobs/:id/bids
 * Vendor submits a bid on an open job.
 * Body: { bidAmount, proposalNotes, promotionType, photos[] }
 */
router.post('/:id/bids', authenticate, requireRole('vendor'), async (req: AuthRequest, res, next) => {
  try {
    const { bidAmount, proposalNotes, promotionType, photos } = req.body;
    if (!bidAmount) {
      return res.status(400).json({ success: false, message: 'bidAmount is required' });
    }

    const { query: queryModule } = await import('../db');

    // Check job is open
    const jobRes = await queryModule(
      `SELECT id, status, bid_deadline FROM jobs_posted WHERE id = $1`,
      [req.params.id]
    );
    if (jobRes.rows.length === 0) return res.status(404).json({ success: false, message: 'Job not found' });
    if (jobRes.rows[0].status !== 'open') return res.status(400).json({ success: false, message: 'Job is no longer open for bids' });

    const bidRes = await queryModule(
      `INSERT INTO vendor_job_bids (job_id, vendor_id, bid_amount, proposal_notes, promotion_type, photos)
       VALUES ($1, $2, $3, $4, $5, $6)
       ON CONFLICT (job_id, vendor_id) DO UPDATE
         SET bid_amount = EXCLUDED.bid_amount,
             proposal_notes = EXCLUDED.proposal_notes,
             promotion_type = EXCLUDED.promotion_type,
             photos = EXCLUDED.photos
       RETURNING *`,
      [req.params.id, req.user!.id, bidAmount, proposalNotes || null, promotionType || null, JSON.stringify(photos || [])]
    );
    res.status(201).json({ success: true, data: bidRes.rows[0] });
  } catch (e) { next(e); }
});

/**
 * GET /jobs/my-bids
 * Vendor sees all their bids on jobs_posted.
 */
router.get('/my-bids', authenticate, requireRole('vendor'), async (req: AuthRequest, res, next) => {
  try {
    const { query: queryModule } = await import('../db');
    const res2 = await queryModule(
      `SELECT vjb.*,
         json_build_object(
           'id', jp.id, 'title', jp.title, 'category', jp.category,
           'urgency', jp.urgency, 'status', jp.status,
           'budget_min', jp.budget_min, 'budget_max', jp.budget_max,
           'property_name', p.name
         ) as job
       FROM vendor_job_bids vjb
       JOIN jobs_posted jp ON jp.id = vjb.job_id
       LEFT JOIN properties p ON p.id = jp.property_id
       WHERE vjb.vendor_id = $1
       ORDER BY vjb.created_at DESC`,
      [req.user!.id]
    );
    res.json({ success: true, data: res2.rows });
  } catch (e) { next(e); }
});

/**
 * GET /jobs/active-jobs
 * Vendor sees jobs where their bid was accepted.
 */
router.get('/active-jobs', authenticate, requireRole('vendor'), async (req: AuthRequest, res, next) => {
  try {
    const { query: queryModule } = await import('../db');
    const res2 = await queryModule(
      `SELECT jp.*,
         vjb.bid_amount, vjb.proposal_notes,
         p.name as property_name, p.address_line1, p.city, p.state_province,
         u_unit.unit_number,
         json_build_object('id', u.id, 'display_name', u.display_name, 'email', u.email) as landlord_contact
       FROM vendor_job_bids vjb
       JOIN jobs_posted jp ON jp.id = vjb.job_id
       LEFT JOIN properties p ON p.id = jp.property_id
       LEFT JOIN units u_unit ON u_unit.id = jp.unit_id
       JOIN users u ON u.id = jp.landlord_id
       WHERE vjb.vendor_id = $1 AND vjb.status = 'accepted'
       ORDER BY jp.updated_at DESC`,
      [req.user!.id]
    );
    res.json({ success: true, data: res2.rows });
  } catch (e) { next(e); }
});

// ─────────────────────────────────────────────────────────
// METADATA
// ─────────────────────────────────────────────────────────

/**
 * GET /jobs/meta/promotion-types
 * Returns valid promotion type options for bid submission.
 */
router.get('/meta/promotion-types', (_req, res) => {
  res.json({ success: true, data: PROMOTION_TYPES });
});

// ─────────────────────────────────────────────────────────
// ADMIN — All Jobs
// ─────────────────────────────────────────────────────────

/**
 * GET /jobs/admin/all
 * Admin sees all job postings.
 */
router.get('/admin/all', adminOrJwtAuth, async (req: AuthRequest, res, next) => {
  try {
    const isAdmin = req.user?.roles?.includes('admin') || req.user?.roles?.includes('super_admin');
    if (!isAdmin) return res.status(403).json({ success: false, message: 'Admin access required' });
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 20;
    const result = await JobService.getAllForAdmin(page, limit);
    res.json({ success: true, ...result });
  } catch (e) { next(e); }
});

/**
 * GET /jobs/admin/:id/bids
 * Admin sees all bids on a specific job.
 */
router.get('/admin/:id/bids', adminOrJwtAuth, async (req: AuthRequest, res, next) => {
  try {
    const isAdmin = req.user?.roles?.includes('admin') || req.user?.roles?.includes('super_admin');
    if (!isAdmin) return res.status(403).json({ success: false, message: 'Admin access required' });
    
    const { query: queryModule } = await import('../db');
    
    // Get job
    const jobRes = await queryModule('SELECT * FROM jobs_posted WHERE id = $1', [req.params.id]);
    if (jobRes.rows.length === 0) return res.status(404).json({ success: false, message: 'Job not found' });
    
    // Get bids
    const bidsRes = await queryModule(
      `SELECT vjb.*,
         json_build_object(
           'id', u.id,
           'display_name', u.display_name,
           'email', u.email
         ) as vendor
       FROM vendor_job_bids vjb
       JOIN users u ON u.id = vjb.vendor_id
       WHERE vjb.job_id = $1
       ORDER BY vjb.created_at ASC`,
      [req.params.id]
    );
    
    res.json({ success: true, data: { job: jobRes.rows[0], bids: bidsRes.rows } });
  } catch (e) { next(e); }
});

export { router as jobRouter };
