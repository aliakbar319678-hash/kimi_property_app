import { NotificationService } from '../services/notification.service';
import { query } from '../db';

(async () => {
  try {
    const adminRes = await query('SELECT id FROM users WHERE role = $1 LIMIT 1', ['admin']);
    if (adminRes.rows.length === 0) {
      console.error('No admin user found');
      process.exit(1);
    }
    const adminId = adminRes.rows[0].id;
    const adminAlert = await NotificationService.create({
      userId: adminId,
      type: 'system',
      title: 'Test Admin Alert',
      message: 'This is a test admin alert',
      priority: 'high',
      channels: ['email', 'in_app'],
    });
    console.log('Admin alert created with id:', adminAlert.id);
    const notifRes = await query('SELECT * FROM notifications WHERE id = $1', [adminAlert.id]);
    console.log('Notification entry:', notifRes.rows[0]);
  } catch (err) {
    console.error('Script failed:', err);
  }
  process.exit(0);
})();
