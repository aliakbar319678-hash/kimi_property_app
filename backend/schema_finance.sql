CREATE TABLE IF NOT EXISTS platform_configs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    commission_percent NUMERIC(5,2) DEFAULT 0,
    admin_fee NUMERIC(10,2) DEFAULT 0,
    late_fee_percent NUMERIC(5,2) DEFAULT 0,
    currency VARCHAR(10) DEFAULT 'USD',
    updated_by UUID REFERENCES users(id),
    updated_at TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS escrow_ledgers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID REFERENCES users(id),
    property_id UUID REFERENCES properties(id),
    lease_id UUID REFERENCES leases(id),
    amount NUMERIC(10,2) NOT NULL,
    deposit_type VARCHAR(50) DEFAULT 'security',
    status VARCHAR(50) DEFAULT 'held',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS payouts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    payee_id UUID REFERENCES users(id),
    payee_role VARCHAR(50) NOT NULL,
    amount NUMERIC(10,2) NOT NULL,
    platform_fee_deducted NUMERIC(10,2) DEFAULT 0,
    status VARCHAR(50) DEFAULT 'queued',
    scheduled_date DATE,
    processed_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    payer_id UUID REFERENCES users(id),
    payee_id UUID REFERENCES users(id),
    property_id UUID REFERENCES properties(id),
    unit_id UUID,
    lease_id UUID REFERENCES leases(id),
    type VARCHAR(50) NOT NULL,
    amount NUMERIC(10,2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'USD',
    status VARCHAR(50) DEFAULT 'pending',
    gateway VARCHAR(50) DEFAULT 'stripe',
    gateway_transaction_id VARCHAR(255),
    metadata JSONB,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
