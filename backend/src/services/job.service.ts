import { query } from '../db';
import { AppError } from '../middleware/errorHandler';
import { NotificationService } from './notification.service';

// ─────────────────────────────────────────────────────────
// 5 Promotion options (from PDF spec)
// ─────────────────────────────────────────────────────────
export const PROMOTION_TYPES = [
  'advertise_services_to_landlords',
  'share_special_promotions_or_discounts',
  'feature_services_on_platform',
  'send_promotional_notifications',
  'create_limited_time_offers',
] as const;

export type PromotionType = typeof PROMOTION_TYPES[number];

// ─────────────────────────────────────────────────────────
// Job Service
// ─────────────────────────────────────────────────────────
export class JobService {

  /**
   * Landlord creates a new job posting
   */
  static async createJob(landlordId: string, data: {
    propertyId: string;
    unitId?: string;
    title: string;
    description?: string;
    category: string;
    subCategory?: string;
    urgency?: 'emergency' | 'urgent' | 'standard';
    budgetMin?: number;
    budgetMax?: number;
    preferredTimeline?: string;
    bidDeadline?: string;
    photos?: string[];
    specialNotes?: string;
  }) {
    const res = await query(
      `INSERT INTO jobs_posted
         (landlord_id, property_id, unit_id, title, description, category, sub_category,
          urgency, budget_min, budget_max, preferred_timeline, bid_deadline, photos, special_notes)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
       RETURNING *`,
      [
        landlordId,
        data.propertyId,
        data.unitId || null,
        data.title,
        data.description || null,
        data.category,
        data.subCategory || null,
        data.urgency || 'standard',
        data.budgetMin || null,
        data.budgetMax || null,
        data.preferredTimeline || null,
        data.bidDeadline || null,
        JSON.stringify(data.photos || []),
        data.specialNotes || null,
      ]
    );

    const job = res.rows[0];

    // Notify matching vendors asynchronously
    this.notifyMatchingVendors(job.id, job.title, job.category).catch((err) =>
      console.error('[JOB] Failed to notify vendors:', err)
    );

    return job;
  }

  /**
   * Find vendors who match the job's category and send them a notification
   */
  private static async notifyMatchingVendors(jobId: string, jobTitle: string, category: string) {
    // Find vendors with matching service category
    const vendorsRes = await query(
      `SELECT up.user_id
       FROM user_profiles up
       JOIN user_roles ur ON ur.user_id = up.user_id
       WHERE ur.role = 'vendor'
         AND up.vendor_services->'categories' ? $1`,
      [category]
    );
    for (const row of vendorsRes.rows) {
      await NotificationService.createJobPostedAlert(row.user_id, jobId, jobTitle, category);
    }
  }

  /**
   * Get all jobs posted by a landlord
   */
  static async getLandlordJobs(landlordId: string, status?: string) {
    let sql = `SELECT jp.*,
                 p.name as property_name,
                 u.unit_number,
                 (SELECT COUNT(*) FROM vendor_job_bids vjb WHERE vjb.job_id = jp.id AND vjb.status = 'pending') as pending_bid_count,
                 (SELECT COUNT(*) FROM vendor_job_bids vjb WHERE vjb.job_id = jp.id) as total_bid_count
               FROM jobs_posted jp
               LEFT JOIN properties p ON p.id = jp.property_id
               LEFT JOIN units u ON u.id = jp.unit_id
               WHERE jp.landlord_id = $1`;
    const params: any[] = [landlordId];
    if (status) { sql += ` AND jp.status = $2`; params.push(status); }
    sql += ` ORDER BY jp.created_at DESC`;
    const res = await query(sql, params);
    return res.rows;
  }

