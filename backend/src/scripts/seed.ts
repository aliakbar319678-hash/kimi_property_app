import { pool, query } from '../db';
import bcrypt from 'bcryptjs';
import { config } from '../config';
import { v4 as uuidv4 } from 'uuid';

async function seed() {
  console.log('🌱 Seeding database with rich operational and LMS data...');

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
    `INSERT INTO users (id, email, password_hash, display_name, kyc_status, region_id)
     VALUES (uuid_generate_v4(), 'admin@propadmin.io', $1, 'James Wilson', 'approved', (SELECT id FROM regions WHERE code = 'US-NYC'))
     ON CONFLICT (email) DO UPDATE SET password_hash = $1 RETURNING id`,
    [hash]
  );
  const adminId = adminRes.rows[0].id;

  await query(
    `INSERT INTO user_roles (user_id, role, is_primary) VALUES ($1, 'super_admin', true)
     ON CONFLICT DO NOTHING`,
    [adminId]
  );

  // LMS: Seeding Mock Students (Users)
  const studentsList = [
    { name: 'James Holloway', email: 'james.h@tenant.io', role: 'tenant' },
    { name: 'Priya Mehta', email: 'priya.m@landlord.com', role: 'landlord' },
    { name: 'Carlos Rivera', email: 'c.rivera@estate.net', role: 'landlord' },
    { name: 'Aisha Johnson', email: 'aisha@propmanage.io', role: 'tenant' },
    { name: 'Thomas Wright', email: 'tw@vendorpro.com', role: 'vendor' },
    { name: 'Samantha Lee', email: 'sam.lee@rents.co', role: 'tenant' }
  ];

  const studentIds: string[] = [];

  for (const s of studentsList) {
    const sRes = await query(
      `INSERT INTO users (id, email, password_hash, display_name, kyc_status, region_id)
       VALUES (uuid_generate_v4(), $1, $2, $3, 'approved', (SELECT id FROM regions WHERE code = 'US-NYC'))
       ON CONFLICT (email) DO UPDATE SET display_name = $3 RETURNING id`,
      [s.email, hash, s.name]
    );
    const sid = sRes.rows[0].id;
    studentIds.push(sid);

    await query(
      `INSERT INTO user_roles (user_id, role, is_primary) VALUES ($1, $2, true)
       ON CONFLICT DO NOTHING`,
      [sid, s.role]
    );
  }

  // LMS: Seeding Courses
  const coursesList = [
    { title: 'Fair Housing Compliance', slug: 'fair-housing-compliance', category: 'compliance', difficulty: 'beginner', duration: 120, instructor: 'Compliance Team', desc: 'Comprehensive compliance training covering Federal Fair Housing Act guidelines.' },
    { title: 'Property Maintenance Essentials', slug: 'property-maintenance-essentials', category: 'maintenance', difficulty: 'intermediate', duration: 180, instructor: 'Facilities Department', desc: 'Standard operating procedures for electrical, HVAC, and building upkeep.' },
    { title: 'Tenant Relations Mastery', slug: 'tenant-relations-mastery', category: 'strategy', difficulty: 'advanced', duration: 90, instructor: 'Management Division', desc: 'Resolving disputes, handling renewals, and maintaining high tenant retention.' },
    { title: 'Financial Reporting for PMs', slug: 'financial-reporting-for-pms', category: 'finance', difficulty: 'intermediate', duration: 150, instructor: 'Finance Operations', desc: 'Preparing profit/loss statements, handling escrows, and tracking security deposits.' },
    { title: 'Legal & Lease Management', slug: 'legal-lease-management', category: 'legal', difficulty: 'advanced', duration: 210, instructor: 'Legal Counsel', desc: 'Drafting enforceable leases, managing eviction procedures, and complying with state-specific rental statutes.' }
  ];

  const courseIds: string[] = [];
  for (const c of coursesList) {
    const cRes = await query(
      `INSERT INTO courses (title, slug, category, difficulty, duration_minutes, instructor_name, description, is_published, passing_score)
       VALUES ($1, $2, $3, $4, $5, $6, $7, true, 70)
       ON CONFLICT (slug) DO UPDATE SET description = $7 RETURNING id`,
      [c.title, c.slug, c.category, c.difficulty, c.duration, c.instructor, c.desc]
    );
    courseIds.push(cRes.rows[0].id);
  }

  // LMS: Seeding Modules for courses
  for (const cid of courseIds) {
    await query(`DELETE FROM modules WHERE course_id = $1`, [cid]);
    await query(
      `INSERT INTO modules (course_id, title, description, content_type, content_url, sort_order) VALUES
       ($1, 'Introduction & Core Concepts', 'Foundational overview and legal frameworks.', 'video', 'http://localhost/video1.mp4', 1),
       ($1, 'Practical Scenarios & Case Studies', 'Step-by-step review of real-world operational challenges.', 'video', 'http://localhost/video2.mp4', 2)`,
      [cid]
    );

    // Seeding Quiz for each course
    await query(`DELETE FROM quizzes WHERE course_id = $1`, [cid]);
    const quizQuestions = [
      {
        id: uuidv4().substring(0, 8),
        text: 'Select the correct statement regarding Federal Fair Housing guidelines:',
        options: [
          { id: 0, text: 'Local rules can override federal regulations', is_correct: false },
          { id: 1, text: 'Federal fair housing applies to all residential property transactions', is_correct: true }
        ]
      },
      {
        id: uuidv4().substring(0, 8),
        text: 'Identify all standard practices for maintaining lease document validity (Select 2 answers):',
        options: [
          { id: 0, text: 'Tenant signature is required', is_correct: true },
          { id: 1, text: 'Verbal agreements are always binding in all states', is_correct: false },
          { id: 2, text: 'Landlord countersign signature is required', is_correct: true }
        ]
      }
    ];

    await query(
      `INSERT INTO quizzes (course_id, title, questions) VALUES ($1, 'Final Course Exam', $2)`,
      [cid, JSON.stringify(quizQuestions)]
    );
  }

  // LMS: Seeding Enrollments (Students' progress)
  await query(`DELETE FROM certificates`);
  await query(`DELETE FROM enrollments`);
  const enrollmentsData = [
    { studentIdx: 0, courseIdx: 0, progress: 92, status: 'completed' }, // James Holloway in Fair Housing
    { studentIdx: 1, courseIdx: 1, progress: 67, status: 'in_progress' }, // Priya Mehta in Maintenance
    { studentIdx: 2, courseIdx: 4, progress: 100, status: 'completed' }, // Carlos Rivera in Legal & Lease
    { studentIdx: 3, courseIdx: 2, progress: 38, status: 'in_progress' }, // Aisha Johnson in Tenant Relations
    { studentIdx: 4, courseIdx: 1, progress: 0, status: 'in_progress' }, // Thomas Wright
    { studentIdx: 5, courseIdx: 0, progress: 55, status: 'in_progress' }  // Samantha Lee
  ];

  for (const e of enrollmentsData) {
    const sid = studentIds[e.studentIdx];
    const cid = courseIds[e.courseIdx];
    if (sid && cid) {
      await query(
        `INSERT INTO enrollments (user_id, course_id, progress_percent, status, started_at, completed_at)
         VALUES ($1, $2, $3, $4, NOW() - INTERVAL '15 days', $5)`,
        [sid, cid, e.progress, e.status, e.status === 'completed' ? 'NOW()' : null]
      );

      // Seed certificates for completed ones
      if (e.status === 'completed') {
        const certNum = 'CERT-' + uuidv4().substring(0, 8).toUpperCase();
        await query(
          `INSERT INTO certificates (user_id, course_id, certificate_number, issued_date, expiry_date, status)
           VALUES ($1, $2, $3, CURRENT_DATE, CURRENT_DATE + INTERVAL '2 years', 'active')`,
          [sid, cid, certNum]
        );
      }
    }
  }

  // Seeding Support Tickets
  await query(`DELETE FROM support_tickets`);
  const ticketRes = await query(
    `INSERT INTO support_tickets (title, priority, status, description, reporter, reporter_role, reporter_detail, assigned_to, attachment, attachment_size, resolution_notes) VALUES
     ('Stripe Rent Payment Error', 'high', 'open', 'Tenant reports recurring failure during rent processing on the Stripe gateway endpoint. White screen shows error 500 when confirm button is pressed.', 'Sarah Mitchell', 'Tenant', 'Primary Tenant • Unit 5B: Azure Residences', 'Unassigned', 'error_log_payment.png', '351 KB', NULL),
     ('Property Verification Delay', 'medium', 'open', 'Awaiting document validation for "The Heights Executive". Submitted 48h ago. Tax certificates and insurance documents have been fully submitted for compliance checks.', 'Marcus Sterling', 'Landlord', 'Landlord • The Heights Executive', 'Unassigned', 'ownership_deed.pdf', '2.4 MB', NULL),
     ('Lease Auto-Renewal Failure', 'low', 'resolved', 'System did not send automated notification of lease auto-renewal option to Tenant. Evaluated manually and confirmed settings.', 'Liam Johnson', 'Tenant', 'Tenant • Unit 12: Sunset Apartments', 'Emily Davis (Finance Operations)', NULL, NULL, 'Manually checked the lease settings and triggered the renewal notification job. Confirmed tenant received it.')
     RETURNING id`
  );
  
  const ticket1 = ticketRes.rows[0].id;
  const ticket2 = ticketRes.rows[1].id;
  const ticket3 = ticketRes.rows[2].id;

  await query(`DELETE FROM support_ticket_updates`);
  await query(
    `INSERT INTO support_ticket_updates (ticket_id, user_name, action, note, created_at) VALUES
     ($1, 'System', 'created', 'Ticket automatically routed to Finance queue', NOW() - INTERVAL '2 hours'),
     ($2, 'System', 'created', 'Ticket queued for compliance review', NOW() - INTERVAL '48 hours'),
     ($3, 'System', 'created', 'Ticket received', NOW() - INTERVAL '3 days'),
     ($3, 'System', 'assigned', 'Assigned to Emily Davis (Finance Operations)', NOW() - INTERVAL '2 days'),
     ($3, 'Emily Davis (Finance Operations)', 'status_change', 'Status changed to In Progress', NOW() - INTERVAL '1 day'),
     ($3, 'Emily Davis (Finance Operations)', 'note', 'Investigating lease notification configurations. Seems cron job failed to fire.', NOW() - INTERVAL '1 day'),
     ($3, 'Emily Davis (Finance Operations)', 'resolved', 'Manually checked the lease settings and triggered the renewal notification job. Confirmed tenant received it.', NOW())`,
    [ticket1, ticket2, ticket3]
  );

  // Seeding LMS Resources
  await query(`DELETE FROM lms_resources`);
  await query(
    `INSERT INTO lms_resources (title, type, description, file_url, file_size) VALUES
     ('Federal Fair Housing Compliance Guidelines', 'legal_doc', 'Official regulatory guide outlining federal fair housing standards and landlord liabilities.', '/uploads/docs/fair_housing_guide.pdf', '1.8 MB'),
     ('Quarterly Building Maintenance Inspection Checklist', 'checklist', 'Printable sheet for building structural, electrical, and HVAC maintenance audits.', '/uploads/docs/maintenance_checklist.pdf', '420 KB'),
     ('Standard Residential Lease Template', 'template', 'Fully customizable state-compliant rental lease document template in editable PDF format.', '/uploads/docs/residential_lease_template.pdf', '850 KB'),
     ('De-escalation Techniques for Landlords', 'guide', 'Strategic tips and methods for managing landlord-tenant conflict resolution.', '/uploads/docs/de_escalation_guide.pdf', '1.1 MB'),
     ('Eviction Filing Procedure Video Tutorial', 'video', '15-minute video detailing state court filings, notice deliveries, and legal protocols.', '/uploads/video/eviction_filing_guide.mp4', '42 MB'),
     ('Operational Procedures Briefing Audio', 'audio', 'Audio briefing on company policy changes and remote property audit structures.', '/uploads/audio/operational_briefing.mp3', '12 MB')`
  );

  // Seeding System/LMS Notifications for Admin System
  await query(`DELETE FROM notifications WHERE user_id = $1`, [adminId]);
  await query(
    `INSERT INTO notifications (user_id, type, title, message, action_url, action_type, priority, channels, is_read) VALUES
     ($1, 'course', 'James Holloway completed Fair Housing Compliance', 'Student James Holloway has completed the Fair Housing Compliance course and has been issued certificate CERT-A1B2.', '/admin/lms/certificates', 'navigate', 'normal', '["in_app"]', false),
     ($1, 'system', 'New Property Submitted', 'Luxury Apartment #402 in "The Azure Heights" has been submitted for verification by Agent Sarah Mitchell. Document compliance check pending.', '/admin/property', 'navigate', 'high', '["in_app"]', false),
     ($1, 'payment', 'Chargeback Alert', 'A chargeback of $4,250.00 has been initiated for Merchant ID #8892 (Skyline Lofts). Action required within 24 hours.', '/admin/payment', 'navigate', 'high', '["in_app"]', false),
     ($1, 'system', 'Vendor Insurance Expired', 'Liability insurance for "City-Wide Maintenance Group" has expired. All pending work orders have been paused automatically.', '/admin/support', 'navigate', 'normal', '["in_app"]', false)`
  , [adminId]);

  // Seeding Discussions
  await query(`DELETE FROM discussions`);
  const discRes = await query(
    `INSERT INTO discussions (user_id, category, title, content, tags, views_count, replies_count, is_pinned) VALUES
     ($1, 'Compliance', 'Fair Housing Act updates for 2026', 'Are there any specific new provisions added to the familial status protection class under the revised state rental code? Let''s discuss compliance tactics.', '["fair-housing", "compliance", "legal"]', 142, 2, true)
     RETURNING id`,
    [adminId]
  );
  const discId = discRes.rows[0].id;

  await query(`DELETE FROM discussion_replies`);
  await query(
    `INSERT INTO discussion_replies (discussion_id, user_id, content, upvotes) VALUES
     ($1, $2, 'Yes, the new state rental code explicitly specifies guidelines regarding occupancy limits for single-parent families. Make sure your local agents are briefed.', 12),
     ($1, $3, 'Thanks for the heads-up. I will update our property manager handbooks accordingly.', 4)`,
    [discId, studentIds[1], studentIds[2]]
  );


  // ────────────────────────────────────────────────────────────────────────────
  // PROPERTIES, UNITS, LEASES, WORK ORDERS, JOBS, TRANSACTIONS
  // ────────────────────────────────────────────────────────────────────────────

  // Users by role
  // studentsList: [0]=James Holloway (tenant), [1]=Priya Mehta (landlord),
  //               [2]=Carlos Rivera (landlord), [3]=Aisha Johnson (tenant),
  //               [4]=Thomas Wright (vendor), [5]=Samantha Lee (tenant)
  const tenantId1  = studentIds[0]; // James Holloway
  const tenantId2  = studentIds[3]; // Aisha Johnson
  const tenantId3  = studentIds[5]; // Samantha Lee
  const landlordId = studentIds[1]; // Priya Mehta
  const vendorId   = studentIds[4]; // Thomas Wright

  // Clear dependent tables in correct FK order
  await query(`DELETE FROM payouts`);
  await query(`DELETE FROM transactions`);
  await query(`DELETE FROM rent_payments`);
  await query(`DELETE FROM job_assignments`);
  await query(`DELETE FROM bids`);
  await query(`DELETE FROM work_orders`);
  await query(`DELETE FROM leases`);
  await query(`DELETE FROM units`);
  await query(`DELETE FROM properties WHERE landlord_id = $1`, [landlordId]);

  const propRes = await query(
    `INSERT INTO properties (landlord_id, region_id, name, address_line1, city, state_province, postal_code, country_code, type, status, verification_status)
     VALUES ($1, (SELECT id FROM regions WHERE code='US-NYC'), 'Azure Residences', '142 W 57th Street', 'New York', 'NY', '10019', 'US', 'apartment', 'active', 'approved')
     RETURNING id`,
    [landlordId]
  );
  const propId = propRes.rows[0].id;

  // Units
  const unitRes1 = await query(
    `INSERT INTO units (property_id, unit_number, bedrooms, bathrooms, square_feet, rent_amount, status)
     VALUES ($1, '5B', 2, 1, 900, 1500.00, 'occupied') RETURNING id`,
    [propId]
  );
  const unitId1 = unitRes1.rows[0].id;

  const unitRes2 = await query(
    `INSERT INTO units (property_id, unit_number, bedrooms, bathrooms, square_feet, rent_amount, status)
     VALUES ($1, '8A', 1, 1, 650, 950.00, 'occupied') RETURNING id`,
    [propId]
  );
  const unitId2 = unitRes2.rows[0].id;

  // Leases
  const leaseRes1 = await query(
    `INSERT INTO leases (tenant_id, unit_id, property_id, landlord_id, start_date, end_date, rent_amount, deposit_amount, payment_schedule, payment_due_day, status, auto_renew)
     VALUES ($1, $2, $3, $4, '2025-01-01', '2026-12-31', 1500.00, 3000.00, 'monthly', 1, 'active', true)
     RETURNING id`,
    [tenantId1, unitId1, propId, landlordId]
  );
  const leaseId1 = leaseRes1.rows[0].id;

  const leaseRes2 = await query(
    `INSERT INTO leases (tenant_id, unit_id, property_id, landlord_id, start_date, end_date, rent_amount, deposit_amount, payment_schedule, payment_due_day, status, auto_renew)
     VALUES ($1, $2, $3, $4, '2025-06-01', '2026-05-31', 950.00, 1900.00, 'monthly', 5, 'active', false)
     RETURNING id`,
    [tenantId2, unitId2, propId, landlordId]
  );
  const leaseId2 = leaseRes2.rows[0].id;

  // Work Orders (Maintenance Tasks assigned to Vendor)
  const woRes1 = await query(
    `INSERT INTO work_orders (property_id, unit_id, tenant_id, landlord_id, title, description, category, priority, status, budget_min, budget_max, currency, assigned_vendor_id, scheduled_date)
     VALUES ($1, $2, $3, $4, 'HVAC Unit Replacement', 'Central AC unit for Unit 5B has stopped cooling. Requires full inspection and replacement of compressor or unit.', 'hvac', 'high', 'in_progress', 800.00, 1400.00, 'USD', $5, CURRENT_DATE + INTERVAL '2 days')
     RETURNING id`,
    [propId, unitId1, tenantId1, landlordId, vendorId]
  );
  const woId1 = woRes1.rows[0].id;

  const woRes2 = await query(
    `INSERT INTO work_orders (property_id, unit_id, tenant_id, landlord_id, title, description, category, priority, status, budget_min, budget_max, currency, assigned_vendor_id, scheduled_date, completed_date)
     VALUES ($1, $2, $3, $4, 'Plumbing Leak Repair', 'Water leak detected under kitchen sink in Unit 8A. Pipe joint replacement needed.', 'plumbing', 'medium', 'completed', 200.00, 400.00, 'USD', $5, CURRENT_DATE - INTERVAL '5 days', CURRENT_DATE - INTERVAL '2 days')
     RETURNING id`,
    [propId, unitId2, tenantId2, landlordId, vendorId]
  );
  const woId2 = woRes2.rows[0].id;

  // Job Assignments
  const jaRes1 = await query(
    `INSERT INTO job_assignments (work_order_id, vendor_id, final_amount, scheduled_date, status)
     VALUES ($1, $2, 1200.00, CURRENT_DATE + INTERVAL '2 days', 'assigned')
     RETURNING id`,
    [woId1, vendorId]
  );

  const jaRes2 = await query(
      `INSERT INTO job_assignments (work_order_id, vendor_id, final_amount, scheduled_date, status)
     VALUES ($1, $2, 320.00, CURRENT_DATE - INTERVAL '5 days', 'completed')
     RETURNING id`,
    [woId2, vendorId]
  );
  const jaId2 = jaRes2.rows[0].id;

  // Transactions – mix of tenant rent, landlord payout, vendor payment, refund, failed
  const txnId1 = uuidv4();
  const txnId2 = uuidv4();
  const txnId3 = uuidv4();
  const txnId4 = uuidv4();
  const txnId5 = uuidv4();
  const txnId6 = uuidv4();
  const txnId7 = uuidv4();
