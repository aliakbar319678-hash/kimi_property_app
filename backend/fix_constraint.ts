import { query } from './src/db';
import { NotificationService } from './src/services/notification.service';

async function fix() {
  try {
    // Step 1: Drop old constraint
    console.log('Dropping old constraint...');
    await query("ALTER TABLE notifications DROP CONSTRAINT IF EXISTS notifications_type_check");
    
    // Step 2: Add updated constraint with LMS types
    console.log('Adding updated constraint...');
    await query("ALTER TABLE notifications ADD CONSTRAINT notifications_type_check CHECK (type IN ('payment', 'maintenance', 'lease', 'course', 'system', 'fraud_alert', 'job_posted', 'bid_status', 'job_assignment', 'conditional_approval', 'lms_enrollment', 'lms_certificate', 'lms_discussion_reply', 'lease_expiry', 'payment_failed', 'payment_success'))");
    console.log('Constraint updated!');
    
    // Step 3: Backfill notifications for old enrollments
    console.log('Fetching old enrollments...');
    const enrollments = await query('SELECT e.user_id, e.course_id, c.title FROM enrollments e JOIN courses c ON e.course_id = c.id');
    console.log('Found enrollments:', enrollments.rows.length);
    
    for (const e of enrollments.rows) {
      console.log('Creating enrollment notification for:', e.title);
      await NotificationService.createCourseEnrolled(e.user_id, e.course_id, e.title);
    }

    // Step 4: Backfill notifications for old certificates
    console.log('Fetching old certificates...');
    const certificates = await query('SELECT user_id, course_id, course_name FROM certificates');
    console.log('Found certificates:', certificates.rows.length);
    
    for (const c of certificates.rows) {
      console.log('Creating certificate notification for:', c.course_name);
      await NotificationService.createCertificateIssued(c.user_id, c.course_name);
    }

    // Step 5: Verify
    const count = await query('SELECT count(*) FROM notifications');
    console.log('Total notifications in DB:', count.rows[0].count);

    console.log('ALL DONE!');
  } catch (err) {
    console.error('ERROR:', err);
  }
  process.exit(0);
}

fix();
