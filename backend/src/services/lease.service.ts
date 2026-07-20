import { query, withTransaction } from '../db';
import { AppError } from '../middleware/errorHandler';

export class LeaseService {
  static async create(data: any, landlordId: string) {
    return withTransaction(async (client) => {
      const unitRes = await client.query('SELECT status, property_id FROM units WHERE id = $1', [data.unitId]);
      if (unitRes.rows.length === 0) throw new AppError('Unit not found', 404);
      if (unitRes.rows[0].status !== 'vacant') throw new AppError('Unit is not available', 400);

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
    return res.rows;
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

  static async renewLease(leaseId: string, landlordId: string, newEndDate: string) {
    return withTransaction(async (client) => {
      const leaseRes = await client.query('SELECT * FROM leases WHERE id = $1 AND landlord_id = $2', [leaseId, landlordId]);
      if (leaseRes.rows.length === 0) throw new AppError('Lease not found', 404);
      const lease = leaseRes.rows[0];

      await client.query('UPDATE leases SET status = $1, updated_at = NOW() WHERE id = $2', ['renewed', leaseId]);
      const newLeaseRes = await client.query(
        `INSERT INTO leases (tenant_id, unit_id, property_id, landlord_id, start_date, end_date, rent_amount, deposit_amount, payment_schedule, auto_renew, status)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, 'active') RETURNING *`,
        [lease.tenant_id, lease.unit_id, lease.property_id, landlordId, lease.end_date, newEndDate, lease.rent_amount, lease.deposit_amount, lease.payment_schedule, lease.auto_renew]
      );
      return newLeaseRes.rows[0];
    });
  }

  static async updateStatus(id: string, status: string, landlordId: string) {
    const res = await query(
      'UPDATE leases SET status = $1, updated_at = NOW() WHERE id = $2 AND landlord_id = $3 RETURNING *',
      [status, id, landlordId]
    );
    if (res.rows.length === 0) throw new AppError('Lease not found or access denied', 404);
    return res.rows[0];
  }
}
