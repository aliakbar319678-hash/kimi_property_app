import { pool } from '../db';

async function checkConstraints() {
  // Check the category constraint on jobs_posted
  const r = await pool.query(`
    SELECT pg_get_constraintdef(oid) as constraint_def
    FROM pg_constraint
    WHERE conname = 'jobs_posted_category_check'
  `);
  console.log('jobs_posted_category_check:');
  console.log(r.rows[0]?.constraint_def);

  // Check urgency constraint too
  const u = await pool.query(`
    SELECT pg_get_constraintdef(oid) as constraint_def
    FROM pg_constraint
    WHERE conname LIKE '%jobs_posted%'
  `);
  console.log('\nAll jobs_posted constraints:');
  u.rows.forEach((row: any) => console.log(row.constraint_def));

  await pool.end();
}

checkConstraints().catch(e => { console.error(e.message); process.exit(1); });
