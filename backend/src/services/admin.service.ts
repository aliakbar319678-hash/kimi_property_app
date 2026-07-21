import { query, withTransaction } from '../db';
import { AppError } from '../middleware/errorHandler';
import { NotificationService } from './notification.service';

export class AdminService {
  static async getDashboardStats() {
    const usersRes = await query('SELECT COUNT(*) as total FROM users WHERE is_active = true');
    const vendorsRes = await query("SELECT COUNT(*) as total FROM user_roles WHERE role = 'vendor'");
    const propertiesRes = await query("SELECT COUNT(*) as total FROM properties WHERE status = 'active'");
    const revenueRes = await query("SELECT COALESCE(SUM(amount), 0) as total FROM transactions WHERE status = 'completed' AND created_at >= DATE_TRUNC('month', CURRENT_DATE)");
    const pendingVerificationsRes = await query("SELECT COUNT(*) as total FROM verification_cases WHERE status = 'pending_review'");
    const fraudAlertsRes = await query('SELECT COUNT(*) as total FROM users WHERE fraud_score >= 50');

    return {
      totalUsers: parseInt(usersRes.rows[0].total, 10),
      activeVendors: parseInt(vendorsRes.rows[0].total, 10),
      totalProperties: parseInt(propertiesRes.rows[0].total, 10),
      monthlyRevenue: parseFloat(revenueRes.rows[0].total),
      pendingVerifications: parseInt(pendingVerificationsRes.rows[0].total, 10),
      fraudAlerts: parseInt(fraudAlertsRes.rows[0].total, 10),
    };
  }

  static async getAuditLogs(filters: any) {
    let sql = `SELECT a.*, u.email as user_email, u.display_name as user_name FROM audit_logs a
               LEFT JOIN users u ON u.id = a.user_id WHERE 1=1`;
    const params: any[] = [];
    let idx = 1;
    if (filters.userId) { sql += ` AND a.user_id = $${idx++}`; params.push(filters.userId); }
    if (filters.action) { sql += ` AND a.action = $${idx++}`; params.push(filters.action); }
    if (filters.entityType) { sql += ` AND a.entity_type = $${idx++}`; params.push(filters.entityType); }
    if (filters.startDate) { sql += ` AND a.created_at >= $${idx++}`; params.push(filters.startDate); }
    if (filters.endDate) { sql += ` AND a.created_at <= $${idx++}`; params.push(filters.endDate); }
    sql += ` ORDER BY a.created_at DESC LIMIT $${idx++} OFFSET $${idx++}`;
    params.push(filters.limit || 50, ((parseInt(filters.page) || 1) - 1) * (parseInt(filters.limit) || 50));
    const res = await query(sql, params);
    return res.rows;
  }

  static async getVerificationQueue(status?: string) {
    let sql = `SELECT vc.*, u.email, u.display_name, u.fraud_score FROM verification_cases vc
               JOIN users u ON u.id = vc.user_id WHERE 1=1`;
    const params: any[] = [];
    if (status) { sql += ` AND vc.status = $1`; params.push(status); }
    sql += ` ORDER BY vc.created_at DESC`;
    const res = await query(sql, params);
    return res.rows;
  }

  static async reviewVerification(caseId: string, adminId: string, decision: 'approved' | 'rejected', notes?: string) {
    const caseRes = await query('SELECT * FROM verification_cases WHERE id = $1', [caseId]);
    if (caseRes.rows.length === 0) throw new AppError('Case not found', 404);

    const newStatus = decision === 'approved' ? 'approved' : 'rejected';
    await query(
      `UPDATE verification_cases SET status = $1, assigned_admin_id = $2, reviewed_at = NOW(), risk_flags = COALESCE(risk_flags, '[]'::jsonb) || $3 WHERE id = $4`,
      [newStatus, adminId, JSON.stringify([{ note: notes, reviewed_by: adminId, at: new Date().toISOString() }]), caseId]
    );
    await query('UPDATE users SET kyc_status = $1 WHERE id = $2', [newStatus, caseRes.rows[0].user_id]);
    return { reviewed: true };
  }

  static async suspendUser(userId: string, adminId: string, reason: string) {
    await query('UPDATE users SET is_active = false, kyc_status = $1 WHERE id = $2', ['suspended', userId]);
    await query(
      `INSERT INTO audit_logs (user_id, user_role, action, entity_type, entity_id, details, created_at)
       VALUES ($1, $2, $3, $4, $5, $6, NOW())`,
      [adminId, 'super_admin', 'SUSPENDED', 'user', userId, JSON.stringify({ reason })]
    );
    return { suspended: true };
  }

