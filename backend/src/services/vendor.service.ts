import { query } from '../db';

export class VendorService {
  static async getMyBids(vendorId: string, status?: string) {
    let sql = `SELECT b.*, wo.title as work_order_title, wo.category, wo.priority, wo.status as work_order_status,
                      p.name as property_name, u.unit_number
               FROM bids b
               JOIN work_orders wo ON wo.id = b.work_order_id
               JOIN properties p ON p.id = wo.property_id
               JOIN units u ON u.id = wo.unit_id
               WHERE b.vendor_id = $1`;
    const params: any[] = [vendorId];
    if (status) { sql += ` AND b.status = $2`; params.push(status); }
    sql += ` ORDER BY b.created_at DESC`;
    const res = await query(sql, params);
    return res.rows;
  }

  static async getVendorStats(vendorId: string) {
    const totalBidsRes = await query('SELECT COUNT(*) FROM bids WHERE vendor_id = $1', [vendorId]);
    const acceptedBidsRes = await query("SELECT COUNT(*) FROM bids WHERE vendor_id = $1 AND status = 'accepted'", [vendorId]);
    const totalEarningsRes = await query(
      "SELECT COALESCE(SUM(final_amount), 0) FROM job_assignments WHERE vendor_id = $1 AND status = 'completed'",
      [vendorId]
    );
    const avgRatingRes = await query(
      `SELECT AVG(rating) FROM vendor_reviews WHERE vendor_id = $1`,
      [vendorId]
    );
    return {
      totalBids: parseInt(totalBidsRes.rows[0].count, 10),
      acceptedBids: parseInt(acceptedBidsRes.rows[0].count, 10),
      totalEarnings: parseFloat(totalEarningsRes.rows[0].coalesce),
      averageRating: parseFloat(avgRatingRes.rows[0]?.avg || '0'),
    };
  }
}
