import { query, withTransaction } from '../db';
import { AppError } from '../middleware/errorHandler';

export class LeaseService {
  static async create(data: any, landlordId: string) {
    return withTransaction(async (client) => {
      const unitRes = await client.query('SELECT status, property_id FROM units WHERE id = $1', [data.unitId]);
      if (unitRes.rows.length === 0) throw new AppError('Unit not found', 404);
      if (unitRes.rows[0].status !== 'vacant') throw new AppError('Unit is not available', 400);

      // Verify landlord has completed payment onboarding
      const landlordRes = await client.query('SELECT payment_onboarded FROM users WHERE id = $1', [landlordId]);
      if (landlordRes.rows.length === 0) throw new AppError('Landlord not found', 404);
      if (!landlordRes.rows[0].payment_onboarded) throw new AppError('Landlord has not completed payment onboarding', 400);

      const leaseRes = await client.query(
        `INSERT INTO leases (tenant_id, unit_id, property_id, landlord_id, start_date, end_date, rent_amount, deposit_amount, payment_schedule, auto_renew, status)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, 'draft') RETURNING *`,
        [data.tenantId, data.unitId, unitRes.rows[0].property_id, landlordId, data.startDate, data.endDate, data.rentAmount, data.depositAmount, data.paymentSchedule, data.autoRenew]
      );
      return leaseRes.rows[0];
    });
  }

  static async getById(id: string) {
    const res = await query('SELECT * FROM leases WHERE id = $1', [id]);
    if (res.rows.length === 0) throw new AppError('Lease not found', 404);
    return res.rows[0];
  }

  static async updateStatus(id: string, status: string) {
    const res = await query(
      'UPDATE leases SET status = $1, updated_at = NOW() WHERE id = $2 RETURNING *',
      [status, id]
    );
    if (res.rows.length === 0) throw new AppError('Lease not found', 404);
    return res.rows[0];
  }

  static async getDashboard(userId: string, role: string) {
    let sql = '';
    let params: any[] = [userId];
    if (role === 'tenant') {
      sql = `SELECT l.*, p.name as property_name, u.unit_number FROM leases l
             JOIN properties p ON p.id = l.property_id
             JOIN units u ON u.id = l.unit_id
             WHERE l.tenant_id = $1 AND l.status IN ('active','expiring')`;
    } else {
      sql = `SELECT l.*, p.name as property_name, u.unit_number, 
                    (SELECT COUNT(*) FROM rent_payments WHERE lease_id = l.id AND status = 'pending') as pending_payments
             FROM leases l
             JOIN properties p ON p.id = l.property_id
             JOIN units u ON u.id = l.unit_id
             WHERE l.landlord_id = $1`;
    }
    const res = await query(sql, params);
    return res.rows.map(row => ({
      ...row,
      tenant: { id: row.tenant_id }
    }));
  }

  static async getExpiringSoon(landlordId: string) {
    const res = await query(
      `SELECT l.*, u.unit_number, p.name as property_name, 
              (l.end_date - CURRENT_DATE) as days_left
       FROM leases l
       JOIN units u ON u.id = l.unit_id
       JOIN properties p ON p.id = l.property_id
       WHERE l.landlord_id = $1 
         AND l.status = 'active'
         AND (l.end_date - CURRENT_DATE) <= l.renewal_notice_days
       ORDER BY days_left ASC`,
      [landlordId]
    );
    return res.rows;
  }

  static async renewLease(leaseId: string, landlordId: string, data: any) {
    return withTransaction(async (client) => {
      const leaseRes = await client.query('SELECT * FROM leases WHERE id = $1 AND landlord_id = $2', [leaseId, landlordId]);
      if (leaseRes.rows.length === 0) throw new AppError('Lease not found', 404);
      const lease = leaseRes.rows[0];

      await client.query('UPDATE leases SET status = $1, updated_at = NOW() WHERE id = $2', ['renewed', leaseId]);
      
      const newEndDate = data.end_date || data.endDate;
      if (!newEndDate) throw new AppError('end_date is required for renewal', 400);

      const newStartDate = data.start_date || data.startDate || lease.end_date;
      const newRentAmount = data.rent_amount || data.rentAmount || lease.rent_amount;
      const newDepositAmount = data.deposit_amount || data.depositAmount || lease.deposit_amount;
      const newPaymentSchedule = data.payment_schedule || data.paymentSchedule || lease.payment_schedule;
      const newAutoRenew = data.auto_renew !== undefined ? data.auto_renew : (data.autoRenew !== undefined ? data.autoRenew : lease.auto_renew);

      const newLeaseRes = await client.query(
        `INSERT INTO leases (tenant_id, unit_id, property_id, landlord_id, start_date, end_date, rent_amount, deposit_amount, payment_schedule, auto_renew, status)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, 'active') RETURNING *`,
        [lease.tenant_id, lease.unit_id, lease.property_id, landlordId, newStartDate, newEndDate, newRentAmount, newDepositAmount, newPaymentSchedule, newAutoRenew]
      );
      return newLeaseRes.rows[0];
    });
  }

  static async getInspections(leaseId: string) {
    const res = await query(
      `SELECT inspection_id, type, status, to_char(inspection_date, 'YYYY-MM-DD') as inspection_date, inspector_name, total_items_checked, flagged_issues, pdf_report_url 
       FROM inspections WHERE lease_id = $1 ORDER BY created_at DESC`, [leaseId]
    );
    return res.rows;
  }

  static async submitInspection(leaseId: string, data: any, userId: string) {
    const inspectionId = `insp_${Math.floor(Math.random() * 1000).toString().padStart(3, '0')}`;
    const totalItems = data.checklist_data ? data.checklist_data.length : 0;
    const flagged = data.checklist_data ? data.checklist_data.filter((i: any) => i.condition !== 'GOOD').length : 0;
    const inspectionDate = new Date().toISOString().split('T')[0];

    const res = await query(
      `INSERT INTO inspections (lease_id, inspection_id, type, inspection_date, inspector_name, total_items_checked, flagged_issues, checklist_data, landlord_signature, tenant_signature)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10) RETURNING *`,
      [leaseId, inspectionId, data.inspection_type, inspectionDate, data.inspector_role === 'LANDLORD' ? 'Admin' : 'Inspector', totalItems, flagged, JSON.stringify(data.checklist_data), data.landlord_signature || null, data.tenant_signature || null]
    );
    
    // Simulating PDF generation URL
    const pdfUrl = `https://api.propadmin.com/reports/${inspectionId}.pdf`;
    await query(`UPDATE inspections SET pdf_report_url = $1 WHERE id = $2`, [pdfUrl, res.rows[0].id]);
    
    return { ...res.rows[0], pdf_report_url: pdfUrl };
  }
}
