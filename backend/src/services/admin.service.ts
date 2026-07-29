import { query, withTransaction } from '../db';
import { AppError } from '../middleware/errorHandler';

export class AdminService {
  static async getDashboardStats(period?: string) {
    let dateConstraint = "1=1"; // default no date constraint or we can use 1=1
    let interval = "1 year";
    let chartDays = 7;
    let chartStep = "1 day";

    if (period === 'Last 7 Days') {
      dateConstraint = "created_at >= CURRENT_DATE - INTERVAL '7 days'";
      interval = "7 days";
      chartDays = 7;
      chartStep = "1 day";
    } else if (period === 'Last 30 Days') {
      dateConstraint = "created_at >= CURRENT_DATE - INTERVAL '30 days'";
      interval = "30 days";
      chartDays = 30;
      chartStep = "5 days";
    } else if (period === 'Last 41 Days') {
      dateConstraint = "created_at >= CURRENT_DATE - INTERVAL '41 days'";
      interval = "41 days";
      chartDays = 41;
      chartStep = "7 days";
    } else if (period === 'Last 90 Days') {
      dateConstraint = "created_at >= CURRENT_DATE - INTERVAL '90 days'";
      interval = "90 days";
      chartDays = 90;
      chartStep = "15 days";
    } else if (period === 'This Year') {
      dateConstraint = "created_at >= DATE_TRUNC('year', CURRENT_DATE)";
      interval = "1 year";
      chartDays = 365;
      chartStep = "1 month";
    }

    // Fallback if dateConstraint not in table (e.g., users table uses created_at)
    const usersRes = await query(`SELECT COUNT(*) as total FROM users WHERE ${dateConstraint}`);
    
    // For user_roles, created_at is not standard, let's just use users table join or ignore date filter for roles
    // We will just filter users for vendors
    const vendorsRes = await query(`SELECT COUNT(u.id) as total FROM users u JOIN user_roles ur ON ur.user_id = u.id WHERE ur.role = 'vendor' AND ( ${dateConstraint.replace('created_at', 'u.created_at')} )`);
    const propertiesRes = await query(`SELECT COUNT(*) as total FROM properties WHERE status = 'active' AND ${dateConstraint}`);
    const revenueRes = await query(`SELECT COALESCE(SUM(amount), 0) as total FROM transactions WHERE status = 'completed' AND ${dateConstraint}`);
    const pendingVerificationsRes = await query(`SELECT COUNT(*) as total FROM verification_cases WHERE status = 'pending_review' AND ${dateConstraint}`);
    const fraudAlertsRes = await query(`SELECT COUNT(*) as total FROM users WHERE fraud_score >= 50 AND ${dateConstraint}`);

    const regionalRes = await query(`
      SELECT 
        r.code,
        r.name,
        COUNT(u.id) as managed_units,
        COALESCE(AVG(CASE WHEN u.status = 'occupied' THEN 100 ELSE 0 END), 0) as occupancy_rate,
        COALESCE(AVG(u.rent_amount), 0) as avg_rent,
        COALESCE(SUM(t.amount), 0) as revenue_cont
      FROM regions r
      LEFT JOIN properties p ON p.region_id = r.id
      LEFT JOIN units u ON u.property_id = p.id
      LEFT JOIN transactions t ON t.property_id = p.id AND t.status = 'completed'
      GROUP BY r.id
      ORDER BY revenue_cont DESC
    `);

    // Chart data based on period
    // Since generating dynamic chart labels in SQL with different intervals can be tricky, we'll fetch daily/monthly data and aggregate in JS or SQL.
    // For simplicity, we'll keep the previous 6-month chart if period is missing or 'This Year', else we build a simpler query.
    let chartRes;
    
    if (period === 'This Year' || !period) {
      chartRes = await query(`
        SELECT 
          TO_CHAR(DATE_TRUNC('month', CURRENT_DATE - (i || ' months')::interval), 'Mon') as label,
          COALESCE(
            (SELECT COUNT(*) FROM users u WHERE DATE_TRUNC('month', u.created_at) = DATE_TRUNC('month', CURRENT_DATE - (i || ' months')::interval)), 
            0
          ) as users,
          COALESCE(
            (SELECT SUM(amount) FROM transactions t WHERE t.status = 'completed' AND DATE_TRUNC('month', t.created_at) = DATE_TRUNC('month', CURRENT_DATE - (i || ' months')::interval)), 
            0
          ) as revenue
        FROM generate_series(6, 0, -1) as i
      `);
    } else {
      // Dynamic days query for Last 7, 30, 41, 90 Days
      chartRes = await query(`
        SELECT 
          TO_CHAR(CURRENT_DATE - (i || ' days')::interval, 'DD Mon') as label,
          COALESCE(
            (SELECT COUNT(*) FROM users u WHERE DATE_TRUNC('day', u.created_at) = DATE_TRUNC('day', CURRENT_DATE - (i || ' days')::interval)), 
            0
          ) as users,
          COALESCE(
            (SELECT SUM(amount) FROM transactions t WHERE t.status = 'completed' AND DATE_TRUNC('day', t.created_at) = DATE_TRUNC('day', CURRENT_DATE - (i || ' days')::interval)), 
            0
          ) as revenue
        FROM generate_series($1::int, 0, -1) as i
      `, [chartDays - 1]);
    }
    
    // Fetch payment snapshot
    const paymentStats = await query(`
      SELECT 
        COUNT(CASE WHEN status = 'completed' THEN 1 END) as successful,
        COUNT(CASE WHEN status = 'failed' THEN 1 END) as failed,
        COUNT(CASE WHEN status = 'refunded' OR status = 'disputed' THEN 1 END) as chargebacks,
        COUNT(*) as total
      FROM transactions WHERE ${dateConstraint}
    `);

    const pStatsRow = paymentStats.rows[0];
    const totalPayments = parseInt(pStatsRow.total) || 1;
    const paymentPercentages = {
      successful: Math.round((parseInt(pStatsRow.successful) / totalPayments) * 100) || 0,
      failed: Math.round((parseInt(pStatsRow.failed) / totalPayments) * 100) || 0,
      chargebacks: Math.round((parseInt(pStatsRow.chargebacks) / totalPayments) * 100) || 0,
    };

    return {
      totalUsers: parseInt(usersRes.rows[0]?.total || 0, 10),
      activeVendors: parseInt(vendorsRes.rows[0]?.total || 0, 10),
      totalProperties: parseInt(propertiesRes.rows[0]?.total || 0, 10),
      monthlyRevenue: parseFloat(revenueRes.rows[0]?.total || 0),
      pendingVerifications: parseInt(pendingVerificationsRes.rows[0]?.total || 0, 10),
      fraudAlerts: parseInt(fraudAlertsRes.rows[0]?.total || 0, 10),
      regional_performance: regionalRes.rows,
      chartData: {
        labels: chartRes.rows.map((r: any) => r.label),
        users: chartRes.rows.map((r: any) => parseInt(r.users, 10)),
        revenue: chartRes.rows.map((r: any) => parseFloat(r.revenue))
      },
      paymentSnapshot: paymentPercentages
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
    params.push(filters.limit || 50, (filters.page || 1 - 1) * (filters.limit || 50));
    const res = await query(sql, params);
    return res.rows;
  }

  static async getAuditStats() {
    const res = await query(`
      SELECT 
        COUNT(*) as total_events,
        SUM(CASE WHEN action ILIKE '%admin%' OR action ILIKE '%update_user%' THEN 1 ELSE 0 END) as admin_actions,
        SUM(CASE WHEN action ILIKE '%pay%' THEN 1 ELSE 0 END) as payments,
        SUM(CASE WHEN action ILIKE '%user%' AND action NOT ILIKE '%update_user%' THEN 1 ELSE 0 END) as user_changes,
        SUM(CASE WHEN action ILIKE '%login%' OR action ILIKE '%security%' THEN 1 ELSE 0 END) as security_alerts
      FROM audit_logs
    `);
    
    // Fallback to 0 if null
    const row = res.rows[0] || {};
    return {
      total_events: parseInt(row.total_events || '0', 10),
      admin_actions: parseInt(row.admin_actions || '0', 10),
      payments: parseInt(row.payments || '0', 10),
      user_changes: parseInt(row.user_changes || '0', 10),
      security_alerts: parseInt(row.security_alerts || '0', 10)
    };
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
      "UPDATE verification_cases SET status = $1, assigned_admin_id = $2, reviewed_at = NOW(), risk_flags = COALESCE(risk_flags, '[]'::jsonb) || $3 WHERE id = $4",
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
}
