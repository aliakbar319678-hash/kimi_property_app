import { query } from '../db';

async function run() {
    try {
        console.log('Adding audio_url to modules table...');
        await query(`ALTER TABLE modules ADD COLUMN IF NOT EXISTS audio_url VARCHAR(255);`);
        console.log('Successfully added audio_url column!');
    } catch (e) {
        console.error('Error adding column:', e);
    } finally {
        process.exit(0);
    }
}

run();
