import { pool } from './db';
async function main() {
    const tables = ['units', 'user_profiles', 'support_tickets', 'audit_logs', 'notifications'];
    for(const t of tables) {
        const res = await pool.query("SELECT column_name, data_type FROM information_schema.columns WHERE table_name=$1", [t]);
        console.log(`\nTable: ${t}`);
        console.log(res.rows);
    }
    process.exit(0);
}
main();
