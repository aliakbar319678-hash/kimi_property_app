-- ==========================================
-- Phase 1: Core Financial Engine Updates
-- ==========================================

-- 1. Platform Configuration (Global Fees)
CREATE TABLE IF NOT EXISTS platform_configs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    commission_percent DECIMAL(5,2) DEFAULT 5.00,
    admin_fee DECIMAL(10,2) DEFAULT 0.00,
    late_fee_percent DECIMAL(5,2) DEFAULT 10.00,
    currency VARCHAR(3) DEFAULT 'USD',
    updated_by UUID REFERENCES users(id),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert a default row if not exists
INSERT INTO platform_configs (commission_percent, admin_fee, late_fee_percent, currency)
SELECT 5.00, 0.00, 10.00, 'USD'
WHERE NOT EXISTS (SELECT 1 FROM platform_configs);


-- 2. Stripe Connect Fields on Users Table
ALTER TABLE users ADD COLUMN IF NOT EXISTS stripe_account_id VARCHAR(255);
ALTER TABLE users ADD COLUMN IF NOT EXISTS stripe_onboarding_status VARCHAR(20) DEFAULT 'pending' CHECK (stripe_onboarding_status IN ('pending', 'completed', 'restricted'));


-- 3. Escrow Ledgers (Security Deposits)
CREATE TABLE IF NOT EXISTS escrow_ledgers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID REFERENCES users(id),
    property_id UUID REFERENCES properties(id),
    lease_id UUID REFERENCES leases(id),
    amount DECIMAL(12,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    deposit_type VARCHAR(50) DEFAULT 'security' CHECK (deposit_type IN ('security', 'pet', 'key', 'other')),
    status VARCHAR(20) DEFAULT 'held' CHECK (status IN ('held', 'released', 'partially_deducted', 'fully_deducted')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);


-- 4. Payouts Queue (Landlord & Vendor Payouts)
CREATE TABLE IF NOT EXISTS payouts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    payee_id UUID REFERENCES users(id),
    payee_role VARCHAR(20) NOT NULL CHECK (payee_role IN ('landlord', 'vendor')),
    amount DECIMAL(12,2) NOT NULL,
    platform_fee_deducted DECIMAL(12,2) DEFAULT 0.00,
    currency VARCHAR(3) DEFAULT 'USD',
    status VARCHAR(20) DEFAULT 'queued' CHECK (status IN ('queued', 'processing', 'paid', 'failed', 'released', 'on_hold')),

    scheduled_date DATE NOT NULL,
    processed_date TIMESTAMPTZ,
    transaction_id UUID REFERENCES transactions(id),
    stripe_payout_id VARCHAR(255),
    error_message TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