// Fixed transaction inserts – individual rows
await query(`INSERT INTO transactions (id, payer_id, payee_id, property_id, unit_id, lease_id, type, amount, currency, status, gateway, gateway_transaction_id, metadata)
  VALUES ($1, $2, $3, $4, $5, $6, 'rent', 1500.00, 'USD', 'completed', 'stripe', 'ch_james_rent_001',
    '{"description":"Monthly rent payment for Unit 5B, June 2026","unit_number":"5B","month":"June 2026"}')`,
  [txnId1, tenantId1, landlordId, propId, unitId1, leaseId1]);
await query(`INSERT INTO transactions (id, payer_id, payee_id, property_id, unit_id, lease_id, type, amount, currency, status, gateway, gateway_transaction_id, metadata)
  VALUES ($1, $2, $3, $4, $5, $6, 'rent', 950.00, 'USD', 'completed', 'stripe', 'ch_aisha_rent_001',
    '{"description":"Monthly rent payment for Unit 8A, June 2026","unit_number":"8A","month":"June 2026"}')`,
  [txnId2, tenantId2, landlordId, propId, unitId2, leaseId2]);
await query(`INSERT INTO transactions (id, payer_id, payee_id, property_id, unit_id, lease_id, type, amount, currency, status, gateway, gateway_transaction_id, metadata)
  VALUES ($1, $2, $3, $4, $5, $6, 'vendor_payout', 320.00, 'USD', 'completed', 'paypal', 'pp_thomas_job_001',
    '{"description":"Vendor payout: Plumbing Leak Repair, Unit 8A","work_order_title":"Plumbing Leak Repair"}')`,
  [txnId3, landlordId, vendorId, propId, unitId2, null]);
