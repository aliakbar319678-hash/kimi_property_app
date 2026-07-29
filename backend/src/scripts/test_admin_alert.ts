import { query } from '../db';
import { NotificationService } from '../services/notification.service';

async function testAdminAlert() {
  console.log('Running test admin alert...');
  try {
    // Simulated error during lease processing
    throw new Error('Simulated lease processing error');
  } catch (innerError: any) {
    console.error('Inner error captured:', innerError.message);
    try {
      const adminRes = await query('SELECT id FROM users WHERE role = $1 LIMIT 1', ['admin']);
      if (adminRes.rows.length) {
        await NotificationService.create({
          userId: adminRes.rows[0].id,
          type: 'error',
          title: 'Test Lease Notification Failure',
          message: `Test failure: ${innerError.message}`,
          priority: 'high',
          channels: ['email', 'in_app'],
        });
        console.log('Admin alert notification created');
      } else {
        console.warn('No admin user found');
      }
    } catch (notifyErr) {
      console.error('Admin alert creation failed:', notifyErr);
    }
  }
}

testAdminAlert()
  .then(() => process.exit(0))
  .catch(err => {
    console.error('Script error:', err);
    process.exit(1);
  });
