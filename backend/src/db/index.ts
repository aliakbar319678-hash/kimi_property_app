import { Pool, PoolClient, QueryResult } from 'pg';
import { config } from '../config';

export const pool = new Pool({
  connectionString: config.databaseUrl,
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

pool.on('error', (err: any) => {
  console.error('Unexpected DB error', err);
  process.exit(-1);
});

export async function query<T extends import('pg').QueryResultRow = any>(text: string, params?: any[]): Promise<QueryResult<T>> {
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
  } catch (err: any) {
    console.warn('⚠️  PostGIS extension not available (spatial features disabled):', err.message);
  }
  try {
    await query('CREATE EXTENSION IF NOT EXISTS "uuid-ossp"');
    console.log('✅ uuid-ossp extension ready');
  } catch (err: any) {
    console.warn('⚠️  uuid-ossp extension not available:', err.message);
  }
}
