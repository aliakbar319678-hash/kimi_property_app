import { query } from './src/db';

async function test() {
  try {
    const res = await query(`
      SELECT column_name FROM information_schema.columns WHERE table_name='enrollments'
    `);
    console.log("Columns:", res.rows.map(r => r.column_name).join(', '));
    console.log("Success:", res.rows.length);
  } catch (e: any) {
    console.error("Error running query:", e.message);
  }
  process.exit();
}
test();
