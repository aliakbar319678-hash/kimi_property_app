import { query } from '../db';
import { v4 as uuidv4 } from 'uuid';

async function run() {
  console.log('Seeding Platform Updates mock data...');

  // Get users by joining user_roles
  const tenantRes = await query(`SELECT user_id as id FROM user_roles WHERE role = 'tenant' LIMIT 1`);
  const landlordRes = await query(`SELECT user_id as id FROM user_roles WHERE role = 'landlord' LIMIT 1`);
  const vendorRes = await query(`SELECT user_id as id FROM user_roles WHERE role = 'vendor' LIMIT 1`);
  const propertyRes = await query(`SELECT id FROM properties LIMIT 1`);
  
  if (!tenantRes.rows.length || !landlordRes.rows.length || !vendorRes.rows.length || !propertyRes.rows.length) {
    console.error('Missing required users or properties. Make sure database is seeded.');
    process.exit(1);
  }

  const tenantId = tenantRes.rows[0].id;
  const landlordId = landlordRes.rows[0].id;
  const vendorId = vendorRes.rows[0].id;
  const propertyId = propertyRes.rows[0].id;

  const unitRes = await query(`SELECT id FROM units WHERE property_id = $1 LIMIT 1`, [propertyId]);
  let unitId = null;
  if (unitRes.rows.length > 0) {
      unitId = unitRes.rows[0].id;
  } else {
      const newUnitRes = await query(
          `INSERT INTO units (property_id, unit_number, rent_amount) VALUES ($1, $2, $3) RETURNING id`,
          [propertyId, '101A', 1500]
      );
      unitId = newUnitRes.rows[0].id;
  }

  console.log('Using IDs:', { tenantId, landlordId, vendorId, propertyId, unitId });

  // 1. Create Mock Applications
  await query(`DELETE FROM applications`);
  await query(
    `INSERT INTO applications (tenant_id, unit_id, property_id, landlord_id, current_step, screening_status, approval_status, conditional_terms, submitted_at, created_at)
     VALUES 
     ($1, $2, $3, $4, 5, 'passed', 'approved', '{"tags":[], "note":""}', NOW(), NOW() - interval '2 days'),
     ($1, $2, $3, $4, 5, 'pending', 'pending', '{"tags":[], "note":""}', NOW(), NOW() - interval '1 days'),
     ($1, $2, $3, $4, 5, 'passed', 'conditional_approval', '{"tags":["higher_security_deposit", "co_signer_required"], "note":"Need 2x deposit"}', NOW(), NOW())`,
    [tenantId, unitId, propertyId, landlordId]
  );
  console.log('Inserted Applications');

  // 2. Create Mock Jobs
  await query(`DELETE FROM jobs_posted CASCADE`);
  const job1Id = uuidv4();
  const job2Id = uuidv4();
  
  await query(
    `INSERT INTO jobs_posted (id, landlord_id, property_id, unit_id, title, category, urgency, budget_min, budget_max, status, created_at)
     VALUES 
     ($1, $2, $3, $4, 'Fix Leaking Sink', 'essential_maintenance', 'urgent', 100, 250, 'open', NOW() - interval '2 days'),
     ($5, $2, $3, $4, 'Deep Clean Apartment', 'turnover_cleaning', 'standard', 300, 500, 'open', NOW() - interval '1 days')`,
    [job1Id, landlordId, propertyId, unitId, job2Id]
  );
  console.log('Inserted Jobs Posted');

  // 3. Create Mock Bids
  await query(`DELETE FROM vendor_job_bids`);
  await query(
    `INSERT INTO vendor_job_bids (job_id, vendor_id, bid_amount, promotion_type, status, created_at)
     VALUES 
     ($1, $2, 150.00, 'discount', 'pending', NOW()),
     ($3, $2, 350.00, 'priority', 'pending', NOW())`,
    [job1Id, vendorId, job2Id]
  );
  console.log('Inserted Vendor Bids');

  console.log('Platform Updates Seeding Complete!');
  process.exit(0);
}

run().catch(console.error);
