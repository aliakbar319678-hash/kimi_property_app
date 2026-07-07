const { Pool } = require('pg');
const pool = new Pool({ connectionString: 'postgresql://postgres:1122@localhost:5432/mydatabase' });

async function fixConstraint() {
  const client = await pool.connect();
  try {
    await client.query('ALTER TABLE user_roles DROP CONSTRAINT IF EXISTS user_roles_role_check');
    console.log('Dropped old constraint');

    const newConstraint = `ALTER TABLE user_roles ADD CONSTRAINT user_roles_role_check CHECK (
      role IN ('super_admin','admin','landlord','property_manager','tenant','vendor','lms_instructor','staff')
    )`;
    await client.query(newConstraint);
    console.log('Added new constraint with staff role');
  } catch (e) {
    console.error('Error:', e.message);
  } finally {
    client.release();
    await pool.end();
  }
}

fixConstraint();