  static async getSystemHealth() {
    const res = await query('SELECT * FROM system_health ORDER BY checked_at DESC LIMIT 10');
    return res.rows;
  }

  static async rejectProperty(propertyId: string, adminId: string, reason: string, deadline: Date) {
    const propRes = await query('SELECT * FROM properties WHERE id = $1', [propertyId]);
    if (propRes.rows.length === 0) throw new AppError('Property not found', 404);
    
    const property = propRes.rows[0];
    
    await query(
      `UPDATE properties
       SET status = 'rejected',
           rejection_reason = $1,
           rejection_deadline = $2,
           rejection_warning_sent = false,
           updated_at = NOW()
       WHERE id = $3`,
      [reason, deadline, propertyId]
    );

    // Send Notification to landlord
    await NotificationService.create({
      userId: property.landlord_id,
      type: 'system',
      title: 'Property Verification Rejected',
      message: `Your property "${property.name}" was rejected. Reason: "${reason}". Please fix it by ${new Date(deadline).toISOString()} to avoid archiving.`,
      priority: 'high',
      channels: ['in_app'],
    });

    // Add entry to audit logs
    await query(
      `INSERT INTO audit_logs (user_id, user_role, action, entity_type, entity_id, details, created_at)
       VALUES ($1, $2, $3, $4, $5, $6, NOW())`,
      [adminId, 'admin', 'REJECT_PROPERTY', 'property', propertyId, JSON.stringify({ reason, deadline })]
    );

    return { success: true };
  }
  static async requestRevisionProperty(propertyId: string, adminId: string, reason: string, requestedDocuments: string) {
    const propRes = await query('SELECT * FROM properties WHERE id = $1', [propertyId]);
    if (propRes.rows.length === 0) throw new AppError('Property not found', 404);
    
    const property = propRes.rows[0];
    const historyEntry = { action: 'request_revision', reason, requested_documents: requestedDocuments, by: adminId, timestamp: new Date().toISOString() };
    
    await query(
      `UPDATE properties
       SET verification_status = 'needs_revision',
           rejection_reason = $1,
           requested_documents = $2,
           revision_history = COALESCE(revision_history, '[]'::jsonb) || $3::jsonb,
           updated_at = NOW()
       WHERE id = $4`,
      [reason, JSON.stringify(requestedDocuments), JSON.stringify([historyEntry]), propertyId]
    );

    // Send Notification
    await NotificationService.create({
      userId: property.landlord_id,
      type: 'system',
      title: 'Action Required: Property Needs Revision',
      message: `Your property "${property.name}" needs revision. Reason: ${reason}. Please update and resubmit.`,
      priority: 'high',
      channels: ['in_app'],
    });

    return { success: true };
  }

  static async permanentRejectProperty(propertyId: string, adminId: string, reason: string) {
    const propRes = await query('SELECT * FROM properties WHERE id = $1', [propertyId]);
    if (propRes.rows.length === 0) throw new AppError('Property not found', 404);
    
    const property = propRes.rows[0];
    const historyEntry = { action: 'permanent_reject', reason, by: adminId, timestamp: new Date().toISOString() };
    
    await query(
      `UPDATE properties
       SET verification_status = 'permanently_rejected',
           is_permanently_rejected = true,
           rejection_reason = $1,
           revision_history = COALESCE(revision_history, '[]'::jsonb) || $2::jsonb,
           updated_at = NOW()
       WHERE id = $3`,
      [reason, JSON.stringify([historyEntry]), propertyId]
    );

    // Send Notification
    await NotificationService.create({
      userId: property.landlord_id,
      type: 'system',
      title: 'Property Permanently Rejected',
      message: `Your property "${property.name}" has been permanently rejected. Reason: ${reason}.`,
      priority: 'high',
      channels: ['in_app'],
    });

    return { success: true };
  }

  static async approveProperty(propertyId: string, adminId: string) {
    const propRes = await query('SELECT * FROM properties WHERE id = $1', [propertyId]);
    if (propRes.rows.length === 0) throw new AppError('Property not found', 404);
    
    const property = propRes.rows[0];
    const historyEntry = { action: 'approve', by: adminId, timestamp: new Date().toISOString() };
    
    await query(
      `UPDATE properties
       SET verification_status = 'approved',
           revision_history = COALESCE(revision_history, '[]'::jsonb) || $1::jsonb,
           updated_at = NOW()
       WHERE id = $2`,
      [JSON.stringify([historyEntry]), propertyId]
    );

    // Send Notification
    await NotificationService.create({
      userId: property.landlord_id,
      type: 'system',
      title: 'Property Approved!',
      message: `Your property "${property.name}" has been verified and approved.`,
      priority: 'normal',
      channels: ['in_app'],
    });

    return { success: true };
  }
}
