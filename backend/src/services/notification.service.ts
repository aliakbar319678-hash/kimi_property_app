import { query } from '../db';
import { AppError } from '../middleware/errorHandler';

export class NotificationService {
  static async create(data: { userId: string; type: string; title: string; message: string; actionUrl?: string; actionType?: string; priority?: string; channels?: string[] }) {
    const res = await query(
      `INSERT INTO notifications (user_id, type, title, message, action_url, action_type, priority, channels, sent_at)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, NOW()) RETURNING *`,
      [data.userId, data.type, data.title, data.message, data.actionUrl || null, data.actionType || null, data.priority || 'normal', JSON.stringify(data.channels || ['in_app'])]
    );
    return res.rows[0];
  }

  static async getUnread(userId: string) {
    const res = await query(
      'SELECT * FROM notifications WHERE user_id = $1 AND is_read = false ORDER BY created_at DESC',
      [userId]
    );
    return res.rows;
  }

  static async getAll(userId: string, page: number = 1, limit: number = 20) {
    const offset = (page - 1) * limit;
    const res = await query(
      'SELECT * FROM notifications WHERE user_id = $1 ORDER BY created_at DESC LIMIT $2 OFFSET $3',
      [userId, limit, offset]
    );
    const countRes = await query('SELECT COUNT(*) FROM notifications WHERE user_id = $1', [userId]);
    return { data: res.rows, meta: { total: parseInt(countRes.rows[0].count, 10), page, limit } };
  }

  // New method to fetch all notifications for admin view
  static async getAllForAdmin(page: number = 1, limit: number = 20) {
    const offset = (page - 1) * limit;
    const res = await query(
      'SELECT * FROM notifications ORDER BY created_at DESC LIMIT $1 OFFSET $2',
      [limit, offset]
    );
    const countRes = await query('SELECT COUNT(*) FROM notifications');
    return { data: res.rows, meta: { total: parseInt(countRes.rows[0].count, 10), page, limit } };
  }

  static async markRead(userId: string, notificationId: string) {
    const res = await query(
      'UPDATE notifications SET is_read = true, read_at = NOW() WHERE id = $1 AND user_id = $2 RETURNING *',
      [notificationId, userId]
    );
    if (res.rows.length === 0) throw new AppError('Notification not found', 404);
    return res.rows[0];
  }

  static async markAllRead(userId: string) {
    await query('UPDATE notifications SET is_read = true, read_at = NOW() WHERE user_id = $1 AND is_read = false', [userId]);
    return { marked: true };
  }

  static async getUnreadCount(userId: string) {
    const res = await query('SELECT COUNT(*) FROM notifications WHERE user_id = $1 AND is_read = false', [userId]);
    return { count: parseInt(res.rows[0].count, 10) };
  }

  // ─── Domain-specific helpers ────────────────────────────────────────────────

  /** Staff account created (welcome) */
  static async createStaffWelcome(staffId: string, displayName: string, email: string, department: string, permissions: string[]) {
    const role = department ? `${department} Staff` : 'Staff';
    const perms = Array.isArray(permissions) && permissions.length > 0 ? permissions.join(', ') : 'standard';
    return this.create({
      userId: staffId,
      type: 'system',
      title: 'Welcome to the Team!',
      message: `Hi ${displayName}, your new ${role} account (${email}) has been created. You can now log in and access your ${perms} privileges.`,
      priority: 'normal',
      channels: ['in_app', 'email'],
    });
  }

  /** Ticket assigned to staff */
  static async createTicketAssigned(staffId: string, ticketId: string, ticketTitle: string) {
    return this.create({
      userId: staffId,
      type: 'maintenance',
      title: 'New Ticket Assigned',
      message: `You have been assigned ticket: "${ticketTitle}"`,
      actionUrl: `/staff/tickets/${ticketId}`,
      actionType: 'navigate',
      priority: 'high',
      channels: ['in_app', 'email'],
    });
  }

