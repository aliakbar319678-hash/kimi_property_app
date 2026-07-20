-- ==========================================
-- PropAdmin Advanced Schema Expansion v2.1
-- ==========================================

-- 1. Tenant Screening
CREATE TABLE IF NOT EXISTS screening_applications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4 (),
    applicant_id UUID REFERENCES users (id) ON DELETE CASCADE,
    property_id UUID REFERENCES properties (id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'pending_review' CHECK (
        status IN (
            'pending_review',
            'approved',
            'rejected',
            'escalated'
        )
    ),
    credit_score INT,
    background_check JSONB DEFAULT '{}', -- criminal_record, evictions, etc.
    employment_verified BOOLEAN DEFAULT FALSE,
    references_data JSONB DEFAULT '[]', -- references list
    income_verified BOOLEAN DEFAULT FALSE,
    decision VARCHAR(20) DEFAULT 'pending' CHECK (
        decision IN (
            'pending',
            'approve',
            'reject',
            'conditional'
        )
    ),
    decided_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW (),
    updated_at TIMESTAMPTZ DEFAULT NOW ()
);

-- 2. Move-in Checklists
CREATE TABLE IF NOT EXISTS move_in_checklists (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4 (),
    lease_id UUID REFERENCES leases (id) ON DELETE CASCADE,
    tenant_id UUID REFERENCES users (id) ON DELETE CASCADE,
    landlord_id UUID REFERENCES users (id) ON DELETE CASCADE,
    items JSONB DEFAULT '[]', -- list of checklist items with status
    photos JSONB DEFAULT '[]', -- list of photo URLs
    condition_ratings JSONB DEFAULT '{}', -- item-level condition ratings
    signed_by_tenant BOOLEAN DEFAULT FALSE,
    signed_by_landlord BOOLEAN DEFAULT FALSE,
    signed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW (),
    updated_at TIMESTAMPTZ DEFAULT NOW ()
);

-- 3. Move-out Inspections
CREATE TABLE IF NOT EXISTS move_out_inspections (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4 (),
    lease_id UUID REFERENCES leases (id) ON DELETE CASCADE,
    inspection_date DATE NOT NULL,
    findings JSONB DEFAULT '[]',
    photos JSONB DEFAULT '[]',
    damage_costs DECIMAL(12, 2) DEFAULT 0.00,
    deposit_deductions DECIMAL(12, 2) DEFAULT 0.00,
    final_deposit_amount DECIMAL(12, 2) DEFAULT 0.00,
    returned_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW ()
);

-- 4. Late Payment Notices
CREATE TABLE IF NOT EXISTS late_payment_notices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4 (),
    lease_id UUID REFERENCES leases (id) ON DELETE CASCADE,
    tenant_id UUID REFERENCES users (id) ON DELETE CASCADE,
    notice_type VARCHAR(50) NOT NULL CHECK (
        notice_type IN (
            'first_notice',
            'second_notice',
            'final_notice',
            'legal_action'
        )
    ),
    sent_at TIMESTAMPTZ DEFAULT NOW (),
    due_amount DECIMAL(12, 2) NOT NULL,
    late_fee DECIMAL(10, 2) DEFAULT 0.00,
    status VARCHAR(20) DEFAULT 'unpaid' CHECK (
        status IN ('unpaid', 'paid', 'dismissed')
    ),
    legal_action_required BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW ()
);

-- 5. Vendor Ratings
CREATE TABLE IF NOT EXISTS vendor_ratings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4 (),
    vendor_id UUID REFERENCES users (id) ON DELETE CASCADE,
    rated_by UUID REFERENCES users (id) ON DELETE CASCADE,
    rating SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review TEXT,
    categories JSONB DEFAULT '[]', -- list of services rated
    created_at TIMESTAMPTZ DEFAULT NOW ()
);

-- 6. Vendor Insurances
CREATE TABLE IF NOT EXISTS vendor_insurances (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4 (),
    vendor_id UUID REFERENCES users (id) ON DELETE CASCADE,
    insurance_type VARCHAR(100) NOT NULL,
    provider VARCHAR(255) NOT NULL,
    policy_number VARCHAR(100) NOT NULL,
    expiry_date DATE NOT NULL,
    coverage_amount DECIMAL(15, 2) NOT NULL,
    verified BOOLEAN DEFAULT FALSE,
    verified_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW (),
    updated_at TIMESTAMPTZ DEFAULT NOW ()
);

-- 7. Email Templates
CREATE TABLE IF NOT EXISTS email_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4 (),
    name VARCHAR(100) UNIQUE NOT NULL,
    subject VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    variables JSONB DEFAULT '[]',
    type VARCHAR(50) DEFAULT 'general',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW (),
    updated_at TIMESTAMPTZ DEFAULT NOW ()
);

-- 8. SMS Logs
CREATE TABLE IF NOT EXISTS sms_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4 (),
    user_id UUID REFERENCES users (id) ON DELETE SET NULL,
    phone VARCHAR(20) NOT NULL,
    message TEXT NOT NULL,
    status VARCHAR(20) DEFAULT 'sent' CHECK (
        status IN ('queued', 'sent', 'failed')
    ),
    sent_at TIMESTAMPTZ DEFAULT NOW (),
    provider VARCHAR(50) DEFAULT 'mock'
);

-- 9. Property Marketing
CREATE TABLE IF NOT EXISTS property_marketing (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4 (),
    property_id UUID REFERENCES properties (id) ON DELETE CASCADE UNIQUE,
    listing_sites JSONB DEFAULT '[]', -- where property is listed
    virtual_tour_url VARCHAR(500),
    featured BOOLEAN DEFAULT FALSE,
    seo_title VARCHAR(255),
    seo_description TEXT,
    keywords JSONB DEFAULT '[]',
    created_at TIMESTAMPTZ DEFAULT NOW (),
    updated_at TIMESTAMPTZ DEFAULT NOW ()
);

-- 10. Showings
CREATE TABLE IF NOT EXISTS showings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4 (),
    property_id UUID REFERENCES properties (id) ON DELETE CASCADE,
    applicant_id UUID REFERENCES users (id) ON DELETE CASCADE,
    scheduled_at TIMESTAMPTZ NOT NULL,
    status VARCHAR(20) DEFAULT 'scheduled' CHECK (
        status IN (
            'scheduled',
            'completed',
            'cancelled',
            'no_show'
        )
    ),
    notes TEXT,
    feedback TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW (),
    updated_at TIMESTAMPTZ DEFAULT NOW ()
);

-- 11. Renewal Notices
CREATE TABLE IF NOT EXISTS renewal_notices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4 (),
    lease_id UUID REFERENCES leases (id) ON DELETE CASCADE,
    notice_sent_at TIMESTAMPTZ DEFAULT NOW (),
    tenant_response VARCHAR(50) DEFAULT 'pending' CHECK (
        tenant_response IN (
            'pending',
            'renew',
            'vacate',
            'negotiate'
        )
    ),
    new_rent_amount DECIMAL(12, 2),
    decision VARCHAR(50) DEFAULT 'pending',
    decision_deadline DATE,
    created_at TIMESTAMPTZ DEFAULT NOW (),
    updated_at TIMESTAMPTZ DEFAULT NOW ()
);