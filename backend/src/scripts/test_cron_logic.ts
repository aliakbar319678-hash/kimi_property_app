import { query } from '../db';
import { NotificationService } from '../services/notification.service';

async function test() {
  console.log('Running lease expiry monitor test...');
  try {
    const expiringRes = await query(
      `SELECT l.*, u.unit_number, p.name as property_name, (l.end_date - CURRENT_DATE) as days_left
       FROM leases l
       JOIN units u ON u.id = l.unit_id
       JOIN properties p ON p.id = l.property_id
       WHERE l.status = 'active'
         AND (l.end_date - CURRENT_DATE) <= l.renewal_notice_days
         AND (l.end_date - CURRENT_DATE) > 0`
    );
    console.log(`Found ${expiringRes.rows.length} leases to process.`);
    for (const lease of expiringRes.rows) {
      console.log(`Processing lease ${lease.id}...`);
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
    console.log('Finished without errors.');
  } catch(e) {
    console.error('Error occurred:', e);
  }
  process.exit(0);
}
test();
