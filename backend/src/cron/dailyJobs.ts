import cron from 'node-cron';
import { query } from '../db';
import { NotificationService } from '../services/notification.service';
import { releaseHeldPayments, sendHoldReleaseReminders } from '../workers/releaseHeldPayments';
import { sendLeaseExpiryNoCardReminders } from '../workers/leaseReminders';
import { autoChargeRent } from '../workers/autoChargeRent';

export function startCronJobs() {
  // ── Auto-charge rent (daily at 08:30) ───────────────────────────
  cron.schedule('30 8 * * *', async () => {
    try {
      await autoChargeRent();
    } catch (e) {
      console.error('[cron] autoChargeRent failed:', e);
    }
  });

  // ── Lease Expiry No-Card Reminder (daily at 07:00) ───────────────────────────
  cron.schedule('0 7 * * *', async () => {
    try {
      await sendLeaseExpiryNoCardReminders();
    } catch (e) {
      console.error('[cron] sendLeaseExpiryNoCardReminders failed:', e);
    }
  });
  // ── Vendor Payment Hold Release (every hour at :00) ───────────────────────
  cron.schedule('0 * * * *', async () => {
    try {
      await releaseHeldPayments();
    } catch (e) {
      console.error('[cron] releaseHeldPayments failed:', e);
    }
  });

  // ── 1-day-before hold reminder (daily at 08:00) ───────────────────────────
  cron.schedule('0 8 * * *', async () => {
    try {
      await sendHoldReleaseReminders();
    } catch (e) {
      console.error('[cron] sendHoldReleaseReminders failed:', e);
    }
  });

  // Lease expiry monitor (daily at 00:00)
  cron.schedule('0 0 * * *', async () => {
    try {
      console.log('Running lease expiry monitor...');
      const expiringRes = await query(
        `SELECT l.*, u.unit_number, p.name as property_name, (l.end_date - CURRENT_DATE) as days_left
         FROM leases l
         JOIN units u ON u.id = l.unit_id
         JOIN properties p ON p.id = l.property_id
         WHERE l.status = 'active'
           AND (l.end_date - CURRENT_DATE) <= l.renewal_notice_days
           AND (l.end_date - CURRENT_DATE) > 0`
      );
      for (const lease of expiringRes.rows) {
        try {
          await NotificationService.create({
            userId: lease.tenant_id,
            type: 'lease',
            title: 'Lease Expiring Soon',
            message: `Your lease for Unit ${lease.unit_number} expires in ${lease.days_left} days.`,
            priority: 'high',
            channels: ['in_app', 'email'],
          });
          await NotificationService.create({
            userId: lease.landlord_id,
            type: 'lease',
            title: 'Lease Renewal Reminder',
            message: `Unit ${lease.unit_number} lease expires in ${lease.days_left} days.`,
            priority: 'normal',
            channels: ['in_app'],
          });
          await query("UPDATE leases SET status = 'expiring' WHERE id = $1", [lease.id]);
        } catch (innerError: any) {
          console.error(`[cron] Failed to process lease ${lease.id}:`, innerError);
          // Notify admin about the failure
          try {
            const adminRes = await query('SELECT id FROM users WHERE role = $1 LIMIT 1', ['admin']);
            if (adminRes.rows.length) {
              await NotificationService.create({
                userId: adminRes.rows[0].id,
                type: 'system',
                title: 'Lease Notification Failure',
                message: `Failed to send lease expiration reminder for lease ${lease.id}: ${innerError.message}`,
                priority: 'high',
                channels: ['email', 'in_app'],
              });
            }
          } catch (notifyErr) {
            console.error('[cron] Admin alert failed:', notifyErr);
          }
        }
      }
    } catch (e) {
      console.error('[cron] Lease expiry monitor failed:', e);
    }
  });

  // Rent reminder (daily at 09:00)
  cron.schedule('0 9 * * *', async () => {
    try {
      console.log('Running rent reminder...');
      const dueRes = await query(
        `SELECT * FROM rent_payments
         WHERE status IN ('pending','partial')
           AND due_date <= CURRENT_DATE + INTERVAL '3 days'
           AND reminder_sent = false`
      );
      for (const payment of dueRes.rows) {
        try {
          await NotificationService.create({
            userId: payment.tenant_id,
            type: 'payment',
            title: 'Rent Due Soon',
            message: `Your rent of $${payment.amount_due} is due on ${payment.due_date}.`,
            priority: 'high',
            channels: ['in_app', 'email', 'push'],
          });
          await query('UPDATE rent_payments SET reminder_sent = true WHERE id = $1', [payment.id]);
        } catch (innerError: any) {
          console.error(`[cron] Failed to process rent payment ${payment.id}:`, innerError);
          // Admin alert for rent reminder processing failure
          try {
            const adminRes = await query('SELECT id FROM users WHERE role = $1 LIMIT 1', ['admin']);
            if (adminRes.rows.length) {
              await NotificationService.create({
                userId: adminRes.rows[0].id,
                type: 'system',
                title: 'Rent Reminder Failure',
                message: `Failed to send rent reminder for payment ${payment.id}.`,
                priority: 'high',
                channels: ['email', 'in_app'],
              });
            }
          } catch (notifyErr) {
            console.error('[cron] Admin alert for rent reminder failed:', notifyErr);
          }
        }
      }
    } catch (e) {
      console.error('[cron] Rent reminder failed:', e);
    }
  });

  // Security scan (every 6 hours)
  cron.schedule('0 */6 * * *', async () => {
    console.log('Running security scan...');
    const auditRes = await query(
      `SELECT COUNT(*) as count FROM audit_logs
       WHERE action IN ('FAILED_LOGIN','UNAUTHORIZED_ACCESS')
         AND created_at >= NOW() - INTERVAL '24 hours'`
    );
    const threatCount = parseInt(auditRes.rows[0].count, 10);
    const status = threatCount > 10 ? 'warning' : 'clean';
    await query(
      `INSERT INTO system_health (metric_name, metric_value, status, checked_at)
       VALUES ('last_security_scan', $1, $2, NOW())`,
      [threatCount.toString(), status]
    );
  });

  // Materialized view refresh (every 15 min)
  cron.schedule('*/15 * * * *', async () => {
    await query('REFRESH MATERIALIZED VIEW CONCURRENTLY mv_rent_status');
    await query('REFRESH MATERIALIZED VIEW CONCURRENTLY mv_operational_overview');
  });

  console.log('Cron jobs scheduled');
}
