import { query } from './src/db';

async function check() {
  const res = await query('SELECT id, status, progress_percent FROM enrollments');
  console.log(res.rows);
  
  // also check if there are any quiz attempts that are completed
  process.exit(0);
}
check();
