// src/scripts/backfill_lease_notifications.ts
import { query } from '../db';
import { NotificationService } from '../services/notification.service';

async function backfillLeaseNotifications() {
  console.log('Running backfill lease notifications...');
  const res = await query(`
    SELECT l.*, u.unit_number, p.name as property_name, (l.end_date - CURRENT_DATE) as days_left
    FROM leases l
    JOIN units u ON u.id = l.unit_id
    JOIN properties p ON p.id = l.property_id
    WHERE l.status = 'active'
      AND (l.end_date - CURRENT_DATE) <= l.renewal_notice_days
      AND (l.end_date - CURRENT_DATE) > 0
  `);

  const leases = res.rows;
  console.log(`Found ${leases.length} lease(s) needing notification.`);

  for (const lease of leases) {
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
      // Mark as expiring to avoid duplicate notifications
      await query('UPDATE leases SET status = $1 WHERE id = $2', ['expiring', lease.id]);
    } catch (err) {
      console.error(`Failed to notify lease ${lease.id}:`, err);
    }
  }
  console.log('Backfill completed.');
}

backfillLeaseNotifications()
  .then(() => process.exit(0))
  .catch(err => {
    console.error('Backfill script error:', err);
    process.exit(1);
  });