await query(`INSERT INTO transactions (id, payer_id, payee_id, property_id, unit_id, lease_id, type, amount, currency, status, gateway, gateway_transaction_id, metadata)
  VALUES ($1, $2, $3, $4, $5, $6, 'vendor_payout', 1820.00, 'USD', 'completed', 'bank_transfer', 'bt_priya_payout_001',
    '{"description":"Monthly net rental income payout for Azure Residences","units_count":2}')`,
  [txnId4, landlordId, landlordId, propId, null, null]);
await query(`INSERT INTO transactions (id, payer_id, payee_id, property_id, unit_id, lease_id, type, amount, currency, status, gateway, gateway_transaction_id, metadata)
  VALUES ($1, $2, $3, $4, $5, $6, 'rent', 1100.00, 'USD', 'failed', 'stripe', 'ch_sam_fail_001',
    '{"description":"Monthly rent payment failed - insufficient funds","failure_reason":"card_declined"}')`,
  [txnId5, tenantId3, landlordId, propId, null, null]);
await query(`INSERT INTO transactions (id, payer_id, payee_id, property_id, unit_id, lease_id, type, amount, currency, status, gateway, gateway_transaction_id, metadata)
  VALUES ($1, $2, $3, $4, $5, $6, 'refund', 750.00, 'USD', 'completed', 'stripe', 'ch_james_refund_001',
    '{"description":"Partial refund: security deposit partial return","reason":"Property condition satisfactory"}')`,
  [txnId6, tenantId1, landlordId, propId, unitId1, leaseId1]);
