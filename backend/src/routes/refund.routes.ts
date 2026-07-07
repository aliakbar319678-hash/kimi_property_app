import { Router } from 'express';
import { query } from '../db';
import { adminOrJwtAuth } from '../middleware/adminKey';
import { StripeService } from '../services/stripe.service';
import { AppError } from '../middleware/errorHandler';

const router = Router();

// Process Refund (Admin Only)
router.post('/process', adminOrJwtAuth, async (req: any, res, next) => {
  try {
    const { transaction_id, amount, reason } = req.body;

    if (!transaction_id) throw new AppError('transaction_id is required', 400);
    if (!reason) throw new AppError('Refund reason is required', 400);

    const txRes = await query('SELECT * FROM transactions WHERE id = $1', [transaction_id]);
    if (txRes.rows.length === 0) throw new AppError('Transaction not found', 404);

    const tx = txRes.rows[0];

    if (tx.status === 'refunded') throw new AppError('This transaction has already been refunded', 409);
    if (tx.status !== 'completed') throw new AppError(`Cannot refund a transaction with status: ${tx.status}`, 400);
    if (!tx.gateway_transaction_id) throw new AppError('Transaction cannot be refunded: no payment gateway ID found', 400);

    // Map any free-text reason to a valid Stripe enum value
    let stripeReason: 'duplicate' | 'fraudulent' | 'requested_by_customer' = 'requested_by_customer';
    const reasonLower = reason.toLowerCase();
    if (reasonLower.includes('fraud') || reasonLower.includes('unauthorized') || reasonLower.includes('stolen')) {
      stripeReason = 'fraudulent';
    } else if (reasonLower.includes('duplicate') || reasonLower.includes('double')) {
      stripeReason = 'duplicate';
    }

    // Issue refund via Stripe (mocked in dev environment)
    const refund = await StripeService.issueRefund(
      tx.gateway_transaction_id,
      amount ? Math.round(parseFloat(amount) * 100) : undefined,
      stripeReason
    );

    // Mark the original transaction as 'refunded'
    await query(
      "UPDATE transactions SET status = 'refunded', updated_at = NOW() WHERE id = $1",
      [transaction_id]
    );

    // Use payee_id as issuer if no JWT user context (admin key auth bypasses JWT)
    const issuerId = req.user?.id || tx.payee_id;

    // Record refund as a new transaction in the ledger
    const refundTxRes = await query(
      `INSERT INTO transactions 
        (payer_id, payee_id, property_id, unit_id, lease_id, type, amount, currency, status, gateway, gateway_transaction_id, metadata, created_at, updated_at)
       VALUES ($1, $2, $3, $4, $5, 'refund', $6, 'USD', 'completed', 'stripe', $7, $8, NOW(), NOW()) 
       RETURNING *`,
      [
        issuerId,
        tx.payer_id,
        tx.property_id,
        tx.unit_id,
        tx.lease_id,
        amount || tx.amount,
        refund.id,
        JSON.stringify({ reason, original_transaction_id: transaction_id })
      ]
    );

    const refundedAmount = parseFloat(amount || tx.amount).toFixed(2);
    res.json({
      success: true,
      data: refundTxRes.rows[0],
      message: `Refund of $${refundedAmount} processed successfully`
    });
  } catch (e) { next(e); }
});

export { router as refundRouter };
