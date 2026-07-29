import { Router } from 'express';
import { FinanceService } from '../services/finance.service';
import { authenticate, AuthRequest, requireRole } from '../middleware/auth';
import { adminOrJwtAuth } from '../middleware/adminKey';
import { query } from '../db';

const router = Router();

router.get('/dashboard', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const stats = await FinanceService.getDashboardStats(req.user!.id, req.user!.activeRole!, req.query.period as string);
    res.json({ success: true, data: stats });
  } catch (e) { next(e); }
});

// Admin-facing overall stats
router.get('/stats', adminOrJwtAuth, async (req: AuthRequest, res, next) => {
  try {
    const incomeRes = await query("SELECT COALESCE(SUM(amount),0) as total FROM transactions WHERE status = 'completed' AND type != 'refund'");
    const expenseRes = await query("SELECT COALESCE(SUM(amount),0) as total FROM transactions WHERE type = 'refund' AND status = 'completed'");
    const pendingRes = await query("SELECT COALESCE(SUM(amount),0) as total FROM transactions WHERE status = 'pending'");
    
    const txnsRes = await query(`
      SELECT 
        t.id, t.amount, t.status, t.type,
        CASE t.gateway
          WHEN 'stripe' THEN 'Card (Stripe)'
          WHEN 'paypal' THEN 'PayPal'
          ELSE 'Bank Transfer'
        END as payment_method,
        t.created_at,
        u.id as user_id,
        u.display_name as user_name,
        u.email as user_email,
        ur.role as user_role,
        u.phone as user_phone
      FROM transactions t
      LEFT JOIN users u ON t.payer_id = u.id
      LEFT JOIN user_roles ur ON ur.user_id = u.id AND ur.is_primary = true
      ORDER BY t.created_at DESC LIMIT 50
    `);

    const failedTxns = await query(`SELECT COUNT(*) as cnt, SUM(amount) as total_lost FROM transactions WHERE status = 'failed' AND created_at > NOW() - INTERVAL '24 hours'`);
    const disputedTxns = await query(`SELECT COUNT(*) as cnt FROM transactions WHERE status = 'disputed'`);
    
    const alerts = [];
    const failedCount = parseInt(failedTxns.rows[0].cnt);
    const disputedCount = parseInt(disputedTxns.rows[0].cnt);
    
    if (failedCount > 0) {
      alerts.push({
        type: 'investigate',
        title: `${failedCount} Failed Payment${failedCount > 1 ? 's' : ''} Detected`,
        description: `$${parseFloat(failedTxns.rows[0].total_lost || 0).toFixed(2)} in failed transactions in the last 24 hours. Immediate review required.`
      });
    }
    if (disputedCount > 0) {
      alerts.push({
        type: 'resolve',
        title: `${disputedCount} Open Dispute${disputedCount > 1 ? 's' : ''} Pending`,
        description: `${disputedCount} chargeback dispute${disputedCount > 1 ? 's' : ''} require admin resolution before auto-refund window closes.`
      });
    }

    res.json({ 
      success: true, 
      data: {
        total_income: parseFloat(incomeRes.rows[0].total) || 0,
        total_expenses: parseFloat(expenseRes.rows[0].total) || 0,
        pending_payments: parseFloat(pendingRes.rows[0].total) || 0,
        net_profit: (parseFloat(incomeRes.rows[0].total) || 0) - (parseFloat(expenseRes.rows[0].total) || 0),
        transactions: txnsRes.rows,
        alerts
      } 
    });
  } catch (e) { next(e); }
});

router.post('/payments/initiate', authenticate, requireRole('tenant'), async (req: AuthRequest, res, next) => {
  try {
    const payment = await FinanceService.initiatePayment(req.body.leaseId, req.user!.id, req.body.amount, req.body.paymentMethod);
    res.status(201).json({ success: true, data: payment });
  } catch (e) { next(e); }
});

router.post('/payments/vendor', authenticate, requireRole('landlord', 'property_manager'), async (req: AuthRequest, res, next) => {
  try {
    const { workOrderId, vendorId, amount, paymentMethod, workReference } = req.body;
    if (!workOrderId || !vendorId || !amount) {
      return res.status(400).json({ success: false, error: 'Missing required parameters (workOrderId, vendorId, amount)' });
    }
    const result = await FinanceService.payVendor(workOrderId, req.user!.id, vendorId, amount, paymentMethod || 'balance', workReference);
    res.status(201).json(result);
  } catch (e) { next(e); }
});

