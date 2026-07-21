import { query } from './src/db';

async function run() {
  const res = await query("SELECT email FROM users JOIN user_roles ON users.id = user_roles.user_id WHERE role = 'landlord' LIMIT 1");
  console.log(res.rows);
  process.exit(0);
}
run();
