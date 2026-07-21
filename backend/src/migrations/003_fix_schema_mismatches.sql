-- ==========================================
-- PropAdmin Migration 003: Fix Schema Mismatches
-- Generated: 2026-07-21
-- Fixes all issues found in backend_deep_bug_report.json
-- ==========================================

-- ==========================================
-- 1. CREATE MISSING TABLE: move_inspections
-- ==========================================
-- The backend routes (move.routes.ts) and upload.service.ts both use a SINGLE
-- unified "move_inspections" table for both move-in checklists and move-out
-- inspections. The 001 migration created two separate tables which no code uses.
CREATE TABLE IF NOT EXISTS move_inspections (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lease_id UUID REFERENCES leases(id) ON DELETE CASCADE,
    type VARCHAR(20) NOT NULL CHECK (type IN ('MOVE_IN', 'MOVE_OUT')),
    inspector_id UUID REFERENCES users(id) ON DELETE SET NULL,
    condition_ratings JSONB DEFAULT '{}',
    photos JSONB DEFAULT '[]',
    items JSONB DEFAULT '[]',
    deposit_refunded DECIMAL(12,2) DEFAULT 0.00,
    transaction_id VARCHAR(255),
    tenant_signature TEXT,
    landlord_signature TEXT,
    signed_at TIMESTAMPTZ,
    status VARCHAR(20) DEFAULT 'draft' CHECK (status IN ('draft', 'signed', 'finalized')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_move_inspections_lease ON move_inspections(lease_id);
CREATE INDEX IF NOT EXISTS idx_move_inspections_type ON move_inspections(type);

-- ==========================================
-- 2. CREATE MISSING TABLE: vendor_profiles_advanced
-- ==========================================
-- Used by vendor_advanced.routes.ts for ratings aggregation and insurance tracking.
CREATE TABLE IF NOT EXISTS vendor_profiles_advanced (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id UUID UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    average_rating DECIMAL(3,2) DEFAULT 0.00,
    total_jobs_completed INT DEFAULT 0,
    insurance_policy_number VARCHAR(100),
    insurance_expiry DATE,
    is_insurance_verified BOOLEAN DEFAULT FALSE,
    specializations JSONB DEFAULT '[]',
    service_areas JSONB DEFAULT '[]',
    bio TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_vendor_profiles_advanced_vendor ON vendor_profiles_advanced(vendor_id);

-- ==========================================
-- 3. FIX TABLE: screening_applications
-- ==========================================
-- Routes use: tenant_id, monthly_income, employment_status, credit_score_mock, background_status_mock
-- Schema had: applicant_id, credit_score, background_check (JSONB), employment_verified
ALTER TABLE screening_applications
    ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES users(id) ON DELETE CASCADE,
    ADD COLUMN IF NOT EXISTS monthly_income DECIMAL(12,2) DEFAULT 0.00,
    ADD COLUMN IF NOT EXISTS employment_status VARCHAR(50) DEFAULT 'employed',
    ADD COLUMN IF NOT EXISTS credit_score_mock INT,
    ADD COLUMN IF NOT EXISTS background_status_mock VARCHAR(50) DEFAULT 'PENDING';

-- Backfill existing rows
UPDATE screening_applications SET tenant_id = applicant_id WHERE tenant_id IS NULL AND applicant_id IS NOT NULL;
UPDATE screening_applications SET credit_score_mock = credit_score WHERE credit_score_mock IS NULL AND credit_score IS NOT NULL;

-- ==========================================
-- 4. FIX TABLE: late_payment_notices
-- ==========================================
-- Routes use: amount_due, late_fee_applied, days_late, notice_status, legal_case_reference, court_hearing_date, legal_documents
-- Schema had: due_amount, late_fee, status, legal_action_required
ALTER TABLE late_payment_notices
    ADD COLUMN IF NOT EXISTS amount_due DECIMAL(12,2),
    ADD COLUMN IF NOT EXISTS late_fee_applied DECIMAL(10,2) DEFAULT 0.00,
    ADD COLUMN IF NOT EXISTS days_late INT DEFAULT 1,
    ADD COLUMN IF NOT EXISTS notice_status VARCHAR(20) DEFAULT 'SENT',
    ADD COLUMN IF NOT EXISTS legal_case_reference VARCHAR(255),
    ADD COLUMN IF NOT EXISTS court_hearing_date DATE,
    ADD COLUMN IF NOT EXISTS legal_documents JSONB DEFAULT '[]';

-- Backfill existing rows
UPDATE late_payment_notices SET amount_due = due_amount WHERE amount_due IS NULL AND due_amount IS NOT NULL;
UPDATE late_payment_notices SET late_fee_applied = late_fee WHERE late_fee_applied = 0.00 AND late_fee IS NOT NULL AND late_fee > 0;
UPDATE late_payment_notices SET notice_status = UPPER(status) WHERE status IS NOT NULL;

-- ==========================================
-- 5. FIX TABLE: property_marketing
-- ==========================================
-- Routes use: public_description, is_featured, amenities (JSONB)
-- Schema had: seo_description, featured, keywords
ALTER TABLE property_marketing
    ADD COLUMN IF NOT EXISTS public_description TEXT,
    ADD COLUMN IF NOT EXISTS is_featured BOOLEAN DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS amenities JSONB DEFAULT '[]';

-- Backfill existing rows
UPDATE property_marketing SET public_description = seo_description WHERE public_description IS NULL AND seo_description IS NOT NULL;
UPDATE property_marketing SET is_featured = featured WHERE featured IS NOT NULL;

-- ==========================================
-- 6. FIX TABLE: showings
-- ==========================================
-- Routes use: tenant_id, showing_date (TIMESTAMPTZ)
-- Schema had: applicant_id, scheduled_at
ALTER TABLE showings
    ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES users(id) ON DELETE CASCADE,
    ADD COLUMN IF NOT EXISTS showing_date TIMESTAMPTZ;

-- Backfill existing rows
UPDATE showings SET tenant_id = applicant_id WHERE tenant_id IS NULL AND applicant_id IS NOT NULL;
UPDATE showings SET showing_date = scheduled_at WHERE showing_date IS NULL AND scheduled_at IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_showings_showing_date ON showings(showing_date);
CREATE INDEX IF NOT EXISTS idx_showings_tenant ON showings(tenant_id);

-- ==========================================
-- 7. FIX TABLE: vendor_reviews
-- ==========================================
-- Routes use: categories (JSONB) — was missing entirely
ALTER TABLE vendor_reviews
    ADD COLUMN IF NOT EXISTS categories JSONB DEFAULT '[]';

-- ==========================================
-- 8. Additional indexes for performance
-- ==========================================
CREATE INDEX IF NOT EXISTS idx_screening_tenant ON screening_applications(tenant_id);
CREATE INDEX IF NOT EXISTS idx_late_notices_lease ON late_payment_notices(lease_id);
CREATE INDEX IF NOT EXISTS idx_late_notices_tenant ON late_payment_notices(tenant_id);
CREATE INDEX IF NOT EXISTS idx_property_marketing_featured ON property_marketing(is_featured);
CREATE INDEX IF NOT EXISTS idx_vendor_reviews_vendor ON vendor_reviews(vendor_id);

-- ==========================================
-- Migration 003 Complete
-- Tables created:    move_inspections, vendor_profiles_advanced
-- Columns added:     screening_applications(5), late_payment_notices(7),
--                    property_marketing(3), showings(2), vendor_reviews(1)
-- Backfills applied: All renamed columns populated from their old equivalents
-- ==========================================
