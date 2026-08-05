import { query } from './src/db';
import bcrypt from 'bcryptjs';

async function check() {
  try {
    const res = await query('SELECT * FROM users WHERE email = $1', ['admin@propadmin.io']);
    if (res.rows.length === 0) {
      console.log('Admin not found!');
      return;
    }
    const admin = res.rows[0];
    console.log('Admin user:', admin.id, admin.email, admin.is_active, admin.kyc_status);
    const valid = await bcrypt.compare('Admin123!', admin.password_hash);
    console.log('Password valid:', valid);
  } catch (e) {
    console.error(e);
  }
  process.exit(0);
}
check();
