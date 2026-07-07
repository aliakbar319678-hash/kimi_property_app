const fs = require('fs');
const path = require('path');
const { Pool } = require('pg');

const pool = new Pool({ connectionString: 'postgresql://postgres:1122@localhost:5432/mydatabase' });

async function runMigrations() {
  const client = await pool.connect();
  try {
    const dir = path.join(__dirname, 'src', 'migrations');
    
    // Run 004
    console.log('Running 004_create_platform_settings.sql...');
    const sql004 = fs.readFileSync(path.join(dir, '004_create_platform_settings.sql'), 'utf8');
    await client.query(sql004);
    console.log('004 done.');

    // Run 006
    console.log('Running 006_create_tickets_system.sql...');
    const sql006 = fs.readFileSync(path.join(dir, '006_create_tickets_system.sql'), 'utf8');
    await client.query(sql006);
    console.log('006 done.');

    // Verify
    const tables = await client.query('SELECT table_name FROM information_schema.tables WHERE table_schema = \'public\'');
    const tableNames = tables.rows.map(r => r.table_name);
    console.log('Tickets table exists?', tableNames.includes('tickets'));
    console.log('Platform settings table exists?', tableNames.includes('platform_settings'));

  } catch (err) {
    console.error('Migration error:', err);
  } finally {
    client.release();
    await pool.end();
  }
}

runMigrations();
