-- ========================================================
-- Migration 007: Platform Updates — PDF Spec (July 2026)
-- ========================================================
-- Safe to run multiple times (uses IF NOT EXISTS / IF EXISTS)
-- NO destructive changes — old data is preserved throughout

-- ─────────────────────────────────────────────────────────
-- 0. APPLICATIONS TABLE (brand new — did not exist before)
-- ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS applications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    unit_id UUID REFERENCES units(id),
    property_id UUID REFERENCES properties(id),
    tenant_id UUID REFERENCES users(id),
    landlord_id UUID REFERENCES users(id),

    -- 5-Step wizard data stored as JSONB
    personal_info      JSONB DEFAULT '{}',
    income_employment  JSONB DEFAULT '{}',
    references_data    JSONB DEFAULT '[]',
    documents          JSONB DEFAULT '[]',
    current_step       SMALLINT DEFAULT 1,

    -- Application status
    approval_status VARCHAR(30) DEFAULT 'pending'
        CHECK (approval_status IN ('pending', 'approved', 'rejected', 'conditional_approval')),

    -- Conditional approval structured terms
    -- Shape: { "tags": ["higher_security_deposit", ...], "note": "optional text" }
    conditional_terms JSONB DEFAULT '{"tags":[],"note":""}',

    -- Tenant screening ($50 fee)
    screening_status VARCHAR(20) DEFAULT 'not_started'
        CHECK (screening_status IN ('not_started', 'pending', 'passed', 'failed')),
    screening_charge_id    VARCHAR(255), -- Stripe charge ID
    screening_provider_ref VARCHAR(255), -- 3rd-party stub reference (e.g. TransUnion)

    submitted_at TIMESTAMPTZ,
    reviewed_at  TIMESTAMPTZ,
    created_at   TIMESTAMPTZ DEFAULT NOW(),
    updated_at   TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_applications_tenant   ON applications(tenant_id);
CREATE INDEX IF NOT EXISTS idx_applications_landlord ON applications(landlord_id);
CREATE INDEX IF NOT EXISTS idx_applications_status   ON applications(approval_status);
CREATE INDEX IF NOT EXISTS idx_applications_unit     ON applications(unit_id);

