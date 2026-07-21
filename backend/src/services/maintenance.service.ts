import { query, withTransaction } from '../db';
import { AppError } from '../middleware/errorHandler';

export class MaintenanceService {
  static async createWorkOrder(data: any, landlordId: string) {
    const unitRes = await query('SELECT property_id FROM units WHERE id = $1', [data.unitId]);
    if (unitRes.rows.length === 0) throw new AppError('Unit not found', 404);

    const status = data.assignedVendorId ? 'scheduled' : 'open';

    const res = await query(
      `INSERT INTO work_orders (property_id, unit_id, tenant_id, landlord_id, title, description, category, priority, budget_min, budget_max, currency, access_instructions, notify_tenant, notify_vendor, assigned_vendor_id, scheduled_date, status)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17) RETURNING *`,
      [
        unitRes.rows[0].property_id, data.unitId, data.tenantId || null, landlordId,
        data.title, data.description, data.category, data.priority,
        data.budgetMin || null, data.budgetMax || null, data.currency || 'USD',
        data.accessInstructions || null, data.notifyTenant !== false, data.notifyVendor !== false,
        data.assignedVendorId || null, data.scheduledDate || null, status
      ]
    );
    return res.rows[0];
  }

  static async getWorkOrders(userId: string, role: string, filters: any) {
    let sql = `SELECT wo.*, p.name as property_name, u.unit_number, 
                      (SELECT COUNT(*) FROM bids WHERE work_order_id = wo.id AND status = 'pending') as bid_count
               FROM work_orders wo
               JOIN properties p ON p.id = wo.property_id
               JOIN units u ON u.id = wo.unit_id
               WHERE 1=1`;
    const params: any[] = [];
    let idx = 1;

    if (role === 'landlord') { sql += ` AND wo.landlord_id = $${idx++}`; params.push(userId); }
    else if (role === 'tenant') { sql += ` AND wo.tenant_id = $${idx++}`; params.push(userId); }
    else if (role === 'vendor') { sql += ` AND (wo.assigned_vendor_id = $${idx++} OR wo.status = 'open')`; params.push(userId); }

    if (filters.status) { sql += ` AND wo.status = $${idx++}`; params.push(filters.status); }
    if (filters.priority) { sql += ` AND wo.priority = $${idx++}`; params.push(filters.priority); }
    if (filters.category) { sql += ` AND wo.category = $${idx++}`; params.push(filters.category); }

    sql += ` ORDER BY wo.created_at DESC`;
    const res = await query(sql, params);
    return res.rows;
  }

  static async getById(id: string) {
    const woRes = await query('SELECT * FROM work_orders WHERE id = $1', [id]);
    if (woRes.rows.length === 0) throw new AppError('Work order not found', 404);
    const bidsRes = await query('SELECT b.*, u.display_name as vendor_name FROM bids b JOIN users u ON u.id = b.vendor_id WHERE b.work_order_id = $1 ORDER BY b.amount ASC', [id]);
    const partsRes = await query(
      `SELECT wip.*, i.name as item_name, i.sku FROM work_order_parts wip
       JOIN inventory_items i ON i.id = wip.inventory_item_id
       WHERE wip.work_order_id = $1`, [id]
    );
    return { ...woRes.rows[0], bids: bidsRes.rows, parts: partsRes.rows };
  }

  static async submitBid(workOrderId: string, vendorId: string, data: any) {
    return withTransaction(async (client) => {
      const woRes = await client.query('SELECT currency, status FROM work_orders WHERE id = $1', [workOrderId]);
      if (woRes.rows.length === 0) throw new AppError('Work order not found', 404);
      if (woRes.rows[0].status !== 'open') throw new AppError('Bidding is closed for this work order', 400);
      if (woRes.rows[0].currency !== data.currency) throw new AppError('Bid currency must match work order currency', 400);

      const bidRes = await client.query(
        `INSERT INTO bids (work_order_id, vendor_id, amount, currency, message, estimated_hours, proposed_date, is_fixed_price)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *`,
        [workOrderId, vendorId, data.amount, data.currency, data.message || null, data.estimatedHours || null, data.proposedDate, data.isFixedPrice || false]
      );
      return bidRes.rows[0];
    });
  }

  static async acceptBid(bidId: string, landlordId: string) {
    const bidRes = await query('SELECT * FROM bids WHERE id = $1', [bidId]);
    if (bidRes.rows.length === 0) throw new AppError('Bid not found', 404);
    const bid = bidRes.rows[0];

    const woRes = await query('SELECT landlord_id FROM work_orders WHERE id = $1', [bid.work_order_id]);
    if (woRes.rows[0].landlord_id !== landlordId) throw new AppError('Not authorized', 403);

    await query('UPDATE bids SET status = $1 WHERE id = $2', ['accepted', bidId]);
    return { accepted: true };
  }

  static async updateStatus(workOrderId: string, status: string, userId: string) {
    const validTransitions: Record<string, string[]> = {
      open: ['scheduled', 'cancelled'],
      scheduled: ['in_progress', 'cancelled'],
      in_progress: ['waiting_parts', 'completed'],
      waiting_parts: ['in_progress', 'completed'],
    };
    const woRes = await query('SELECT status, landlord_id, assigned_vendor_id FROM work_orders WHERE id = $1', [workOrderId]);
    if (woRes.rows.length === 0) throw new AppError('Work order not found', 404);
    const current = woRes.rows[0].status;
    if (!validTransitions[current]?.includes(status)) throw new AppError(`Invalid transition from ${current} to ${status}`, 400);

    await query('UPDATE work_orders SET status = $1, updated_at = NOW() WHERE id = $2', [status, workOrderId]);
    return { updated: true };
  }

  static async getVendorJobs(vendorId: string, status?: string) {
    let sql = `SELECT wo.*, p.name as property_name, u.unit_number FROM work_orders wo
               JOIN properties p ON p.id = wo.property_id
               JOIN units u ON u.id = wo.unit_id
               WHERE wo.assigned_vendor_id = $1`;
    const params: any[] = [vendorId];
    if (status) { sql += ` AND wo.status = $2`; params.push(status); }
    sql += ` ORDER BY wo.scheduled_date ASC`;
    const res = await query(sql, params);
    return res.rows;
  }
}