// ─── Vendor Wallet (held + available balance) ─────────────────────────────────
router.get('/vendor/wallet', authenticate, requireRole('vendor', 'landlord'), async (req: AuthRequest, res, next) => {
  try {
    const data = await FinanceService.getVendorHeldPayments(req.user!.id);
    res.json({ success: true, data });
  } catch (e) { next(e); }
});

// ─── Dispute a held payment ───────────────────────────────────────────────────
router.post('/payments/:transactionId/dispute', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const { reason } = req.body;
    if (!reason) return res.status(400).json({ success: false, error: 'reason is required' });
    const tx = await FinanceService.disputeHold(req.params.transactionId, reason);
    res.json({ success: true, data: tx, message: 'Payment disputed' });
  } catch (e) { next(e); }
});

// ─── Cancel / void a held payment ─────────────────────────────────────────────
router.post('/payments/:transactionId/cancel', authenticate, requireRole('admin', 'super_admin', 'landlord'), async (req: AuthRequest, res, next) => {
  try {
    const tx = await FinanceService.cancelHold(req.params.transactionId);
    res.json({ success: true, data: tx, message: 'Payment hold cancelled' });
  } catch (e) { next(e); }
});

router.get('/vendor/earnings', authenticate, requireRole('vendor', 'landlord'), async (req: AuthRequest, res, next) => {
  try {
    const earnings = await FinanceService.getVendorEarnings(req.user!.id);
    res.json({ success: true, data: earnings });
  } catch (e) { next(e); }
});

router.post('/invoices', authenticate, requireRole('vendor', 'landlord', 'admin'), async (req: AuthRequest, res, next) => {
  try {
    const invoice = await FinanceService.generateInvoice(req.user!.id, req.body.workOrderId, req.body.items, req.body.due_date || req.body.dueDate);
    res.status(201).json({ success: true, data: invoice });
  } catch (e) { next(e); }
});

router.post('/payments/retry/:id', adminOrJwtAuth, async (req: AuthRequest, res, next) => {
  try {
    const txId = req.params.id;
    const txRes = await query(
      `SELECT * FROM transactions WHERE id = $1 AND status = 'failed'`, [txId]
    );
    if (!txRes.rows.length) {
      return res.status(404).json({ success: false, error: 'Failed transaction not found' });
    }
    const tx = txRes.rows[0];
    const Stripe = require('stripe');
    const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

    // If the original had a payment_intent, try to confirm it again
    const piId = tx.metadata?.payment_intent_id || tx.gateway_transaction_id;
    if (piId && piId.startsWith('pi_')) {
      try {
        const pi = await stripe.paymentIntents.retrieve(piId);
        if (pi.status === 'requires_payment_method' || pi.status === 'requires_confirmation') {
          await stripe.paymentIntents.confirm(piId);
        }
        await query(
          `UPDATE transactions SET status = 'pending', metadata = metadata || '{"retry": true}'::jsonb, updated_at = NOW() WHERE id = $1`,
          [txId]
        );
        return res.json({ success: true, message: 'Payment intent re-confirmed, awaiting webhook confirmation' });
      } catch (stripeErr: any) {
        return res.status(400).json({ success: false, error: `Stripe retry failed: ${stripeErr.message}` });
      }
    }

    // Fallback: create a brand new payment intent for the same amount
    try {
      const pi = await stripe.paymentIntents.create({
        amount: Math.round(tx.amount * 100),
        currency: tx.currency || 'usd',
        description: `Retry of failed transaction ${txId}`,
        metadata: { original_transaction_id: txId, retry: 'true' }
      });
      await query(
        `UPDATE transactions SET status = 'pending', gateway_transaction_id = $1,
         metadata = metadata || $2, updated_at = NOW() WHERE id = $3`,
        [pi.id, JSON.stringify({ payment_intent_id: pi.id, retry: true }), txId]
      );
      res.json({ success: true, message: 'New payment intent created', client_secret: pi.client_secret });
    } catch (stripeErr: any) {
      res.status(400).json({ success: false, error: `Stripe retry failed: ${stripeErr.message}` });
    }
  } catch (e) { next(e); }
});

