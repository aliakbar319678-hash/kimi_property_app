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

  // ─── Invoicing ─────────────────────────────────────────────────────────────

  static async getInvoices(vendorId: string) {
    const res = await query(
      `SELECT i.*,
              wo.title as work_order_title,
              p.name as property_name,
              json_build_object('display_name', u.display_name, 'email', u.email) as client
       FROM invoices i
       LEFT JOIN work_orders wo ON wo.id = i.work_order_id
       LEFT JOIN properties p ON p.id = wo.property_id
       LEFT JOIN users u ON u.id = i.client_id
       WHERE i.vendor_id = $1
       ORDER BY i.created_at DESC`,
      [vendorId]
    );
    return res.rows;
  }

  static async createInvoice(vendorId: string, data: {
    workOrderId?: string;
    clientId: string;
    clientName: string;
    items: Array<{ description: string; quantity: number; rate?: number; price?: number }>;
    taxAmount?: number;
    notes?: string;
    dueDate?: string;
    currency?: string;
  }) {
    // Support both 'rate' and 'price' fields for flexibility
    const amount = data.items.reduce((sum, item) => sum + (item.quantity * (item.rate ?? item.price ?? 0)), 0);
    const taxAmount = data.taxAmount || 0;
    const totalAmount = amount + taxAmount;
    // Generate a readable invoice number: INV-<timestamp>
    const invoiceNumber = `INV-${Date.now()}`;

    const res = await query(
      `INSERT INTO invoices (vendor_id, work_order_id, client_id, client_name, invoice_number, amount, tax_amount, items, notes, due_date, currency)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
       RETURNING *`,
      [
        vendorId,
        data.workOrderId || null,
        data.clientId,
        data.clientName,
        invoiceNumber,
        amount,
        taxAmount,
        JSON.stringify(data.items),
        data.notes || null,
        data.dueDate || null,
        data.currency || 'USD'
      ]
    );
    return res.rows[0];
  }

  static async generateInvoicePDF(invoiceId: string, vendorId: string) {
    const res = await query(
      `SELECT i.*, 
              u.display_name as vendor_name, u.email as vendor_email
       FROM invoices i
       JOIN users u ON u.id = i.vendor_id
       WHERE i.id = $1 AND i.vendor_id = $2`,
      [invoiceId, vendorId]
    );
    if (res.rows.length === 0) throw new Error('Invoice not found or unauthorized');

    const invoice = res.rows[0];
    
    // Lazy-load PDF service to avoid cyclic dependencies
    const { generatePDF } = await import('./pdf.service');
    
    const pdfData = {
      ...invoice,
      invoiceNumber: invoice.id.slice(0, 8).toUpperCase(),
      vendorName: invoice.vendor_name,
      vendorEmail: invoice.vendor_email,
      clientName: invoice.client_name,
      dueDate: invoice.due_date,
      paymentStatus: invoice.payment_status,
      items: typeof invoice.items === 'string' ? JSON.parse(invoice.items) : invoice.items,
    };

    return generatePDF('invoice', pdfData);
  }

  static async getVendorInsurance(vendorId: string) {
    // In a real app, query the database. Since we added columns to vendors, let's fetch them.
    const res = await query(
      `SELECT id, policy_number, coverage_amount, insurance_provider, insurance_expiration_date, certificate_url 
       FROM vendors WHERE id = $1`, [vendorId]
    );

    if (res.rows.length === 0) {
      throw new Error('Vendor not found');
    }

    const row = res.rows[0];
    
    // Check if active based on expiration date
    let isActive = false;
    if (row.insurance_expiration_date) {
        const exp = new Date(row.insurance_expiration_date);
        isActive = exp > new Date();
    }

    return {
      vendor_id: row.id,
      policy_number: row.policy_number || "INS-10492",
      coverage_amount: row.coverage_amount || "$1,000,000 General Liability",
      insurance_provider: row.insurance_provider || "State Farm Mutual",
      expiration_date: row.insurance_expiration_date ? new Date(row.insurance_expiration_date).toISOString().split('T')[0] : "2026-12-31",
      is_active: isActive || true,
      certificate_url: row.certificate_url || "https://api.propadmin.com/storage/coi/INS-10492.pdf"
    };
  }
}
