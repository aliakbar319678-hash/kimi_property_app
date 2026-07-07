import { Router } from 'express';
import { query } from '../db';
import { authenticate, requireRole } from '../middleware/auth';
import { adminOrJwtAuth } from '../middleware/adminKey';
import { StripeService } from '../services/stripe.service';

const router = Router();

// Get payouts queue (handles /pending)
router.get('/pending', adminOrJwtAuth, async (req: any, res, next) => {
  try {
    // If a specific status is provided, filter by it; otherwise show both queued and pending
    const statusParam = req.query.status;
    let payouts;
    if (statusParam) {
      const statusList = typeof statusParam === 'string' ? statusParam.split(',') : statusParam;
      const placeholders = statusList.map((_val: string, i: number) => `$${i + 1}`).join(', ');
      payouts = await query(`
          SELECT p.*, u.display_name as payee_name, u.email as payee_email
          FROM payouts p
          JOIN users u ON p.payee_id = u.id
          WHERE p.status IN (${placeholders})
          ORDER BY p.scheduled_date ASC
      `, statusList);
    } else {
      payouts = await query(`
           SELECT p.id, p.amount, p.platform_fee_deducted AS platform_fee, p.status, p.payee_role, p.scheduled_date, u.display_name as payee_name, u.email as payee_email
          FROM payouts p
          JOIN users u ON p.payee_id = u.id
          WHERE p.status IN ('queued', 'pending')
          ORDER BY p.scheduled_date ASC
        `);
    }
    console.log('🔍 PAYOUT DEBUG - First row:', JSON.stringify(payouts.rows[0]));
    console.log('🔍 PAYOUT DEBUG - Total rows:', payouts.rows.length);
    res.json({ success: true, data: payouts.rows });
  } catch (e) { next(e); }
});

// Get detailed view of a specific payout
router.get('/:id', adminOrJwtAuth, async (req: any, res, next) => {
  try {
    const payoutId = req.params.id;

    // Fetch the payout with full transaction, property, tenant AND work-order context
    const payoutRes = await query(`
      SELECT
        p.id, p.amount, p.platform_fee_deducted AS platform_fee,
        p.status, p.payee_role, p.scheduled_date, p.processed_date,
        u.id AS payee_id, u.display_name  AS payee_name,
        u.email         AS payee_email,

        -- Transaction
        t.id            AS transaction_id,
        t.type          AS transaction_type,
        t.metadata      AS transaction_metadata,
        t.gateway       AS payment_gateway,
        t.gateway_transaction_id,
        t.created_at    AS transaction_date,

        -- Property / Unit
        prop.name       AS property_name,
        prop.address_line1 AS property_address,
        unit.unit_number,

        -- Tenant (for landlord payouts)
        tenant.display_name AS tenant_name,
        tenant.email        AS tenant_email,

        -- Work Order (for vendor payouts)
        wo.id           AS work_order_id,
        wo.title        AS work_order_title,
        wo.description  AS work_order_description,
        wo.category     AS work_order_category,
        wo.priority     AS work_order_priority,
        wo.status       AS work_order_status,
        wo.budget_min,
        wo.budget_max,
        wo.scheduled_date   AS wo_scheduled_date,
        wo.completed_date   AS wo_completed_date,

        -- Job Assignment
        ja.final_amount AS job_final_amount,
        ja.status       AS job_status

      FROM payouts p
      JOIN users u ON p.payee_id = u.id

      LEFT JOIN transactions  t    ON p.transaction_id  = t.id
      LEFT JOIN properties    prop ON t.property_id     = prop.id
      LEFT JOIN units         unit ON t.unit_id         = unit.id
      LEFT JOIN leases        l    ON t.lease_id        = l.id
      LEFT JOIN users         tenant ON l.tenant_id     = tenant.id

      -- Work order link: vendor payouts reference a transaction whose payee is the vendor;
      -- find the work order assigned to that vendor on the same property
      LEFT JOIN work_orders   wo ON (
        wo.assigned_vendor_id = p.payee_id
        AND wo.property_id = t.property_id
      )
      LEFT JOIN job_assignments ja ON (
        ja.work_order_id = wo.id
        AND ja.vendor_id = p.payee_id
      )

      WHERE p.id = $1
      LIMIT 1
    `, [payoutId]);

    if (payoutRes.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Payout not found' });
    }

    res.json({ success: true, data: payoutRes.rows[0] });
  } catch (e) { next(e); }
});

// Process a specific payout manually
router.post('/:id/process', adminOrJwtAuth, async (req: any, res, next) => {
  try {
    const payoutId = req.params.id;
    const payoutRes = await query(`
      SELECT p.*, u.stripe_account_id 
      FROM payouts p
      JOIN users u ON p.payee_id = u.id
      WHERE p.id = $1 AND p.status IN ('queued', 'failed')
    `, [payoutId]);

    if (payoutRes.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Payout not found or not in queued/failed state' });
    }

    const payout = payoutRes.rows[0];

    // In a real scenario with Stripe Connect Express/Custom where you hold funds centrally
    // you would use Stripe Transfers to push funds to the connected account.
    // However, since we are using destination charges for rent, the landlord already gets the money
    // at the time of the charge. The payouts queue is more relevant for vendors or if platform collects 
    // all funds first and pays out on Net-30.
    
    // For now, we will simulate the processing success
    await query(
      `UPDATE payouts SET status = 'paid', processed_date = NOW(), updated_at = NOW() WHERE id = $1`,
      [payoutId]
    );

    res.json({ success: true, message: 'Payout processed successfully' });
  } catch (e) { next(e); }
});

// Process all pending payouts
router.post('/process-batch', adminOrJwtAuth, async (req: any, res, next) => {
  try {
    const payoutsRes = await query(`
      SELECT id FROM payouts WHERE status IN ('queued', 'failed')
    `);

    if (payoutsRes.rows.length === 0) {
      return res.status(400).json({ success: false, message: 'No pending payouts to process' });
    }

    // Process them in a real app via Stripe API. Here we simulate success.
    await query(
      `UPDATE payouts SET status = 'paid', processed_date = NOW(), updated_at = NOW() WHERE status IN ('queued', 'failed')`
    );

    res.json({ success: true, message: `Successfully processed ${payoutsRes.rows.length} payouts.` });
  } catch (e) { next(e); }
});

// Hold a payout
router.post('/:id/hold', adminOrJwtAuth, async (req: any, res, next) => {
  try {
    const payoutId = req.params.id;
    await query(
      `UPDATE payouts SET status = 'on_hold', updated_at = NOW() WHERE id = $1 AND status IN ('queued','failed')`,
      [payoutId]
    );
    res.json({ success: true, message: 'Payout placed on hold' });
  } catch (e) { next(e); }
});

// Release a payout
router.post('/:id/release', adminOrJwtAuth, async (req: any, res, next) => {
  try {
    const payoutId = req.params.id;
    await query(
      `UPDATE payouts SET status = 'released', updated_at = NOW() WHERE id = $1 AND status = 'on_hold'`,
      [payoutId]
    );
    res.json({ success: true, message: 'Payout released' });
  } catch (e) { next(e); }
});

export { router as payoutRouter };
