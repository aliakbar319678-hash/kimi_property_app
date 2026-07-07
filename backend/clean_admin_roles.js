// clean_admin_roles.js — remove duplicate roles for admin user
const { Pool } = require('pg');
const pool = new Pool({ connectionString: 'postgresql://postgres:1122@localhost:5432/mydatabase' });

async function clean() {
  const client = await pool.connect();
  try {
    // Get admin user id
    const res = await client.query("SELECT id FROM users WHERE email = 'admin@propadmin.io'");
    const adminId = res.rows[0].id;
    console.log('Admin ID:', adminId);

    // Delete ALL roles for admin
    await client.query('DELETE FROM user_roles WHERE user_id = $1', [adminId]);
    console.log('Deleted all existing roles');

    // Insert ONE clean admin role
    await client.query(`
      INSERT INTO user_roles (user_id, role, is_primary, permissions)
      VALUES ($1, 'admin', true, $2)
    `, [adminId, JSON.stringify({
      can_view_tickets: true,
      can_resolve_tickets: true,
      can_manage_payments: true,
      can_view_reports: true,
      can_manage_staff: true,
      can_manage_settings: true,
    })]);
    console.log("Inserted single 'admin' role");

    // Verify
    const verif = await client.query('SELECT role FROM user_roles WHERE user_id = $1', [adminId]);
    console.log('Final roles:', verif.rows.map(r => r.role));

    // Full end-to-end login test via DB
    const bcrypt = require('bcryptjs');
    const jwt = require('jsonwebtoken');
    const userRes = await client.query(
      'SELECT id, email, password_hash, is_active, onboarding_step FROM users WHERE email = $1',
      ['admin@propadmin.io']
    );
    const u = userRes.rows[0];
    const ok = await bcrypt.compare('Admin@1234', u.password_hash);
    if (ok) {
      const rolesRes = await client.query('SELECT role FROM user_roles WHERE user_id = $1', [u.id]);
      const roles = rolesRes.rows.map(r => r.role);
      const token = jwt.sign({ userId: u.id, roles }, 'your-super-secret-jwt-key-min-32-chars', { expiresIn: 3600 });
      console.log('\n✓ LOGIN OK — Token roles:', roles);
      console.log('Token (preview):', token.substring(0, 80) + '...');
    } else {
      console.log('✗ Login FAILED');
    }
  } catch (e) {
    console.error('Error:', e.message);
  } finally {
    client.release();
    await pool.end();
  }
}
clean();
