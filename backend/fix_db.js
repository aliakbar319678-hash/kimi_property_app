const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgres://postgres:postgres@localhost:5432/propadmin',
});

async function fixDb() {
  try {
    await pool.query('ALTER TABLE invoices ADD COLUMN IF NOT EXISTS gateway_transaction_id VARCHAR(255);');
    console.log('✅ Added to invoices');
    await pool.query('ALTER TABLE rent_payments ADD COLUMN IF NOT EXISTS gateway_transaction_id VARCHAR(255);');
    console.log('✅ Added to rent_payments');
  } catch (error) {
    console.error('❌ Error adding column:', error.message);
  } finally {
    await pool.end();
  }
}

fixDb();
