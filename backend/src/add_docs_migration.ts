import { pool } from './db';

async function migrate() {
    try {
        await pool.query(`ALTER TABLE properties ADD COLUMN IF NOT EXISTS documents JSONB DEFAULT '[]'`);
        console.log("Migration successful");
    } catch (e) {
        console.error("Migration failed", e);
    } finally {
        process.exit();
    }
}
migrate();
