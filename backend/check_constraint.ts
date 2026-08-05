import { query } from './src/db';
async function check() {
  const res = await query("SELECT conname, pg_get_constraintdef(oid) as def FROM pg_constraint WHERE conname = 'notifications_type_check'");
  console.log(JSON.stringify(res.rows, null, 2));
  process.exit(0);
}
check();
