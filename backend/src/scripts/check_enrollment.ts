import { query } from '../db';

async function check() {
  const res = await query(
    `DELETE FROM enrollments 
     WHERE user_id IN (
       SELECT u.id FROM users u 
       JOIN user_roles ur ON u.id = ur.user_id 
       WHERE ur.role = 'vendor'
     )`
  );
  console.log('Vendor enrollments deleted.');
  process.exit(0);
}
check();
