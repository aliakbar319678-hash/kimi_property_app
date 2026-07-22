import { Pool, PoolClient, QueryResult, QueryResultRow } from 'pg';
import { config } from '../config';

export const pool = new Pool({
  connectionString: config.databaseUrl,
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

pool.on('error', (err: Error) => {
  console.error('Unexpected DB error', err);
  process.exit(-1);
});

export async function query<T extends QueryResultRow = any>(text: string, params?: any[]): Promise<QueryResult<T>> {
  const start = Date.now();
  const res = await pool.query<T>(text, params);
  const duration = Date.now() - start;
  if (config.nodeEnv === 'development') {
    console.log('Executed query', { text: text.substring(0, 100), duration, rows: res.rowCount });
  }
  return res;
}

export async function withTransaction<T>(fn: (client: PoolClient) => Promise<T>): Promise<T> {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const result = await fn(client);
    await client.query('COMMIT');
    return result;
  } catch (e) {
    await client.query('ROLLBACK');
    throw e;
  } finally {
    client.release();
  }
}

export async function initPostGIS() {
  try {
    await query('CREATE EXTENSION IF NOT EXISTS postgis');
    console.log('✅ PostGIS extension ready');
  } catch (e) {
    console.warn('⚠️  PostGIS not installed - skipping (install via StackBuilder if needed)');
  }
  try {
    await query('CREATE EXTENSION IF NOT EXISTS "uuid-ossp"');
    console.log('✅ uuid-ossp extension ready');
  } catch (e) {
    console.warn('⚠️  uuid-ossp not available - skipping');
  }
  try {
    await query(`
      CREATE TABLE IF NOT EXISTS landlord_payout_accounts (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID REFERENCES users(id) ON DELETE CASCADE UNIQUE,
        bank_name VARCHAR(255) NOT NULL,
        account_holder VARCHAR(255) NOT NULL,
        iban_account_no VARCHAR(255) NOT NULL,
        payout_status VARCHAR(50) DEFAULT 'active',
        created_at TIMESTAMPTZ DEFAULT NOW(),
        updated_at TIMESTAMPTZ DEFAULT NOW()
      );
    `);
    console.log('✅ landlord_payout_accounts table ready');
  } catch (e) {
    console.warn('⚠️ Could not initialize landlord_payout_accounts table:', e);
  }
}
