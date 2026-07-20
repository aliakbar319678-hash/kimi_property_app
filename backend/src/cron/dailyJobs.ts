import cron from 'node-cron';
import { query } from '../db';
import { NotificationService } from '../services/notification.service';

export function startCronJobs() {
  // Lease expiry monitor (daily at 00:00)
  cron.schedule('0 0 * * *', async () => {
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
    }
  });

  // Rent reminder (daily at 09:00)
  cron.schedule('0 9 * * *', async () => {
    console.log('Running rent reminder...');
    const dueRes = await query(
      `SELECT * FROM rent_payments
       WHERE status IN ('pending','partial')
         AND due_date <= CURRENT_DATE + INTERVAL '3 days'
         AND reminder_sent = false`
    );
    for (const payment of dueRes.rows) {
      await NotificationService.create({
        userId: payment.tenant_id,
        type: 'payment',
        title: 'Rent Due Soon',
        message: `Your rent of $${payment.amount_due} is due on ${payment.due_date}.`,
        priority: 'high',
        channels: ['in_app', 'email', 'push'],
      });
      await query('UPDATE rent_payments SET reminder_sent = true WHERE id = $1', [payment.id]);
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

  // Rejected property deadline warning (daily at 10:00)
  cron.schedule('0 10 * * *', async () => {
    console.log('Running rejected property warning monitor...');
    const warningRes = await query(
      `SELECT id, landlord_id, name, rejection_deadline
       FROM properties
       WHERE status = 'rejected'
         AND rejection_warning_sent = false
         AND rejection_deadline <= NOW() + INTERVAL '24 hours'`
    );
    for (const prop of warningRes.rows) {
      await NotificationService.create({
        userId: prop.landlord_id,
        type: 'system',
        title: 'Property Rejection Deadline Warning',
        message: `Your property "${prop.name}" removal deadline is tomorrow at ${new Date(prop.rejection_deadline).toLocaleString()}. Please correct the issues to prevent archiving.`,
        priority: 'high',
        channels: ['in_app'],
      });
      await query('UPDATE properties SET rejection_warning_sent = true WHERE id = $1', [prop.id]);
    }
  });

  // Rejected property auto-archiver (daily at 02:00)
  cron.schedule('0 2 * * *', async () => {
    console.log('Running rejected property auto-archiver...');
    const expiredRes = await query(
      `SELECT id, landlord_id, name
       FROM properties
       WHERE status = 'rejected'
         AND rejection_deadline < NOW()`
    );
    for (const prop of expiredRes.rows) {
      await query("UPDATE properties SET status = 'archived', updated_at = NOW() WHERE id = $1", [prop.id]);
      await NotificationService.create({
        userId: prop.landlord_id,
        type: 'system',
        title: 'Property Archived',
        message: `Your property "${prop.name}" has been archived because the deadline to correct rejection reasons has passed.`,
        priority: 'high',
        channels: ['in_app'],
      });
    }
  });

  // Late fee autocalculator (daily at 01:00)
  cron.schedule('0 1 * * *', async () => {
    console.log('Running automatic late fee calculator (Day 5 penalty)...');
    try {
      const lateRentPayments = await query(
        `SELECT id, lease_id, tenant_id, amount_due, due_date FROM rent_payments
         WHERE status IN ('pending', 'late')
           AND due_date <= CURRENT_DATE - INTERVAL '5 days'
           AND late_fee_applied = 0.00`
      );

      for (const payment of lateRentPayments.rows) {
        const penaltyFee = 50.00;
        const newAmount = parseFloat(payment.amount_due) + penaltyFee;

        // Apply penalty to rent_payments
        await query(
          `UPDATE rent_payments 
           SET amount_due = $1, late_fee_applied = $2, status = 'late'
           WHERE id = $3`,
          [newAmount, penaltyFee, payment.id]
        );

        // Record a late payment notice
        await query(
          `INSERT INTO late_payment_notices (lease_id, tenant_id, amount_due, late_fee_applied, days_late, notice_status)
           VALUES ($1, $2, $3, $4, 5, 'SENT')`,
          [payment.lease_id, payment.tenant_id, newAmount, penaltyFee]
        );

        console.log(`Successfully applied $50 late fee penalty to payment ID: ${payment.id}`);
      }
    } catch (err) {
      console.error('Error calculating late fees:', err);
    }
  });

  console.log('Cron jobs scheduled');
}
