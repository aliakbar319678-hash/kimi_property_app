import { query, pool } from '../db';
import Stripe from 'stripe';
import { config } from '../config';
import { NotificationService } from '../services/notification.service';

const stripe = new Stripe(config.stripe.secretKey || 'dummy_key', {
  apiVersion: '2023-10-16' as any,
});

/**
 * autoChargeRent.ts
 * Daily cron worker that finds pending rent payments due today (or past due).
 * Attempts to charge the tenant's default Stripe card automatically.
 * Implements fallback logic: if the primary card fails, it loops through other saved cards.
 */
export async function autoChargeRent(): Promise<void> {
  console.log('[autoChargeRent] Starting run at', new Date().toISOString());
  const client = await pool.connect();

  try {
    // Find all pending rent_payments due today or earlier
    const queryText = `
      SELECT rp.id as rent_payment_id, rp.tenant_id, rp.amount_due, rp.property_id, rp.unit_id, rp.lease_id, u.stripe_customer_id
      FROM rent_payments rp
      JOIN users u ON rp.tenant_id = u.id
      WHERE rp.status = 'pending'
        AND rp.due_date <= CURRENT_DATE
    `;
    const result = await client.query(queryText);
    const payments = result.rows;

    console.log(`[autoChargeRent] Found ${payments.length} pending rent payment(s).`);

    let processedCount = 0;
    let failedCount = 0;

    for (const payment of payments) {
      if (!payment.stripe_customer_id) {
        console.warn(`[autoChargeRent] Tenant ${payment.tenant_id} has no stripe_customer_id. Skipping payment ${payment.rent_payment_id}.`);
        continue;
      }

      try {
        const customerId = payment.stripe_customer_id;
        
        // Fetch all saved cards for the customer
        const paymentMethods = await stripe.paymentMethods.list({
          customer: customerId,
          type: 'card',
        });

        if (paymentMethods.data.length === 0) {
          console.warn(`[autoChargeRent] Tenant ${payment.tenant_id} has no saved cards.`);
          await NotificationService.createPaymentFailedAlert(payment.tenant_id);
          failedCount++;
          continue;
        }

        // Get customer object to find the default payment method
        const customer = await stripe.customers.retrieve(customerId) as Stripe.Customer;
        const defaultMethodId = customer.invoice_settings?.default_payment_method as string | null;

        // Sort cards: put default card first
        const sortedCards = paymentMethods.data.sort((a, b) => {
          if (a.id === defaultMethodId) return -1;
          if (b.id === defaultMethodId) return 1;
          return 0;
        });

        let paymentSucceeded = false;
        let successfulCardId = null;
        let usedFallback = false;
        let lastFailureReason = '';
        let paymentIntentId = null;

        // Loop through cards and attempt to charge
        for (let i = 0; i < sortedCards.length; i++) {
          const card = sortedCards[i];
          const isPrimaryAttempt = i === 0;

          try {
            const paymentIntent = await stripe.paymentIntents.create({
              amount: Math.round(parseFloat(payment.amount_due) * 100),
              currency: 'usd',
              customer: customerId,
              payment_method: card.id,
              off_session: true,
              confirm: true,
            });

            if (paymentIntent.status === 'succeeded' || paymentIntent.status === 'requires_action') {
              paymentSucceeded = true;
              successfulCardId = card.id;
              usedFallback = !isPrimaryAttempt;
              paymentIntentId = paymentIntent.id;
              break; // Stop looping on success
            }
          } catch (err: any) {
            console.error(`[autoChargeRent] Charge failed for card ${card.id}:`, err.message);
            lastFailureReason = err.message;
          }
        }

        if (paymentSucceeded && paymentIntentId) {
          // If fallback was used, set this new card as default
          if (usedFallback && successfulCardId) {
            await stripe.customers.update(customerId, {
              invoice_settings: { default_payment_method: successfulCardId },
            });
            await NotificationService.createPaymentFallbackSuccess(payment.tenant_id);
          }

          // Create transaction record
          await client.query(
            `INSERT INTO transactions (payer_id, property_id, unit_id, lease_id, type, amount, currency, status, gateway, gateway_transaction_id, metadata)
             VALUES ($1, $2, $3, $4, 'rent', $5, 'USD', 'completed', 'stripe', $6, $7)`,
            [payment.tenant_id, payment.property_id, payment.unit_id, payment.lease_id, payment.amount_due, paymentIntentId, JSON.stringify({ payment_intent_id: paymentIntentId })]
          );

          // Update rent_payments table
          await client.query(
            `UPDATE rent_payments SET status = 'paid', paid_date = CURRENT_DATE, amount_paid = amount_due, gateway_transaction_id = $1 WHERE id = $2`,
            [paymentIntentId, payment.rent_payment_id]
          );

          processedCount++;
        } else {
          // All cards failed
          await client.query(
            `UPDATE rent_payments SET metadata = jsonb_set(COALESCE(metadata, '{}'::jsonb), '{last_failure}', $1) WHERE id = $2`,
            [JSON.stringify(lastFailureReason), payment.rent_payment_id]
          );
          await NotificationService.createPaymentFailedAlert(payment.tenant_id);
          failedCount++;
        }

      } catch (err) {
        console.error(`[autoChargeRent] Critical error processing payment ${payment.rent_payment_id}:`, err);
      }
    }

    console.log(`[autoChargeRent] Done. Processed: ${processedCount}. Failed: ${failedCount}.`);
  } catch (err) {
    console.error('[autoChargeRent] Error:', err);
  } finally {
    client.release();
  }
}