  /** New comment on a ticket */
  static async createNewComment(userId: string, ticketId: string, ticketTitle: string) {
    return this.create({
      userId,
      type: 'maintenance',
      title: 'New Comment on Your Ticket',
      message: `A new reply was posted on ticket: "${ticketTitle}"`,
      actionUrl: `/tickets/${ticketId}`,
      actionType: 'navigate',
      priority: 'normal',
      channels: ['in_app'],
    });
  }

  /** Payment entered hold */
  static async createPaymentHeld(vendorId: string, amount: number, releaseDate: Date, ticketId: string) {
    return this.create({
      userId: vendorId,
      type: 'payment',
      title: 'Payment on Hold',
      message: `$${amount.toFixed(2)} has been placed on a 5-day hold and will be released on ${releaseDate.toDateString()}.`,
      actionUrl: `/vendor/wallet`,
      actionType: 'navigate',
      priority: 'high',
      channels: ['in_app', 'email'],
    });
  }

  /** 1 day before payment release reminder */
  static async createHoldReleaseReminder(vendorId: string, amount: number, releaseDate: Date) {
    return this.create({
      userId: vendorId,
      type: 'payment',
      title: 'Payment Releasing Tomorrow',
      message: `$${amount.toFixed(2)} will be released to your available balance tomorrow (${releaseDate.toDateString()}).`,
      actionUrl: `/vendor/wallet`,
      actionType: 'navigate',
      priority: 'normal',
      channels: ['in_app', 'email'],
    });
  }

  /** Payment released from hold */
  static async createPaymentReleased(vendorId: string, netAmount: number) {
    return this.create({
      userId: vendorId,
      type: 'payment',
      title: 'Payment Released',
      message: `$${netAmount.toFixed(2)} has been added to your available balance.`,
      actionUrl: `/vendor/wallet`,
      actionType: 'navigate',
      priority: 'high',
      channels: ['in_app', 'email'],
    });
  }

  /** Hold cancelled */
  static async createHoldCancelled(vendorId: string, amount: number) {
    return this.create({
      userId: vendorId,
      type: 'payment',
      title: 'Payment Hold Cancelled',
      message: `The $${amount.toFixed(2)} payment hold has been cancelled.`,
      priority: 'high',
      channels: ['in_app', 'email'],
    });
  }

  /** Ticket auto-resolved/closed by cron */
  static async createTicketAutoClosed(vendorId: string, ticketTitle: string) {
    return this.create({
      userId: vendorId,
      type: 'maintenance',
      title: 'Ticket Auto-Closed',
      message: `Your ticket "${ticketTitle}" has been automatically closed after payment release.`,
      priority: 'low',
      channels: ['in_app'],
    });
  }

  // ─── Job & Bid Notifications ────────────────────────────────────────────────

  /** Sent to matching vendors when a landlord posts a job in their category */
  static async createJobPostedAlert(vendorId: string, jobId: string, jobTitle: string, category: string) {
    return this.create({
      userId: vendorId,
      type: 'job_posted',
      title: 'New Job Available in Your Category',
      message: `A new job "${jobTitle}" has been posted in the ${category.replace(/_/g, ' ')} category. Submit your bid now!`,
      actionUrl: `/vendor/jobs/open?id=${jobId}`,
      actionType: 'navigate',
      priority: 'high',
      channels: ['in_app', 'email'],
    });
  }

  /** Sent to vendor when their bid is accepted or rejected */
  static async createBidStatusUpdate(vendorId: string, jobId: string, jobTitle: string, status: 'accepted' | 'rejected') {
    const isAccepted = status === 'accepted';
    return this.create({
      userId: vendorId,
      type: 'bid_status',
      title: isAccepted ? '🎉 Your Bid Was Accepted!' : 'Bid Update',
      message: isAccepted
        ? `Congratulations! Your bid on "${jobTitle}" has been accepted. Check your Active Jobs.`
        : `Your bid on "${jobTitle}" was not selected this time.`,
      actionUrl: isAccepted ? `/vendor/active-jobs` : `/vendor/my-bids`,
      actionType: 'navigate',
      priority: isAccepted ? 'high' : 'normal',
      channels: isAccepted ? ['in_app', 'email'] : ['in_app'],
    });
  }

