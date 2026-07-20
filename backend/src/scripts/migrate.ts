import { pool, initPostGIS } from '../db';
import * as fs from 'fs';
import * as path from 'path';

async function migrate() {
  await initPostGIS();
  const migrationsDir = path.join(__dirname, '../../src/migrations');
  
  if (!fs.existsSync(migrationsDir)) {
    throw new Error(`Migrations directory not found: ${migrationsDir}`);
  }

  const files = fs.readdirSync(migrationsDir)
    .filter(file => file.endsWith('.sql'))
    .sort();

  console.log(`🔍 Found ${files.length} migration files to run.`);

  for (const file of files) {
    console.log(`🏃 Running migration: ${file}`);
    const filePath = path.join(migrationsDir, file);
    const sql = fs.readFileSync(filePath, 'utf-8');
    await pool.query(sql);
    console.log(`✅ Completed: ${file}`);
  }

  await pool.end();
  console.log('🎉 All migrations completed successfully');
}

migrate().catch((err) => {
  console.error('❌ Migration failed:', err);
  process.exit(1);
});
