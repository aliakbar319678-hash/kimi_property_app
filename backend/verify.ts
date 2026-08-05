import { query } from './src/db';

async function verify() {
  try {
    // 1. Check who is the admin user (X-Admin-Key resolves to this)
    const adminRes = await query("SELECT u.id, u.email FROM users u JOIN user_roles r ON r.user_id = u.id WHERE r.role IN ('super_admin', 'admin') AND u.is_active = true ORDER BY u.created_at ASC LIMIT 1");
    console.log('Admin user (X-Admin-Key resolves to):', JSON.stringify(adminRes.rows[0]));

    // 2. Check enrollment user IDs
    const enrollRes = await query('SELECT DISTINCT user_id FROM enrollments');
    console.log('Enrollment user IDs:', JSON.stringify(enrollRes.rows));

    // 3. Check all notifications with their user_ids
    const notifRes = await query("SELECT id, user_id, type, title, is_read, created_at FROM notifications WHERE type IN ('lms_enrollment', 'lms_certificate') ORDER BY created_at DESC");
    console.log('LMS Notifications in DB:', JSON.stringify(notifRes.rows, null, 2));

    // 4. Check notifications for admin user specifically
    const adminId = adminRes.rows[0]?.id;
    if (adminId) {
      const adminNotifs = await query('SELECT count(*) FROM notifications WHERE user_id = ', [adminId]);
      console.log('Notifications for admin user:', adminNotifs.rows[0].count);
    }

    // 5. Check student@test.com user
    const studentRes = await query("SELECT id, email FROM users WHERE email = 'student@test.com'");
    console.log('student@test.com user:', JSON.stringify(studentRes.rows[0]));
    if (studentRes.rows[0]) {
      const studentNotifs = await query('SELECT count(*) FROM notifications WHERE user_id = ', [studentRes.rows[0].id]);
      console.log('Notifications for student@test.com:', studentNotifs.rows[0].count);
    }
  } catch (err) {
    console.error('ERROR:', err);
  }
  process.exit(0);
}

verify();
