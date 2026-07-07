/**
 * fix_and_seed.js
 * Run with: node fix_and_seed.js
 *
 * 1. Adds missing columns to users table (onboarding_step, created_by)
 * 2. Adds missing columns to platform_configs (platform_fee_percentage, hold_period_days)
 * 3. Seeds an admin user (admin@propadmin.io / Admin@1234)
 * 4. Seeds default platform config
 * 5. Verifies everything works (login test)
 */

const { Pool } = require('pg');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');

const pool = new Pool({
  connectionString: 'postgresql://postgres:1122@localhost:5432/mydatabase'
});

const JWT_SECRET = 'your-super-secret-jwt-key-min-32-chars';

async function run() {
  const client = await pool.connect();
  try {
    console.log('=== PropAdmin Database Fix & Seed ===\n');

    // ─── 1. Fix users table ────────────────────────────────────────────────
    console.log('1. Fixing users table...');

    // Add onboarding_step column if missing
    await client.query(`
      ALTER TABLE users
      ADD COLUMN IF NOT EXISTS onboarding_step INT NOT NULL DEFAULT 5
    `);
    console.log('   ✓ onboarding_step column ensured');

    // Add created_by column if missing
    await client.query(`
      ALTER TABLE users
      ADD COLUMN IF NOT EXISTS created_by UUID REFERENCES users(id) ON DELETE SET NULL
    `);
    console.log('   ✓ created_by column ensured');

    // Add phone column if missing
    await client.query(`
      ALTER TABLE users
      ADD COLUMN IF NOT EXISTS phone VARCHAR(30)
    `);
    console.log('   ✓ phone column ensured');

    // ─── 2. Fix platform_configs table ────────────────────────────────────
    console.log('\n2. Fixing platform_configs table...');

    await client.query(`
      ALTER TABLE platform_configs
      ADD COLUMN IF NOT EXISTS platform_fee_percentage DECIMAL(6,3) NOT NULL DEFAULT 5.0
    `);
    console.log('   ✓ platform_fee_percentage column ensured');

    await client.query(`
      ALTER TABLE platform_configs
      ADD COLUMN IF NOT EXISTS hold_period_days INT NOT NULL DEFAULT 5
    `);
    console.log('   ✓ hold_period_days column ensured');

    // commission_percent may already exist but let's ensure defaults are usable
    await client.query(`
      ALTER TABLE platform_configs
      ADD COLUMN IF NOT EXISTS commission_percent DECIMAL(6,3) NOT NULL DEFAULT 5.0
    `);
    await client.query(`
      ALTER TABLE platform_configs
      ADD COLUMN IF NOT EXISTS admin_fee DECIMAL(10,2) NOT NULL DEFAULT 0.00
    `);
    await client.query(`
      ALTER TABLE platform_configs
      ADD COLUMN IF NOT EXISTS late_fee_percent DECIMAL(6,3) NOT NULL DEFAULT 10.0
    `);
    await client.query(`
      ALTER TABLE platform_configs
      ADD COLUMN IF NOT EXISTS currency VARCHAR(10) NOT NULL DEFAULT 'USD'
    `);
    console.log('   ✓ All platform_configs columns ensured');

    // ─── 3. Ensure regions table has at least one region ──────────────────
    console.log('\n3. Ensuring default region...');
    let regionId;
    const regionRes = await client.query(`SELECT id FROM regions WHERE code = 'US-NYC' LIMIT 1`);
    if (regionRes.rows.length === 0) {
      regionId = uuidv4();
      await client.query(`
        INSERT INTO regions (id, code, name)
        VALUES ($1, 'US-NYC', 'New York City, USA')
        ON CONFLICT DO NOTHING
      `, [regionId]);
      console.log('   ✓ Created US-NYC region');
    } else {
      regionId = regionRes.rows[0].id;
      console.log('   ✓ Region US-NYC already exists');
    }

    // ─── 4. Seed admin user ────────────────────────────────────────────────
    console.log('\n4. Seeding admin user...');

    const ADMIN_EMAIL = 'admin@propadmin.io';
    const ADMIN_PASSWORD = 'Admin@1234';

    const existingAdmin = await client.query(
      'SELECT id FROM users WHERE email = $1',
      [ADMIN_EMAIL]
    );

    let adminId;
    if (existingAdmin.rows.length > 0) {
      adminId = existingAdmin.rows[0].id;
      // Update password in case it was different
      const hash = await bcrypt.hash(ADMIN_PASSWORD, 12);
      await client.query(
        'UPDATE users SET password_hash = $1, is_active = true, onboarding_step = 5 WHERE id = $2',
        [hash, adminId]
      );
      console.log('   ✓ Admin user updated (password reset to Admin@1234)');
    } else {
      adminId = uuidv4();
      const hash = await bcrypt.hash(ADMIN_PASSWORD, 12);
      await client.query(`
        INSERT INTO users (id, email, phone, password_hash, display_name, region_id, is_active, onboarding_step)
        VALUES ($1, $2, '+1 (555) 000-0001', $3, 'System Administrator', $4, true, 5)
      `, [adminId, ADMIN_EMAIL, hash, regionId]);
      console.log('   ✓ Admin user created');
    }

    // Ensure admin role
    const adminRole = await client.query(
      `SELECT id FROM user_roles WHERE user_id = $1 AND role = 'admin'`,
      [adminId]
    );
    if (adminRole.rows.length === 0) {
      await client.query(
        `INSERT INTO user_roles (user_id, role, is_primary, permissions)
         VALUES ($1, 'admin', true, $2)`,
        [adminId, JSON.stringify({
          can_view_tickets: true,
          can_resolve_tickets: true,
          can_manage_payments: true,
          can_view_reports: true,
          can_manage_staff: true,
          can_manage_settings: true,
        })]
      );
      console.log('   ✓ Admin role assigned');
    } else {
      console.log('   ✓ Admin role already exists');
    }

    // Ensure user_profile row exists
    const profileCheck = await client.query(
      'SELECT user_id FROM user_profiles WHERE user_id = $1',
      [adminId]
    );
    if (profileCheck.rows.length === 0) {
      await client.query(
        `INSERT INTO user_profiles (user_id, legal_first_name, legal_last_name)
         VALUES ($1, 'System', 'Administrator')`,
        [adminId]
      );
      console.log('   ✓ Admin profile created');
    }

    // ─── 5. Seed platform_configs ──────────────────────────────────────────
    console.log('\n5. Seeding platform config...');
    const configExists = await client.query('SELECT id FROM platform_configs LIMIT 1');
    if (configExists.rows.length === 0) {
      const configId = uuidv4();
      await client.query(`
        INSERT INTO platform_configs
          (id, commission_percent, admin_fee, late_fee_percent, currency,
           platform_fee_percentage, hold_period_days, updated_by)
        VALUES ($1, 5.0, 0.00, 10.0, 'USD', 5.0, 5, $2)
      `, [configId, adminId]);
      console.log('   ✓ Platform config seeded');
    } else {
      // Update existing to ensure new columns have values
      await client.query(`
        UPDATE platform_configs
        SET platform_fee_percentage = COALESCE(platform_fee_percentage, 5.0),
            hold_period_days = COALESCE(hold_period_days, 5),
            commission_percent = COALESCE(commission_percent, 5.0),
            currency = COALESCE(currency, 'USD')
      `);
      console.log('   ✓ Platform config updated with defaults');
    }

    // ─── 6. Seed sample staff members ─────────────────────────────────────
    console.log('\n6. Seeding sample staff members...');

    const staffSeed = [
      { email: 'staff.support@propadmin.io', name: 'Ahmed Khan', dept: 'Support' },
      { email: 'staff.finance@propadmin.io', name: 'Sara Ahmed', dept: 'Finance' },
    ];

    for (const s of staffSeed) {
      const existingStaff = await client.query('SELECT id FROM users WHERE email = $1', [s.email]);
      if (existingStaff.rows.length === 0) {
        const staffId = uuidv4();
        const hash = await bcrypt.hash('Staff@1234', 12);
        await client.query(`
          INSERT INTO users (id, email, password_hash, display_name, department, is_active, onboarding_step, created_by, region_id)
          VALUES ($1, $2, $3, $4, $5, true, 5, $6, $7)
        `, [staffId, s.email, hash, s.name, s.dept, adminId, regionId]);

        await client.query(`
          INSERT INTO user_roles (user_id, role, is_primary, permissions)
          VALUES ($1, 'staff', true, $2)
        `, [staffId, JSON.stringify({
          can_view_tickets: true,
          can_resolve_tickets: s.dept === 'Support',
          can_manage_payments: s.dept === 'Finance',
          can_view_reports: true,
          can_manage_staff: false,
          can_manage_settings: false,
        })]);

        await client.query(`
          INSERT INTO user_profiles (user_id) VALUES ($1)
        `, [staffId]);

        console.log(`   ✓ Staff member created: ${s.name} (${s.email})`);
      } else {
        console.log(`   ✓ Staff member already exists: ${s.email}`);
      }
    }

    // ─── 7. Verification: Test login ──────────────────────────────────────
    console.log('\n7. Verifying login works...');
    const loginCheck = await client.query(
      `SELECT id, email, password_hash, is_active, onboarding_step
       FROM users WHERE email = $1`,
      [ADMIN_EMAIL]
    );
    const adminUser = loginCheck.rows[0];
    const valid = await bcrypt.compare(ADMIN_PASSWORD, adminUser.password_hash);
    if (valid) {
      const rolesRes = await client.query('SELECT role FROM user_roles WHERE user_id = $1', [adminUser.id]);
      const roles = rolesRes.rows.map(r => r.role);
      const token = jwt.sign({ userId: adminUser.id, roles }, JWT_SECRET, { expiresIn: 3600 });
      console.log('   ✓ Login verified! JWT generated successfully');
      console.log('   Token (first 60 chars):', token.substring(0, 60) + '...');
      console.log('   Roles:', roles);
    } else {
      console.log('   ✗ Login verification FAILED!');
    }

    // ─── 8. Summary ───────────────────────────────────────────────────────
    console.log('\n=== FIX COMPLETE ===');
    console.log('\nAdmin Credentials:');
    console.log('  Email:    admin@propadmin.io');
    console.log('  Password: Admin@1234');
    console.log('\nSample Staff Credentials:');
    console.log('  Email:    staff.support@propadmin.io  / Staff@1234');
    console.log('  Email:    staff.finance@propadmin.io  / Staff@1234');
    console.log('\nNow restart the Node backend and re-login to the admin panel.');
    console.log('The token will be stored in session and all forms will work.\n');

  } catch (err) {
    console.error('\n✗ ERROR:', err.message);
    console.error(err);
  } finally {
    client.release();
    await pool.end();
  }
}

run();
