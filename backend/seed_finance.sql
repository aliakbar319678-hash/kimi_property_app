-- Fetch a few arbitrary user UUIDs to act as tenants, landlords, and vendors
DO $$ 
DECLARE
    tenant_id UUID;
    landlord_id UUID;
    vendor_id UUID;
    prop_id UUID;
    lease_uuid UUID;
BEGIN
    -- Select the first available users
    SELECT id INTO tenant_id FROM users WHERE email LIKE '%tenant%' OR display_name ILIKE '%tenant%' LIMIT 1;
    IF tenant_id IS NULL THEN
        SELECT id INTO tenant_id FROM users LIMIT 1;
    END IF;

    SELECT id INTO landlord_id FROM users WHERE email LIKE '%landlord%' OR display_name ILIKE '%landlord%' LIMIT 1;
    IF landlord_id IS NULL THEN
        SELECT id INTO landlord_id FROM users LIMIT 1 OFFSET 1;
    END IF;

    SELECT id INTO vendor_id FROM users WHERE email LIKE '%vendor%' OR display_name ILIKE '%vendor%' LIMIT 1;
    IF vendor_id IS NULL THEN
        SELECT id INTO vendor_id FROM users LIMIT 1 OFFSET 2;
    END IF;

    -- Select property and lease
    SELECT id INTO prop_id FROM properties LIMIT 1;
    SELECT id INTO lease_uuid FROM leases LIMIT 1;

    -- Update Stripe status for landlord & vendor to make UI look realistic
    UPDATE users SET stripe_account_id = 'acct_' || substr(md5(random()::text), 1, 16), stripe_onboarding_status = 'completed' WHERE id IN (landlord_id, vendor_id);

    -- Insert Platform Config if it doesn't exist
    INSERT INTO platform_configs (commission_percent, admin_fee, late_fee_percent, currency, updated_by, updated_at)
    SELECT 5.00, 150.00, 10.00, 'USD', tenant_id, NOW()
    WHERE NOT EXISTS (SELECT 1 FROM platform_configs);

    -- Insert Dummy Escrows
    INSERT INTO escrow_ledgers (tenant_id, property_id, lease_id, amount, deposit_type, status, created_at)
    VALUES 
    (tenant_id, prop_id, lease_uuid, 1500.00, 'security', 'held', NOW() - INTERVAL '30 days'),
    (tenant_id, prop_id, lease_uuid, 300.00, 'pet', 'held', NOW() - INTERVAL '15 days'),
    (tenant_id, prop_id, lease_uuid, 50.00, 'key', 'released', NOW() - INTERVAL '60 days');

    -- Insert Dummy Payouts (Landlord)
    INSERT INTO payouts (payee_id, payee_role, amount, platform_fee_deducted, status, scheduled_date, created_at)
    VALUES 
    (landlord_id, 'landlord', 1425.00, 75.00, 'queued', CURRENT_DATE + INTERVAL '1 day', NOW()),
    (landlord_id, 'landlord', 1425.00, 75.00, 'processing', CURRENT_DATE, NOW()),
    (landlord_id, 'landlord', 1425.00, 75.00, 'paid', CURRENT_DATE - INTERVAL '30 days', NOW() - INTERVAL '31 days');

    -- Insert Dummy Payouts (Vendor)
    INSERT INTO payouts (payee_id, payee_role, amount, platform_fee_deducted, status, scheduled_date, created_at)
    VALUES 
    (vendor_id, 'vendor', 450.00, 50.00, 'queued', CURRENT_DATE + INTERVAL '5 days', NOW()),
    (vendor_id, 'vendor', 200.00, 20.00, 'failed', CURRENT_DATE - INTERVAL '2 days', NOW() - INTERVAL '5 days');

END $$;
