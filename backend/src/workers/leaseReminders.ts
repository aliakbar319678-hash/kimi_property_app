import { query, pool } from '../db';
import Stripe from 'stripe';
import { config } from '../config';
import { NotificationService } from '../services/notification.service';

const stripe = new Stripe(config.stripe.secretKey || 'dummy_key', {
  apiVersion: '2023-10-16' as any,
});

/**
 * leaseReminders.ts
 * Daily cron worker that finds leases expiring in 4 days.
 * If the tenant has no saved cards on Stripe, sends an alert notification.
 */
export async function sendLeaseExpiryNoCardReminders(): Promise<void> {
  console.log('[sendLeaseExpiryNoCardReminders] Starting run at', new Date().toISOString());
  const client = await pool.connect();

  try {
    // Find all active leases ending in exactly 4 days
    const queryText = `
      SELECT l.id as lease_id, l.tenant_id, u.stripe_customer_id
      FROM leases l
      JOIN users u ON l.tenant_id = u.id
      WHERE l.status = 'active'
        AND l.end_date::date = CURRENT_DATE + INTERVAL '4 days'
    `;
    const result = await client.query(queryText);
    const leases = result.rows;

    console.log(`[sendLeaseExpiryNoCardReminders] Found ${leases.length} lease(s) expiring in 4 days.`);

    let remindedCount = 0;

    for (const lease of leases) {
      try {
        if (!lease.stripe_customer_id) {
          // No stripe customer at all means no cards
          await NotificationService.createLeaseExpiryNoCardAlert(lease.tenant_id);
          remindedCount++;
          continue;
        }

        // Check if they have cards saved
        const paymentMethods = await stripe.paymentMethods.list({
          customer: lease.stripe_customer_id,
          type: 'card',
        });

        if (paymentMethods.data.length === 0) {
          await NotificationService.createLeaseExpiryNoCardAlert(lease.tenant_id);
          remindedCount++;
        }
      } catch (err) {
        console.error(`[sendLeaseExpiryNoCardReminders] Error checking cards for tenant ${lease.tenant_id}:`, err);
      }
    }

    console.log(`[sendLeaseExpiryNoCardReminders] Done. Sent reminders to ${remindedCount} tenant(s).`);
  } catch (err) {
    console.error('[sendLeaseExpiryNoCardReminders] Error:', err);
  } finally {
    client.release();
  }
}
