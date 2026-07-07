const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({ connectionString: process.env.DATABASE_URL });

async function fix() {
  try {
    await pool.query('ALTER TABLE users ADD COLUMN is_active BOOLEAN DEFAULT true');
    console.log('Added is_active column');
  } catch (e) {
    if (e.code === '42701') console.log('Column already exists');
    else console.error(e);
  }
  process.exit();
}
fix();
