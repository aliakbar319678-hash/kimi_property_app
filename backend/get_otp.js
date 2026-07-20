const { Pool } = require('pg');
const pool = new Pool({ connectionString: 'postgresql://postgres:Aliakbar@localhost:5432/propadmin' });

async function main() {
  // First, find all tables that might store OTPs
  const tables = await pool.query(
    `SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name`
  );
  console.log('=== ALL TABLES ===');
  tables.rows.forEach(r => console.log(r.table_name));

  // Try to find OTP in users table
  try {
    const users = await pool.query(
      `SELECT email, otp_code, otp_expires_at FROM users ORDER BY created_at DESC LIMIT 5`
    );
    console.log('\n=== LATEST OTP CODES (from users table) ===');
    console.log(JSON.stringify(users.rows, null, 2));
  } catch(e) {
    console.log('\nNo otp_code column in users table:', e.message);
  }

  // Try verification_codes table
  try {
    const codes = await pool.query(
      `SELECT * FROM verification_codes ORDER BY created_at DESC LIMIT 5`
    );
    console.log('\n=== VERIFICATION CODES ===');
    console.log(JSON.stringify(codes.rows, null, 2));
  } catch(e) {
    console.log('No verification_codes table:', e.message);
  }

  await pool.end();
}

main().catch(console.error);
