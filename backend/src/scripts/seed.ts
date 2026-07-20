import { pool, query } from '../db';
import bcrypt from 'bcryptjs';
import { config } from '../config';

async function seed() {
  console.log('🌱 Seeding database...');

  // Regions
  await query(
    `INSERT INTO regions (code, name, currency, locale, timezone, is_active) VALUES
     ('US-NYC', 'New York, USA', 'USD', 'en-US', 'America/New_York', true),
     ('SA-RUH', 'Riyadh, Saudi Arabia', 'SAR', 'ar-SA', 'Asia/Riyadh', true),
     ('GB-LON', 'London, UK', 'GBP', 'en-GB', 'Europe/London', true)
     ON CONFLICT DO NOTHING`
  );

  const hash = await bcrypt.hash('Admin123!', config.bcryptRounds);

  // Super Admin
  const adminRes = await query(
    `INSERT INTO users (id, email, password_hash, display_name, kyc_status, is_active, region_id)
     VALUES (uuid_generate_v4(), 'admin@propadmin.io', $1, 'Alex Thompson', 'approved', true, (SELECT id FROM regions WHERE code = 'US-NYC'))
     ON CONFLICT (email) DO UPDATE SET password_hash = $1 RETURNING id`,
    [hash]
  );
  const adminId = adminRes.rows[0].id;

  await query(
    `INSERT INTO user_roles (user_id, role, is_primary) VALUES ($1, 'super_admin', true)
     ON CONFLICT DO NOTHING`,
    [adminId]
  );

  // Landlord
  const landlordRes = await query(
    `INSERT INTO users (id, email, password_hash, display_name, kyc_status, is_active, region_id)
     VALUES (uuid_generate_v4(), 'landlord@example.com', $1, 'Marcus Thorne', 'approved', true, (SELECT id FROM regions WHERE code = 'US-NYC'))
     ON CONFLICT (email) DO UPDATE SET password_hash = $1 RETURNING id`,
    [hash]
  );
  const landlordId = landlordRes.rows[0].id;
  await query(
    `INSERT INTO user_roles (user_id, role, is_primary) VALUES ($1, 'landlord', true)
     ON CONFLICT DO NOTHING`,
    [landlordId]
  );

  // Tenant
  const tenantRes = await query(
    `INSERT INTO users (id, email, password_hash, display_name, kyc_status, is_active, region_id)
     VALUES (uuid_generate_v4(), 'tenant@example.com', $1, 'John Smith', 'approved', true, (SELECT id FROM regions WHERE code = 'US-NYC'))
     ON CONFLICT (email) DO UPDATE SET password_hash = $1 RETURNING id`,
    [hash]
  );
  const tenantId = tenantRes.rows[0].id;
  await query(
    `INSERT INTO user_roles (user_id, role, is_primary) VALUES ($1, 'tenant', true)
     ON CONFLICT DO NOTHING`,
    [tenantId]
  );

  // Vendor
  const vendorRes = await query(
    `INSERT INTO users (id, email, password_hash, display_name, kyc_status, is_active, region_id)
     VALUES (uuid_generate_v4(), 'vendor@example.com', $1, 'Mike Plumbing', 'approved', true, (SELECT id FROM regions WHERE code = 'US-NYC'))
     ON CONFLICT (email) DO UPDATE SET password_hash = $1 RETURNING id`,
    [hash]
  );
  const vendorId = vendorRes.rows[0].id;
  await query(
    `INSERT INTO user_roles (user_id, role, is_primary) VALUES ($1, 'vendor', true)
     ON CONFLICT DO NOTHING`,
    [vendorId]
  );

  // Sample Property
  const propRes = await query(
    `INSERT INTO properties (landlord_id, manager_id, region_id, name, address_line1, city, state_province, postal_code, country_code, type, status, verification_status, amenities, location)
     VALUES ($1, $1, (SELECT id FROM regions WHERE code = 'US-NYC'), 'Sunset Heights Apts', '123 Broadway', 'New York', 'NY', '10001', 'US', 'apartment', 'active', 'approved',
     '["ac","laundry","parking"]', ST_SetSRID(ST_MakePoint(-74.006, 40.7128), 4326))
     RETURNING id`,
    [landlordId]
  );
  const propertyId = propRes.rows[0].id;

  // Sample Unit
  const unitRes = await query(
    `INSERT INTO units (property_id, unit_number, bedrooms, bathrooms, square_feet, rent_amount, deposit_amount, status, available_date)
     VALUES ($1, '402', 2, 2, 1450, 2450.00, 1200.00, 'occupied', '2023-01-01')
     RETURNING id`,
    [propertyId]
  );
  const unitId = unitRes.rows[0].id;

  // Sample Lease
  const leaseRes = await query(
    `INSERT INTO leases (tenant_id, unit_id, property_id, landlord_id, start_date, end_date, rent_amount, deposit_amount, status, payment_schedule, auto_renew)
     VALUES ($1, $2, $3, $4, '2023-01-01', '2026-12-31', 2450.00, 1200.00, 'active', 'monthly', false)
     ON CONFLICT (tenant_id, unit_id, status) WHERE status IN ('active', 'expiring') DO UPDATE SET rent_amount = 2450.00 RETURNING id`,
    [tenantId, unitId, propertyId, landlordId]
  );
  const leaseId = leaseRes.rows[0]?.id;

  // Rent Payments
  await query(
    `INSERT INTO rent_payments (lease_id, tenant_id, property_id, unit_id, amount_due, amount_paid, status, due_date, paid_date, payment_method)
     VALUES 
     ($1, $2, $3, $4, 2450.00, 2450.00, 'paid', CURRENT_DATE - INTERVAL '1 month', CURRENT_DATE - INTERVAL '28 days', 'stripe'),
     ($1, $2, $3, $4, 2450.00, 0.00, 'pending', CURRENT_DATE + INTERVAL '5 days', NULL, NULL),
     ($1, $2, $3, $4, 2450.00, 500.00, 'partial', CURRENT_DATE - INTERVAL '5 days', CURRENT_DATE - INTERVAL '4 days', 'stripe')`,
    [leaseId, tenantId, propertyId, unitId]
  );

  // Transactions
  await query(
    `INSERT INTO transactions (payer_id, payee_id, property_id, unit_id, lease_id, type, amount, currency, status, gateway)
     VALUES
     ($2, $1, $3, $4, $5, 'rent', 2450.00, 'USD', 'completed', 'stripe'),
     ($2, $1, $3, $4, $5, 'deposit', 1200.00, 'USD', 'completed', 'stripe')`,
    [landlordId, tenantId, propertyId, unitId, leaseId]
  );

  // Work Orders
  const workOrderRes = await query(
    `INSERT INTO work_orders (property_id, unit_id, tenant_id, landlord_id, title, description, category, priority, status, budget_min, budget_max, currency)
     VALUES
     ($1, $2, $3, $4, 'Leaking kitchen faucet', 'Water is dripping constantly from the kitchen sink tap.', 'plumbing', 'medium', 'open', 50.00, 200.00, 'USD')
     RETURNING id`,
    [propertyId, unitId, tenantId, landlordId]
  );
  const workOrderId = workOrderRes.rows[0]?.id;

  // Bids
  if (workOrderId) {
    await query(
      `INSERT INTO bids (work_order_id, vendor_id, amount, currency, message, estimated_hours, proposed_date, status, is_fixed_price)
       VALUES
       ($1, $2, 120.00, 'USD', 'Can fix it tomorrow morning.', 2, CURRENT_DATE + INTERVAL '1 day', 'pending', true)`,
      [workOrderId, vendorId]
    );
  }

  // Sample Course
  await query(
    `INSERT INTO courses (title, slug, category, difficulty, duration_minutes, instructor_name, description, is_published, passing_score)
     VALUES ('Fair Housing Compliance', 'fair-housing-compliance', 'compliance', 'beginner', 120, 'Compliance Team', 'Deep dive into fair housing regulations.', true, 70)
     ON CONFLICT DO NOTHING`
  );

  // Seed user profiles for seeded users
  const seededUserIds = [adminId, landlordId, tenantId, vendorId];
  for (const uid of seededUserIds) {
    await query(
      `INSERT INTO user_profiles (user_id, onboarding_step, onboarding_completed)
       VALUES ($1, 5, true)
       ON CONFLICT (user_id) DO NOTHING`,
      [uid]
    );
  }

  // Discussions
  const discRes = await query(
    `INSERT INTO discussions (user_id, category, title, content, tags, views_count, replies_count, is_pinned)
     VALUES
     ($1, 'general', 'Welcome to PropAdmin Community!', 'This is a place to discuss property management, lease regulations and other tenant issues.', '["welcome", "community"]', 15, 1, true)
     RETURNING id`,
    [adminId]
  );
  const discussionId = discRes.rows[0]?.id;

  if (discussionId) {
    await query(
      `INSERT INTO discussion_replies (discussion_id, user_id, content, upvotes)
       VALUES
       ($1, $2, 'Thanks for setting this up! Super helpful.', 5)`,
      [discussionId, landlordId]
    );
  }

  // Notifications
  await query(
    `INSERT INTO notifications (user_id, type, title, message, priority, is_read)
     VALUES
     ($1, 'system', 'Welcome!', 'Your PropAdmin account has been verified.', 'normal', false),
     ($2, 'payment', 'Rent Received', 'Your landlord Marcus Thorne received $2450.00.', 'normal', true)`,
    [tenantId, tenantId]
  );

  // Ads
  await query(
    `INSERT INTO ads (title, description, ad_type, banner_url, target_roles, latitude, longitude, location, radius_meters, redirect_url)
     VALUES
     ('Global Promo Banner', 'Get 20% off on all compliance courses this month!', 'general', 'https://example.com/banners/promo.png', '{}', NULL, NULL, NULL, NULL, 'https://example.com/promo'),
     ('NYC Plumbing Tender', 'Urgent maintenance bid required for plumbing works in central Manhattan.', 'tender', 'https://example.com/banners/plumbing.png', '{"vendor"}', 40.7128, -74.006, ST_SetSRID(ST_MakePoint(-74.006, 40.7128), 4326), 5000, 'https://example.com/tenders/1'),
     ('Landlord Insurance NYC', 'Protect your properties with our premium landlord coverage.', 'landlord', 'https://example.com/banners/insurance.png', '{"landlord"}', 40.7128, -74.006, ST_SetSRID(ST_MakePoint(-74.006, 40.7128), 4326), 10000, 'https://example.com/insurance'),
     ('London Rental Guide', 'New regulations guide for tenants in Greater London.', 'general', 'https://example.com/banners/london-guide.png', '{"tenant"}', 51.5074, -0.1278, ST_SetSRID(ST_MakePoint(-0.1278, 51.5074), 4326), 5000, 'https://example.com/london-guide')`
  );

  console.log('✅ Seed completed');
  await pool.end();
}

seed().catch(console.error);
