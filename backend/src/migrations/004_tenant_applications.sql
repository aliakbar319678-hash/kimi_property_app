-- ==========================================
-- Migration 004: Tenant Applications
-- ==========================================

CREATE TABLE IF NOT EXISTS applications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    property_id UUID REFERENCES properties(id) ON DELETE CASCADE,
    unit_id UUID REFERENCES units(id) ON DELETE CASCADE,
    tenant_id UUID REFERENCES users(id) ON DELETE CASCADE,
    landlord_id UUID REFERENCES users(id) ON DELETE CASCADE,
    screening_fee_paid BOOLEAN DEFAULT false,
    screening_status VARCHAR(20) DEFAULT 'pending' CHECK (screening_status IN ('pending', 'passed', 'failed')),
    approval_status VARCHAR(20) DEFAULT 'pending' CHECK (approval_status IN ('pending', 'approved', 'rejected', 'conditional')),
    conditional_terms JSONB DEFAULT '{}',
    rejection_reason TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for efficient querying
CREATE INDEX IF NOT EXISTS idx_applications_property ON applications(property_id);
CREATE INDEX IF NOT EXISTS idx_applications_tenant ON applications(tenant_id);
CREATE INDEX IF NOT EXISTS idx_applications_landlord ON applications(landlord_id);
CREATE INDEX IF NOT EXISTS idx_applications_status ON applications(approval_status);
