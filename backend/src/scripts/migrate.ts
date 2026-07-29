import { pool, initPostGIS } from '../db';
import * as fs from 'fs';
import * as path from 'path';

async function migrate() {
  await initPostGIS();
  const migrationsDir = path.join(__dirname, '../../src/migrations');
  const files = fs.readdirSync(migrationsDir).filter(f => f.endsWith('.sql')).sort();
  for (const file of files) {
    const filePath = path.join(migrationsDir, file);
    const sql = fs.readFileSync(filePath, 'utf-8');
    try {
      await pool.query(sql);
      console.log(`✅ Executed migration ${file}`);
    } catch (e) {
      console.warn(`⚠️ Skipping migration ${file}: ${(e as any).message}`);
    }
  }
  console.log('✅ All migrations attempted');
  await pool.end();
}

migrate().catch(console.error);
