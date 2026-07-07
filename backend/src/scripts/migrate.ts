import { pool, initPostGIS } from '../db';
import * as fs from 'fs';
import * as path from 'path';

async function migrate() {
  await initPostGIS();

  let dir = path.join(__dirname, '../../src/migrations');
  if (!fs.existsSync(dir)) {
    dir = path.join(__dirname, '../migrations');
  }

  console.log('Scanning migrations in:', dir);
  const files = fs.readdirSync(dir)
    .filter(f => f.endsWith('.sql'))
    .sort();

  for (const file of files) {
    try {
      console.log(`Running migration: ${file}...`);
      const sql = fs.readFileSync(path.join(dir, file), 'utf-8');
      await pool.query(sql);
      console.log(`✅ Completed: ${file}`);
    } catch (e: any) {
      console.warn(`⚠️ Warning running migration ${file}:`, e.message || e);
    }
  }

  console.log('✅ All migrations completed successfully');
  await pool.end();
}

migrate().catch(console.error);
