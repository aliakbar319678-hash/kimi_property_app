
import { query } from './src/db';
import { NotificationService } from './src/services/notification.service';

async function backfill() {
  try {
    console.log('Fetching old enrollments...');
    const enrollments = await query('SELECT e.user_id, e.course_id, c.title FROM enrollments e JOIN courses c ON e.course_id = c.id');
    console.log('Found enrollments:', enrollments.rows.length);
    
    for (const e of enrollments.rows) {
      console.log('Backfilling enrollment for user', e.user_id, 'course', e.title);
      await NotificationService.createCourseEnrolled(e.user_id, e.course_id, e.title);
    }

    console.log('Fetching old certificates...');
    const certificates = await query('SELECT user_id, course_id, course_name FROM certificates');
    console.log('Found certificates:', certificates.rows.length);
    
    for (const c of certificates.rows) {
      console.log('Backfilling certificate for user', c.user_id, 'course', c.course_name);
      await NotificationService.createCertificateIssued(c.user_id, c.course_name);
    }

    console.log('Done!');
  } catch (err) {
    console.error('ERROR:', err);
  }
  process.exit(0);
}

backfill();

