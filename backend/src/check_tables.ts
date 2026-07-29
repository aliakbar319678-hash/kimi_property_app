import { pool } from './db';
async function main() {
    const res = await pool.query("SELECT pg_get_constraintdef(oid) FROM pg_constraint WHERE conname = 'properties_type_check'");
    console.log(res.rows);
    process.exit(0);
}
main();
