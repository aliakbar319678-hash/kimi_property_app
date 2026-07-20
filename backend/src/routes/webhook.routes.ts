import { Router } from 'express';
import { query } from '../db';
import { config } from '../config';
import Stripe from 'stripe';
import { AppError } from '../middleware/errorHandler';

const stripe = new Stripe(config.stripe.secretKey, { apiVersion: '2023-10-16' as any });
const router = Router();

/**
 * @swagger
 * tags:
 *   name: Webhooks
 *   description: Third-party webhook handlers (Stripe, etc.)
 */

/**
 * @swagger
 * /api/v1/webhooks/stripe:
 *   post:
 *     summary: Handle Stripe webhook events
 *     tags: [Webhooks]
 *     parameters:
 *       - in: header
 *         name: stripe-signature
 *         required: false
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *     responses:
 *       200:
 *         description: Webhook received
 */
router.post('/stripe', async (req, res, next) => {
  try {
    const isDev = config.nodeEnv === 'development' || process.env.NODE_ENV === 'development';
    const sig = req.headers['stripe-signature'] as string;

    let event;
    if (isDev && (!sig || sig === 'bypass')) {
      if (Buffer.isBuffer(req.body)) {
        event = JSON.parse(req.body.toString('utf-8'));
      } else {
        event = typeof req.body === 'string' ? JSON.parse(req.body) : req.body;
      }
    } else {
      if (!sig) throw new AppError('Missing signature', 400);
      try {
        event = stripe.webhooks.constructEvent(req.body, sig, config.stripe.webhookSecret);
      } catch (err: any) {
        throw new AppError(`Webhook signature verification failed: ${err.message}`, 400);
      }
    }

    console.log("DEBUG: Event Type ->", event.type);
    console.log("DEBUG: Metadata ->", event.data?.object?.metadata);

    switch (event.type) {
      case 'payment_intent.succeeded': {
        const paymentIntent = event.data.object as Stripe.PaymentIntent;
        const targetId = paymentIntent.metadata?.invoiceId ?? paymentIntent.metadata?.invoice_id ?? paymentIntent.metadata?.paymentId ?? paymentIntent.metadata?.rentPaymentId ?? paymentIntent.metadata?.id;
        console.log("Looking for target ID in payment_intent.succeeded:", targetId);

        if (targetId) {
          // 1. Try updating rent_payments
          const rentPayRes = await query(
            `UPDATE rent_payments SET status = 'paid', paid_date = CURRENT_DATE, amount_paid = amount_due, payment_method = 'stripe' 
             WHERE id = $1 RETURNING *`,
            [targetId]
          );

          if (rentPayRes.rowCount && rentPayRes.rowCount > 0) {
            console.log("SUCCESS: Database rent_payments updated for ID:", targetId);
            // Also update the corresponding transaction
            await query(
              `UPDATE transactions SET status = 'completed', gateway_transaction_id = $1
               WHERE lease_id = $2 AND status = 'pending'`,
              [paymentIntent.id, rentPayRes.rows[0].lease_id]
            );
          } else {
            // 2. Try updating invoices
            const invoiceRes = await query(
              `UPDATE invoices SET status = 'paid', paid_date = CURRENT_DATE WHERE id = $1 RETURNING *`,
              [targetId]
            );
            if (invoiceRes.rowCount && invoiceRes.rowCount > 0) {
              console.log("SUCCESS: Database invoices updated for ID:", targetId);
            } else {
              console.log("WARNING: No record found in invoices or rent_payments with ID:", targetId);
            }
          }
        } else {
          await query(
            `UPDATE transactions SET status = 'completed', gateway_transaction_id = $1
             WHERE metadata->>'payment_intent_id' = $1`,
            [paymentIntent.id]
          );
          await query(
            `UPDATE rent_payments SET status = 'paid', paid_date = CURRENT_DATE, amount_paid = amount_due
             WHERE gateway_transaction_id = $1`,
            [paymentIntent.id]
          );
        }
        break;
      }
      case 'payment_intent.payment_failed': {
        const paymentIntent = event.data.object as Stripe.PaymentIntent;
        await query(
          `UPDATE transactions SET status = 'failed', metadata = metadata || $1
           WHERE metadata->>'payment_intent_id' = $2`,
          [JSON.stringify({ failure_message: paymentIntent.last_payment_error?.message }), paymentIntent.id]
        );
        break;
      }
      case 'invoice.payment_succeeded':
      case 'invoice.paid': {
        const invoice = event.data.object as Stripe.Invoice;
        const invoiceId = invoice.metadata?.invoiceId ?? invoice.metadata?.invoice_id ?? invoice.metadata?.id;

        if (invoiceId) {
          const res = await query(
            `UPDATE invoices SET status = 'paid', paid_date = CURRENT_DATE WHERE id = $1`,
            [invoiceId]
          );
          if (res.rowCount && res.rowCount > 0) {
            console.log("SUCCESS: Database updated for ID:", invoiceId);
          } else {
            console.log("WARNING: No record found with ID:", invoiceId);
          }
        } else {
          const res = await query(
            `UPDATE invoices SET status = 'paid', paid_date = CURRENT_DATE 
             WHERE gateway_transaction_id = $1 OR invoice_number = $2`,
            [invoice.id, invoice.number]
          );
          console.log(`Database update fallback result: ${res.rowCount} rows updated`);
        }
        break;
      }
      default:
        console.log(`Unhandled Stripe event: ${event.type}`);
    }

    res.json({ received: true });
  } catch (e) { next(e); }
});

export { router as webhookRouter };