// ─── Transaction Detail (admin view with full user + role context) ───────────
router.get('/transactions/:id/details', adminOrJwtAuth, async (req: AuthRequest, res, next) => {
  try {
    const { id } = req.params;
    console.log('Fetching transaction details for ID:', id);

    // Base transaction + user info
      const txnRes = await query(`
        SELECT
          t.*,
          u.id         AS user_id,
          u.display_name AS user_name,
          u.email      AS user_email,
          ur.role      AS user_role
        FROM transactions t
        LEFT JOIN users u ON u.id = t.payer_id
        LEFT JOIN user_roles ur ON ur.user_id = u.id AND ur.is_primary = true
        WHERE t.id = $1
      `, [id]);

    if (!txnRes.rows.length) {
      // Fallback: check rent_payments table
      const rpRes = await query(`
        SELECT
          rp.*,
          u.id         AS user_id,
          u.display_name AS user_name,
          u.email      AS user_email,
          ur.role      AS user_role,
          l.id AS lease_id, l.start_date, l.end_date, l.rent_amount, l.deposit_amount,
          l.payment_schedule, l.status AS lease_status, l.auto_renew,
          p.name AS property_name, p.address_line1, p.city, p.state_province,
          p.type AS property_type,
          un.unit_number, un.bedrooms, un.bathrooms, un.square_feet AS floor_area_sqft,
          ll.display_name AS landlord_name
        FROM rent_payments rp
        LEFT JOIN users u ON u.id = rp.tenant_id
        LEFT JOIN user_roles ur ON ur.user_id = u.id AND ur.is_primary = true
        LEFT JOIN leases l ON l.id = rp.lease_id
        LEFT JOIN properties p ON p.id = rp.property_id
        LEFT JOIN units un ON un.id = rp.unit_id
        LEFT JOIN users ll ON ll.id = l.landlord_id
        WHERE rp.id = $1
      `, [id]);

      if (!rpRes.rows.length) {
        return res.status(404).json({ success: false, error: 'Transaction not found' });
      }

      const rp = rpRes.rows[0];
      return res.json({
        success: true,
        source: 'rent_payments',
        data: {
          id: rp.id,
          amount_due: rp.amount_due,
          amount_paid: rp.amount_paid,
          balance_due: rp.balance_due,
          due_date: rp.due_date,
          status: rp.status,
          gateway_transaction_id: rp.gateway_transaction_id,
          created_at: rp.created_at,
          user: {
            id: rp.user_id,
            name: rp.user_name,
            email: rp.user_email,
            role: rp.user_role
          },
          lease: {
            id: rp.lease_id,
            start_date: rp.start_date,
            end_date: rp.end_date,
            rent_amount: rp.rent_amount,
            deposit_amount: rp.deposit_amount,
            payment_schedule: rp.payment_schedule,
            status: rp.lease_status,
            auto_renew: rp.auto_renew
          },
          property: {
            name: rp.property_name,
            address: rp.address_line1,
            city: rp.city,
            state: rp.state_province,
            type: rp.property_type
          },
          unit: {
            unit_number: rp.unit_number,
            bedrooms: rp.bedrooms,
            bathrooms: rp.bathrooms,
            floor_area_sqft: rp.floor_area_sqft
          },
          landlord_name: rp.landlord_name
        }
      });
    }

    const txn = txnRes.rows[0];
    const role = txn.user_role;
    let roleContext: any = null;

    if (role === 'tenant') {
      // Fetch lease + property + unit details
      const leaseRes = await query(`
        SELECT
          l.id, l.start_date, l.end_date, l.rent_amount, l.deposit_amount,
          l.payment_schedule, l.status AS lease_status, l.auto_renew,
          p.name AS property_name, p.address_line1, p.city, p.state_province,
          p.type AS property_type,
          un.unit_number, un.bedrooms, un.bathrooms, un.square_feet AS floor_area_sqft,
          ll.display_name AS landlord_name
        FROM leases l
        LEFT JOIN properties p ON p.id = l.property_id
        LEFT JOIN units un ON un.id = l.unit_id
        LEFT JOIN users ll ON ll.id = l.landlord_id
        WHERE l.tenant_id = $1 AND l.status = 'active'
        LIMIT 1
      `, [txn.user_id]);

      roleContext = {
        type: 'tenant',
        lease: leaseRes.rows[0] || null,
        transactionDescription: txn.metadata?.description || 'Rent payment'
      };
    } else if (role === 'vendor') {
      // Find the payee_id (vendor receives the payment)
      const vendorId = txn.payee_id || txn.user_id;

      // Fetch all job assignments for this vendor, with work order details
      const jobsRes = await query(`
        SELECT
          ja.id AS assignment_id,
          ja.status AS assignment_status,
          ja.final_amount,
          ja.scheduled_date,
          wo.title AS work_order_title,
          wo.description AS work_order_description,
          wo.category,
          wo.priority,
          wo.status AS work_order_status,
          wo.budget_min,
          wo.budget_max,
          wo.completed_date,
          p.name AS property_name,
          un.unit_number
        FROM job_assignments ja
        LEFT JOIN work_orders wo ON wo.id = ja.work_order_id
        LEFT JOIN properties p ON p.id = wo.property_id
        LEFT JOIN units un ON un.id = wo.unit_id
        WHERE ja.vendor_id = $1
        ORDER BY ja.created_at DESC
      `, [vendorId]);

      const totalJobs = jobsRes.rows.length;
      const completedJobs = jobsRes.rows.filter((j: any) => j.assignment_status === 'completed').length;
      const completionPercent = totalJobs > 0 ? Math.round((completedJobs / totalJobs) * 100) : 0;

      roleContext = {
        type: 'vendor',
        jobs: jobsRes.rows,
        stats: {
          total_jobs: totalJobs,
          completed_jobs: completedJobs,
          in_progress_jobs: jobsRes.rows.filter((j: any) => j.assignment_status === 'accepted').length,
          completion_percent: completionPercent
        }
      };
    } else if (role === 'landlord') {
      // Fetch their properties and rental summary
      const propsRes = await query(`
        SELECT
          p.id, p.name, p.address_line1, p.city, p.state_province, p.type, p.status,
          COUNT(DISTINCT u.id) AS total_units,
          COUNT(DISTINCT CASE WHEN u.status = 'occupied' THEN u.id END) AS occupied_units,
          COALESCE(SUM(CASE WHEN t2.status = 'completed' AND t2.type = 'rent' THEN t2.amount ELSE 0 END), 0) AS total_rent_collected
        FROM properties p
        LEFT JOIN units u ON u.property_id = p.id
        LEFT JOIN transactions t2 ON t2.property_id = p.id
        WHERE p.landlord_id = $1
        GROUP BY p.id
      `, [txn.user_id]);

      roleContext = {
        type: 'landlord',
        properties: propsRes.rows,
        transactionDescription: txn.metadata?.description || 'Rental income payout'
      };
    } else {
      roleContext = { type: role || 'unknown' };
    }

    res.json({
      success: true,
      data: {
        id: txn.id,
        amount: txn.amount,
        currency: txn.currency,
        status: txn.status,
        type: txn.type,
        gateway: txn.gateway,
        gateway_transaction_id: txn.gateway_transaction_id,
        created_at: txn.created_at,
        metadata: txn.metadata,
        user: {
          id: txn.user_id,
          name: txn.user_name,
          email: txn.user_email,
          avatar_url: txn.avatar_url,
          phone: txn.phone,
          role
        },
        role_context: roleContext
      }
    });
  } catch (e) { next(e); }
});

router.get('/export', adminOrJwtAuth, async (req: AuthRequest, res, next) => {
  try {
    const txns = await query(`
      SELECT
        t.id,
        COALESCE(u.display_name, u.email, 'Unknown') AS payer_name,
        t.amount,
        t.status,
        t.created_at
      FROM transactions t
      LEFT JOIN users u ON u.id = t.payer_id
      ORDER BY t.created_at DESC
    `);

    let csv = 'Transaction ID,Payer Name,Amount,Status,Date\n';
    txns.rows.forEach((t: any) => {
      const name = `"${(t.payer_name || 'Unknown').replace(/"/g, '""')}"`;
      csv += `${t.id},${name},${t.amount},${t.status},${t.created_at}\n`;
    });

    res.header('Content-Type', 'text/csv');
    res.attachment('transactions.csv');
    res.send(csv);
  } catch (e) { next(e); }
});

export { router as financeRouter };