  /**
   * Get all bids on a specific job (landlord review page)
   */
  static async getJobBids(jobId: string, landlordId: string) {
    // Verify landlord owns this job
    const jobRes = await query('SELECT id, landlord_id, title, status FROM jobs_posted WHERE id = $1', [jobId]);
    if (jobRes.rows.length === 0) throw new AppError('Job not found', 404);
    if (jobRes.rows[0].landlord_id !== landlordId) throw new AppError('Not authorized', 403);

    const bidsRes = await query(
      `SELECT vjb.*,
         json_build_object(
           'id', u.id,
           'display_name', u.display_name,
           'email', u.email,
           'vendor_services', up.vendor_services
         ) as vendor
       FROM vendor_job_bids vjb
       JOIN users u ON u.id = vjb.vendor_id
       LEFT JOIN user_profiles up ON up.user_id = vjb.vendor_id
       WHERE vjb.job_id = $1
       ORDER BY vjb.created_at ASC`,
      [jobId]
    );
    return { job: jobRes.rows[0], bids: bidsRes.rows };
  }

  /**
   * Landlord accepts a specific bid.
   * Trigger `trg_vendor_bid_acceptance` will:
   *   - Auto-reject all other pending bids on this job
   *   - Set jobs_posted.status = 'in_progress'
   */
  static async acceptBid(bidId: string, landlordId: string) {
    // Verify the bid belongs to a job owned by this landlord
    const bidRes = await query(
      `SELECT vjb.*, jp.landlord_id, jp.title as job_title
       FROM vendor_job_bids vjb
       JOIN jobs_posted jp ON jp.id = vjb.job_id
       WHERE vjb.id = $1`,
      [bidId]
    );
    if (bidRes.rows.length === 0) throw new AppError('Bid not found', 404);
    const bid = bidRes.rows[0];
    if (bid.landlord_id !== landlordId) throw new AppError('Not authorized', 403);
    if (bid.status !== 'pending') throw new AppError('Bid is no longer pending', 400);

    // Accept the bid — trigger handles the rest
    await query(
      `UPDATE vendor_job_bids SET status = 'accepted' WHERE id = $1`,
      [bidId]
    );

    // Send notifications
    await NotificationService.createBidStatusUpdate(bid.vendor_id, bid.job_id, bid.job_title, 'accepted');
    await NotificationService.createJobAssignmentConfirmation(bid.vendor_id, bid.job_id, bid.job_title, 'vendor');
    await NotificationService.createJobAssignmentConfirmation(landlordId, bid.job_id, bid.job_title, 'landlord');

    return { accepted: true, bidId, jobId: bid.job_id };
  }

  /**
   * Landlord rejects a specific bid
   */
    // Landlord rejects a specific bid (allow regardless of current status)
    static async rejectBid(bidId: string, landlordId: string) {
        const bidRes = await query(
          `SELECT vjb.*, jp.landlord_id, jp.title as job_title
           FROM vendor_job_bids vjb
           JOIN jobs_posted jp ON jp.id = vjb.job_id
           WHERE vjb.id = $1`,
          [bidId]
        );
        if (bidRes.rows.length === 0) throw new AppError('Bid not found', 404);
        const bid = bidRes.rows[0];
        if (bid.landlord_id !== landlordId) throw new AppError('Not authorized', 403);
        // Directly set to rejected (idempotent)
        await query(`UPDATE vendor_job_bids SET status = 'rejected' WHERE id = $1`, [bidId]);
        await NotificationService.createBidStatusUpdate(bid.vendor_id, bid.job_id, bid.job_title, 'rejected');
        return { rejected: true, bidId };
    }

  /**
   * Admin: get all jobs across all landlords
   */
  static async getAllForAdmin(page = 1, limit = 20) {
    const offset = (page - 1) * limit;
    const res = await query(
      `SELECT jp.*, p.name as property_name,
         json_build_object('id', u.id, 'display_name', u.display_name) as landlord,
         (SELECT COUNT(*) FROM vendor_job_bids vjb WHERE vjb.job_id = jp.id) as bid_count
       FROM jobs_posted jp
       LEFT JOIN properties p ON p.id = jp.property_id
       JOIN users u ON u.id = jp.landlord_id
       ORDER BY jp.created_at DESC
       LIMIT $1 OFFSET $2`,
      [limit, offset]
    );
    const countRes = await query('SELECT COUNT(*) FROM jobs_posted');
    return {
      data: res.rows,
      meta: { total: parseInt(countRes.rows[0].count, 10), page, limit },
    };
  }
}
