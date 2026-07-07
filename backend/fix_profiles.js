const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({ connectionString: process.env.DATABASE_URL });

async function fix() {
  try {
    await pool.query('ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS legal_first_name VARCHAR(100)');
    await pool.query('ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS legal_last_name VARCHAR(100)');
    await pool.query('ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS avatar_url VARCHAR(255)');
    console.log('Added missing columns to user_profiles');
  } catch (e) {
    console.error(e);
  }
  process.exit();
}
fix();