  /** Sent to both vendor and landlord when a bid is accepted (job assignment confirmation) */
  static async createJobAssignmentConfirmation(userId: string, jobId: string, jobTitle: string, role: 'vendor' | 'landlord') {
    return this.create({
      userId,
      type: 'job_assignment',
      title: 'Job Assignment Confirmed',
      message: role === 'vendor'
        ? `You have been assigned to "${jobTitle}". The job is now In Progress.`
        : `A vendor has been assigned to your job "${jobTitle}". It is now In Progress.`,
      actionUrl: role === 'vendor' ? `/vendor/active-jobs` : `/landlord/jobs/${jobId}`,
      actionType: 'navigate',
      priority: 'high',
      channels: ['in_app', 'email'],
    });
  }

  /** Sent to tenant when application gets conditional approval */
  static async createConditionalApprovalUpdate(tenantId: string, applicationId: string, conditionTags: string[], note?: string) {
    const tagLabels: Record<string, string> = {
      higher_security_deposit: 'Higher security deposit required',
      co_signer_required: 'Co-signer/guarantor required',
      additional_income_docs: 'Additional income documentation needed',
      secondary_screening: 'Conditional on passing secondary screening',
      short_term_lease_only: 'Short-term lease only',
      resolve_issues_before_move_in: 'Tenant must resolve specific issues before move-in',
    };
    const conditionList = conditionTags.map((t) => tagLabels[t] || t).join('; ');
    return this.create({
      userId: tenantId,
      type: 'conditional_approval',
      title: 'Application Conditionally Approved',
      message: `Your application has been conditionally approved. Conditions: ${conditionList}.${note ? ` Note: ${note}` : ''}`,
      actionUrl: `/tenant/applications/${applicationId}`,
      actionType: 'navigate',
      priority: 'high',
      channels: ['in_app', 'email'],
    });
  }
  // ─── Payment & Lease Notifications ──────────────────────────────────────────

  /** Lease is expiring in 4 days and tenant has no saved cards */
  static async createLeaseExpiryNoCardAlert(userId: string) {
    return this.create({
      userId,
      type: 'lease_expiry',
      title: 'Action Required: Add Payment Method',
      message: 'Your lease is expiring in 4 days. Please add a new card to ensure smooth processing.',
      actionUrl: '/tenant/wallet',
      actionType: 'navigate',
      priority: 'high',
      channels: ['in_app', 'email'],
    });
  }

  /** Payment failed and no fallback cards worked */
  static async createPaymentFailedAlert(userId: string) {
    return this.create({
      userId,
      type: 'payment_failed',
      title: 'Payment Failed',
      message: 'Your payment failed. Please add a new card and submit your payment.',
      actionUrl: '/tenant/wallet',
      actionType: 'navigate',
      priority: 'high',
      channels: ['in_app', 'email'],
    });
  }

  /** Payment failed on default card, but succeeded on a backup card */
  static async createPaymentFallbackSuccess(userId: string) {
    return this.create({
      userId,
      type: 'payment_success',
      title: 'Payment Successful',
      message: 'Your payment was successful using your backup card. This card has now been set as your default.',
      actionUrl: '/tenant/wallet',
      actionType: 'navigate',
      priority: 'normal',
      channels: ['in_app', 'email'],
    });
  }

  // ─── LMS Notifications ───────────────────────────────────────────────

  /** Sent to student when they enroll in a course */
  static async createCourseEnrolled(userId: string, courseId: string, courseName: string) {
    return this.create({
      userId,
      type: 'lms_enrollment',
      title: 'Course Enrollment Successful',
      message: `You have successfully enrolled in "${courseName}". Start learning now!`,
      actionUrl: `/user/lms/classroom/${courseId}`,
      actionType: 'navigate',
      priority: 'normal',
      channels: ['in_app'],
    });
  }

  /** Sent to student when a certificate is issued */
  static async createCertificateIssued(userId: string, courseName: string) {
    return this.create({
      userId,
      type: 'lms_certificate',
      title: 'Certificate Issued',
      message: `Congratulations! Your certificate for "${courseName}" has been issued.`,
      actionUrl: `/user/lms/certificates`,
      actionType: 'navigate',
      priority: 'high',
      channels: ['in_app', 'email'],
    });
  }
}