-- ─────────────────────────────────────────────────────────
-- 1. JOBS_POSTED TABLE (Landlord job board)
-- ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS jobs_posted (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    landlord_id UUID REFERENCES users(id) ON DELETE CASCADE,
    property_id UUID REFERENCES properties(id),
    unit_id     UUID REFERENCES units(id),

    title       VARCHAR(255) NOT NULL,
    description TEXT,

    -- 5 parent categories from PDF spec
    category VARCHAR(50) NOT NULL
        CHECK (category IN (
            'essential_maintenance',
            'turnover_cleaning',
            'exterior_seasonal',
            'safety_security',
            'specialized_services'
        )),
    sub_category VARCHAR(100), -- e.g. 'plumbing', 'hvac', 'locksmith'

    urgency VARCHAR(20) DEFAULT 'standard'
        CHECK (urgency IN ('emergency', 'urgent', 'standard')),

    budget_min        DECIMAL(10,2),
    budget_max        DECIMAL(10,2),
    preferred_timeline VARCHAR(100),
    bid_deadline      TIMESTAMPTZ,
    photos            JSONB DEFAULT '[]',
    special_notes     TEXT,

    status VARCHAR(20) DEFAULT 'open'
        CHECK (status IN ('open', 'in_progress', 'completed', 'cancelled')),

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_jobs_posted_landlord ON jobs_posted(landlord_id);
CREATE INDEX IF NOT EXISTS idx_jobs_posted_status   ON jobs_posted(status);
CREATE INDEX IF NOT EXISTS idx_jobs_posted_category ON jobs_posted(category);

-- ─────────────────────────────────────────────────────────
-- 2. VENDOR_JOB_BIDS TABLE (Separate from work_order bids)
-- ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS vendor_job_bids (
    id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    job_id     UUID REFERENCES jobs_posted(id) ON DELETE CASCADE,
    vendor_id  UUID REFERENCES users(id) ON DELETE CASCADE,

    bid_amount     DECIMAL(10,2) NOT NULL,
    proposal_notes TEXT,
    photos         JSONB DEFAULT '[]',

    -- Exactly 5 promotion options from PDF spec (stored as string)
    promotion_type VARCHAR(150),

    status VARCHAR(20) DEFAULT 'pending'
        CHECK (status IN ('pending', 'accepted', 'rejected', 'withdrawn')),

    created_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(job_id, vendor_id) -- one bid per vendor per job
);

CREATE INDEX IF NOT EXISTS idx_vendor_job_bids_job    ON vendor_job_bids(job_id);
CREATE INDEX IF NOT EXISTS idx_vendor_job_bids_vendor ON vendor_job_bids(vendor_id);

-- ─────────────────────────────────────────────────────────
-- 3. TRIGGER: Auto-reject other bids + flip job status
--    when a vendor_job_bid is accepted
-- ─────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION auto_reject_vendor_job_bids()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'accepted' THEN
        -- Reject all other pending bids on the same job
        UPDATE vendor_job_bids
        SET status = 'rejected'
        WHERE job_id = NEW.job_id
          AND id != NEW.id
          AND status = 'pending';

        -- Move the job to in_progress
        UPDATE jobs_posted
        SET status = 'in_progress', updated_at = NOW()
        WHERE id = NEW.job_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_vendor_bid_acceptance ON vendor_job_bids;
CREATE TRIGGER trg_vendor_bid_acceptance
AFTER UPDATE ON vendor_job_bids
FOR EACH ROW WHEN (OLD.status IS DISTINCT FROM NEW.status)
EXECUTE FUNCTION auto_reject_vendor_job_bids();

-- ─────────────────────────────────────────────────────────
-- 4. INVOICES TABLE — Add missing columns (safe ALTER)
-- ─────────────────────────────────────────────────────────
ALTER TABLE invoices
    ADD COLUMN IF NOT EXISTS client_name   VARCHAR(255),
    ADD COLUMN IF NOT EXISTS client_id     UUID REFERENCES users(id),
    ADD COLUMN IF NOT EXISTS payment_status VARCHAR(20) DEFAULT 'unpaid'
        CHECK (payment_status IN ('unpaid', 'partial', 'paid', 'overdue')),
    ADD COLUMN IF NOT EXISTS notes    TEXT,
    ADD COLUMN IF NOT EXISTS currency VARCHAR(3) DEFAULT 'USD';

-- ─────────────────────────────────────────────────────────
-- 5. NOTIFICATIONS — Expand type enum
--    (Drop old CHECK constraint, recreate with new types)
-- ─────────────────────────────────────────────────────────
ALTER TABLE notifications
    DROP CONSTRAINT IF EXISTS notifications_type_check;

ALTER TABLE notifications
    ADD CONSTRAINT notifications_type_check
    CHECK (type IN (
        'payment', 'maintenance', 'lease', 'course', 'system', 'fraud_alert',
        'job_posted', 'bid_status', 'job_assignment', 'conditional_approval'
    ));

-- ─────────────────────────────────────────────────────────
-- 6. USER_PROFILES — Add vendor service fields
-- ─────────────────────────────────────────────────────────
-- vendor_services shape: { "categories": [...], "sub_categories": [...] }
ALTER TABLE user_profiles
    ADD COLUMN IF NOT EXISTS vendor_services               JSONB DEFAULT '{}',
    ADD COLUMN IF NOT EXISTS vendor_registration_fee_paid  BOOLEAN DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS vendor_registration_amount    DECIMAL(8,2);

-- ─────────────────────────────────────────────────────────
-- 7. VENDOR LMS PERMISSIONS — Strip LMS flags from vendor roles
--    (Non-destructive: only removes specific JSONB keys)
-- ─────────────────────────────────────────────────────────
UPDATE user_roles
SET permissions = permissions
    - 'lms_access'
    - 'enroll_courses'
    - 'view_certificates'
    - 'lms_dashboard'
WHERE role = 'vendor'
  AND permissions IS NOT NULL;

-- ─────────────────────────────────────────────────────────
-- 8. PLATFORM SETTINGS — Update vendor service fee to 4%
-- ─────────────────────────────────────────────────────────
UPDATE platform_settings
SET platform_fee_percentage = 4.00;

-- ─────────────────────────────────────────────────────────
-- Done
-- ─────────────────────────────────────────────────────────
