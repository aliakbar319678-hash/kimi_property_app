import { query } from './src/db';

async function check() {
  try {
    const res = await query('SELECT email, kyc_status, id FROM users ORDER BY created_at DESC LIMIT 5');
    console.log(res.rows);
  } catch (e) {
    console.error(e);
  }
  process.exit(0);
}
check();
