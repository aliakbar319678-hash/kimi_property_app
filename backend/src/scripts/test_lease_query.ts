import { query } from '../db';
async function test() {
  try {
    const res = await query(`
      SELECT l.end_date, CURRENT_DATE, (l.end_date - CURRENT_DATE) as days_left
      FROM leases l LIMIT 1
    `);
    console.log(res.rows[0]);
  } catch(e) {
    console.error('Error:', e);
  }
  process.exit(0);
}
test();
