import { Router } from 'express';
import { query } from '../db';
import { config } from '../config';
import Stripe from 'stripe';
import { AppError } from '../middleware/errorHandler';

const stripe = new Stripe(config.stripe.secretKey, { apiVersion: '2023-10-16' as any });
const router = Router();

/**
 * @swagger
 * /api/v1/webhooks/stripe:
 *   post:
 *     summary: Stripe Webhook Endpoint
 *     description: Endpoint to receive webhooks from Stripe (e.g. payment_intent.succeeded). Must include Stripe-Signature header.
 *     tags:
 *       - Webhooks
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *           example:
 *             id: "evt_3P..."
 *             object: "event"
 *             type: "payment_intent.succeeded"
 *             data:
 *               object:
 *                 id: "pi_3P..."
 *                 object: "payment_intent"
 *                 amount: 10000
 *                 currency: "usd"
 *                 status: "succeeded"
 *     responses:
 *       200:
 *         description: Webhook received successfully
 *       400:
 *         description: Webhook signature verification failed
 */
router.post('/stripe', async (req, res, next) => {
  try {
    const sig = req.headers['stripe-signature'] as string;
    if (!sig) throw new AppError('Missing signature', 400);

    let event;
    try {
      event = stripe.webhooks.constructEvent(req.body, sig, config.stripe.webhookSecret);
    } catch (err: any) {
      throw new AppError(`Webhook signature verification failed: ${err.message}`, 400);
    }

    switch (event.type) {
      case 'payment_intent.succeeded': {
        const paymentIntent = event.data.object as Stripe.PaymentIntent;
        await query(
          `UPDATE transactions SET status = 'completed', gateway_transaction_id = $1, updated_at = NOW()
           WHERE metadata->>'payment_intent_id' = $1`,
          [paymentIntent.id]
        );
        await query(
          `UPDATE rent_payments SET status = 'paid', paid_date = CURRENT_DATE, amount_paid = amount_due
           WHERE gateway_transaction_id = $1`,
          [paymentIntent.id]
        );
        break;
      }
      case 'payment_intent.payment_failed': {
        const paymentIntent = event.data.object as Stripe.PaymentIntent;
        const txResult = await query(
          `UPDATE transactions SET status = 'failed', metadata = metadata || $1, updated_at = NOW()
           WHERE metadata->>'payment_intent_id' = $2 RETURNING payer_id`,
          [JSON.stringify({ failure_message: paymentIntent.last_payment_error?.message }), paymentIntent.id]
        );
        
        if (txResult.rows.length > 0 && txResult.rows[0].payer_id) {
           const { NotificationService } = require('../services/notification.service');
           await NotificationService.createPaymentFailedAlert(txResult.rows[0].payer_id);
        }
        break;
      }
      case 'invoice.paid': {
        const invoice = event.data.object as Stripe.Invoice;
        await query(
          `UPDATE invoices SET status = 'paid', paid_date = CURRENT_DATE WHERE gateway_transaction_id = $1`,
          [invoice.id]
        );
        break;
      }
      default:
        console.log(`Unhandled Stripe event: ${event.type}`);
    }

    res.json({ received: true });
  } catch (e) { next(e); }
});

export { router as webhookRouter };