await query(`INSERT INTO transactions (id, payer_id, payee_id, property_id, unit_id, lease_id, type, amount, currency, status, gateway, gateway_transaction_id, metadata)
  VALUES ($1, $2, $3, $4, $5, $6, 'vendor_payout', 1200.00, 'USD', 'pending', 'paypal', 'pp_thomas_hvac_001',
    '{"description":"Vendor payout pending: HVAC Unit Replacement (in progress)","work_order_title":"HVAC Unit Replacement"}')`,
  [txnId7, landlordId, vendorId, propId, unitId1, null]);

    // Insert sample payouts with varied statuses
    const payoutId1 = uuidv4();
    const payoutId2 = uuidv4();
    const payoutId3 = uuidv4();
    const payoutId4 = uuidv4();
    const payoutId5 = uuidv4();
    const payoutId6 = uuidv4();
    const payoutId7 = uuidv4();
    const payoutId8 = uuidv4();
    const payoutId9 = uuidv4();
    const payoutId10 = uuidv4();
    await query(`
      INSERT INTO payouts (id, payee_id, payee_role, amount, platform_fee_deducted, status, scheduled_date, transaction_id)
      VALUES
         ($1,  $2, 'landlord', 1500.00, 75.00, 'queued', CURRENT_DATE + INTERVAL '2 days', $3),
         ($4,  $5, 'vendor',    320.00, 16.00, 'queued', CURRENT_DATE + INTERVAL '1 day',  $6),
         ($7,  $2, 'landlord', 2000.00, 100.00, 'queued', CURRENT_DATE + INTERVAL '3 days', $8),
         ($9,  $5, 'vendor',    500.00, 25.00, 'failed', CURRENT_DATE + INTERVAL '1 day',  $6),
         ($10, $2, 'landlord', 4200.00, 210.00, 'queued', CURRENT_DATE + INTERVAL '4 days', $11),
         ($12, $5, 'vendor',   1200.00, 60.00, 'queued', CURRENT_DATE + INTERVAL '2 days', $13),
         ($14, $2, 'landlord',  850.00, 42.50, 'queued', CURRENT_DATE + INTERVAL '5 days', $8),
         ($15, $5, 'vendor',    890.00, 44.50, 'queued', CURRENT_DATE + INTERVAL '1 day',  $13),
         ($16, $2, 'landlord', 3100.00, 155.00, 'queued', CURRENT_DATE + INTERVAL '2 days', $3),
         ($17, $5, 'vendor',     75.00, 3.75, 'queued', CURRENT_DATE + INTERVAL '3 days', $6)
    `,
    [
        payoutId1, landlordId, txnId1,
        payoutId2, vendorId,   txnId3,
        payoutId3,             txnId2,
        payoutId4, 
        payoutId5,             txnId4,
        payoutId6,             txnId7,
        payoutId7, 
        payoutId8, 
        payoutId9, 
        payoutId10
    ]);
    console.log('✅ Rich Database Seeding completed successfully!');
  await pool.end();
}

seed().catch(console.error);
