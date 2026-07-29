import { pool } from './db';
import { v4 as uuidv4 } from 'uuid';

async function seed() {
  console.log("Starting full DB seeding...");
  
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    
    // Clear relevant tables to ensure exactly 1 Landlord, Tenant, Vendor
    const tables = [
      'audit_logs', 'notifications', 'support_tickets', 
      'rent_payments', 'work_orders', 'leases', 'units', 'properties', 
      'user_roles', 'user_profiles', 'users', 'regions',
      'transactions', 'verification_cases'
    ];
    for (const table of tables) {
      await client.query(`TRUNCATE TABLE ${table} CASCADE`);
      console.log(`Truncated ${table}`);
    }

    // UUIDs
    const regionId = uuidv4();
    const landlordId = uuidv4();
    const tenantId = uuidv4();
    const vendorId = uuidv4();
    const propertyId = uuidv4();
    const unitId = uuidv4();
    const leaseId = uuidv4();

    // Insert Region
    await client.query(`
      INSERT INTO regions (id, code, name, currency) 
      VALUES ($1, $2, $3, $4)
    `, [regionId, 'US-CA', 'California', 'USD']);

    // Insert Users
    const insertUser = async (id: string, email: string, firstName: string, lastName: string, role: string) => {
      await client.query(`
        INSERT INTO users (id, email, legal_first_name, legal_last_name, display_name, password_hash, is_active, email_verified, fraud_score, region_id)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
      `, [id, email, firstName, lastName, `${firstName} ${lastName}`, 'seeded_hash', true, true, 0, regionId]);
      
      await client.query(`
        INSERT INTO user_roles (id, user_id, role, is_primary)
        VALUES ($1, $2, $3, $4)
      `, [uuidv4(), id, role, true]);

      await client.query(`
        INSERT INTO user_profiles (user_id, onboarding_completed, onboarding_step)
        VALUES ($1, $2, $3)
      `, [id, true, 5]);
    };

    await insertUser(landlordId, 'landlord@example.com', 'John', 'Landlord', 'landlord');
    await insertUser(tenantId, 'tenant@example.com', 'Jane', 'Tenant', 'tenant');
    await insertUser(vendorId, 'vendor@example.com', 'Bob', 'Vendor', 'vendor');

    // Insert Property
    const docData = JSON.stringify([
        { id: uuidv4(), name: 'Ownership Deed', type: 'deed', size: '3.5 MB', url: '/docs/deed.pdf', status: 'verified' },
        { id: uuidv4(), name: 'Tax Certificate', type: 'tax', size: '2.2 MB', url: '/docs/tax.pdf', status: 'current' },
        { id: uuidv4(), name: 'Management Agreement', type: 'contract', size: '5.9 MB', url: '/docs/agreement.pdf', status: 'signed' }
    ]);
    const amenitiesData = JSON.stringify(["pool", "gym", "parking", "laundry", "security", "elevator"]);

    await client.query(`
      INSERT INTO properties (id, landlord_id, region_id, name, type, status, address_line1, city, state_province, postal_code, country_code, verification_status, documents, amenities)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
    `, [
        propertyId, landlordId, regionId, 'Sunset Apartments', 'apartment', 'active', '123 Sunset Blvd', 'Los Angeles', 'CA', '90001', 'US', 'approved', docData, amenitiesData
    ]);

    // Insert Unit
    await client.query(`
      INSERT INTO units (id, property_id, unit_number, bedrooms, bathrooms, rent_amount, status)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
    `, [unitId, propertyId, '101', 2, 1, 1500.00, 'occupied']);

    // Insert Lease
    await client.query(`
      INSERT INTO leases (id, tenant_id, unit_id, property_id, landlord_id, start_date, end_date, rent_amount, deposit_amount, status)
      VALUES ($1, $2, $3, $4, $5, CURRENT_DATE - INTERVAL '1 month', CURRENT_DATE + INTERVAL '11 months', 1500.00, 1500.00, 'active')
    `, [leaseId, tenantId, unitId, propertyId, landlordId]);

    // Insert Rent Payment
    await client.query(`
      INSERT INTO rent_payments (id, lease_id, tenant_id, property_id, unit_id, amount_due, amount_paid, due_date, status)
      VALUES ($1, $2, $3, $4, $5, 1500.00, 1500.00, CURRENT_DATE, 'paid')
    `, [uuidv4(), leaseId, tenantId, propertyId, unitId]);

    // Insert Work Order
    const workOrderId = uuidv4();
    const workOrderId2 = uuidv4(); // completed one
    
    await client.query(`
      INSERT INTO work_orders (id, property_id, unit_id, tenant_id, landlord_id, assigned_vendor_id, title, description, category, priority, status, currency)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12),
             ($13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24)
    `, [
        workOrderId, propertyId, unitId, tenantId, landlordId, vendorId, 'Leaking Faucet', 'The kitchen sink is leaking.', 'plumbing', 'high', 'in_progress', 'USD',
        workOrderId2, propertyId, unitId, tenantId, landlordId, vendorId, 'Broken Window', 'Living room window glass is broken.', 'general_repair', 'medium', 'completed', 'USD'
    ]);

    // Insert Bid
    const bidId = uuidv4();
    await client.query(`
      INSERT INTO bids (id, work_order_id, vendor_id, amount, currency, status, is_fixed_price)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
    `, [bidId, workOrderId2, vendorId, 250.00, 'USD', 'accepted', true]);

    // Insert Job Assignment
    await client.query(`
      INSERT INTO job_assignments (id, work_order_id, bid_id, vendor_id, final_amount, status)
      VALUES ($1, $2, $3, $4, $5, $6)
    `, [uuidv4(), workOrderId2, bidId, vendorId, 250.00, 'completed']);

    // Insert Invoice
    const invoiceId = uuidv4();
    await client.query(`
      INSERT INTO invoices (id, vendor_id, work_order_id, invoice_number, amount, status, due_date)
      VALUES ($1, $2, $3, $4, $5, $6, CURRENT_DATE)
    `, [invoiceId, vendorId, workOrderId2, 'INV-1001', 250.00, 'paid']);

    // Insert Support Ticket
    // Note: ID for support_tickets is integer (possibly SERIAL), we can omit it if it auto-increments
    try {
      await client.query(`
        INSERT INTO support_tickets (status, description, reporter, reporter_role, title, priority)
        VALUES ($1, $2, $3, $4, $5, $6), ($7, $8, $9, $10, $11, $12)
      `, ['open', 'Need help with rent portal', 'Jane Tenant', 'tenant', 'Portal Issue', 'medium',
          'open', 'Water pressure is low in the kitchen.', 'Jane Tenant', 'tenant', 'Plumbing Issue', 'high']);
    } catch (e: any) {
        if(e.message.includes('null value in column "id"')) {
            await client.query(`
                INSERT INTO support_tickets (id, status, description, reporter, reporter_role, title, priority)
                VALUES ($1, $2, $3, $4, $5, $6, $7), ($8, $9, $10, $11, $12, $13, $14)
            `, [1, 'open', 'Need help with rent portal', 'Jane Tenant', 'tenant', 'Portal Issue', 'medium',
                2, 'open', 'Water pressure is low in the kitchen.', 'Jane Tenant', 'tenant', 'Plumbing Issue', 'high']);
        }
    }

    // Insert Notification
    await client.query(`
      INSERT INTO notifications (id, user_id, title, message, type, is_read)
      VALUES ($1, $2, $3, $4, $5, $6)
    `, [uuidv4(), landlordId, 'New Work Order', 'A new work order was created for Sunset Apartments.', 'system', false]);

    // Insert Audit Logs
    await client.query(`
      INSERT INTO audit_logs (id, user_id, action, entity_type, entity_id, user_role, ip_address, details)
      VALUES 
        ($1, $2, 'login', 'user', $2, 'landlord', '192.168.1.100', '{"browser": "Chrome", "os": "Windows"}'),
        ($3, $4, 'update_user', 'user', $4, 'admin', '10.0.0.15', '{"fields_changed": ["email", "status"]}'),
        ($5, $6, 'process_payment', 'transaction', $7, 'system', '127.0.0.1', '{"amount": 1500, "status": "completed"}'),
        ($8, $9, 'security_alert', 'system', null, 'system', '45.33.22.11', '{"threat_level": "high", "type": "failed_login_attempts"}')
    `, [
        uuidv4(), landlordId,
        uuidv4(), landlordId,
        uuidv4(), tenantId, uuidv4(),
        uuidv4(), landlordId
    ]);

    // Insert Transactions (For Revenue & Monitoring)
    await client.query(`
      INSERT INTO transactions (id, payer_id, payee_id, property_id, unit_id, lease_id, type, amount, currency, status)
      VALUES ($1, $2, $3, $4, $5, $6, 'rent', 1500.00, 'USD', 'completed'),
             ($7, $8, $9, $10, $11, $12, 'rent', 500.00, 'USD', 'pending'),
             ($13, $14, $15, $16, $17, $18, 'rent', 50.00, 'USD', 'failed'),
             ($19, $20, $21, $22, $23, $24, 'vendor_payout', 250.00, 'USD', 'completed')
    `, [
        uuidv4(), tenantId, landlordId, propertyId, unitId, leaseId, // 1-6
        uuidv4(), tenantId, landlordId, propertyId, unitId, leaseId, // 7-12
        uuidv4(), tenantId, landlordId, propertyId, unitId, leaseId,  // 13-18
        uuidv4(), landlordId, vendorId, propertyId, unitId, null // 19-24 (landlord to vendor)
    ]);

    // Insert Verification Case
    await client.query(`
      INSERT INTO verification_cases (id, user_id, case_type, status)
      VALUES ($1, $2, 'identity', 'pending_review')
    `, [uuidv4(), tenantId]);

    await client.query('COMMIT');
    console.log("Database seeded successfully!");
  } catch (error) {
    await client.query('ROLLBACK');
    console.error("Error during seeding:", error);
  } finally {
    client.release();
    process.exit(0);
  }
}

seed();
