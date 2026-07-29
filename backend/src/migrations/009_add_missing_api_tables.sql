-- Migration: 009_add_missing_api_tables.sql
-- Description: Adds tables for inspections, LMS, and ensures vendor reviews have needed columns

-- 1. Inspections Table
CREATE TABLE IF NOT EXISTS inspections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lease_id UUID NOT NULL,
    inspection_id VARCHAR(50) UNIQUE NOT NULL,
    type VARCHAR(20) NOT NULL, -- 'MOVE_IN', 'MOVE_OUT', etc.
    status VARCHAR(20) NOT NULL DEFAULT 'COMPLETED',
    inspection_date DATE NOT NULL,
    inspector_name VARCHAR(100) NOT NULL,
    total_items_checked INT DEFAULT 0,
    flagged_issues INT DEFAULT 0,
    pdf_report_url VARCHAR(255),
    checklist_data JSONB,
    landlord_signature TEXT,
    tenant_signature TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. LMS Courses Table
CREATE TABLE IF NOT EXISTS lms_courses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id VARCHAR(50) UNIQUE NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. LMS Quizzes & Results
CREATE TABLE IF NOT EXISTS lms_quizzes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id UUID REFERENCES lms_courses(id) ON DELETE CASCADE,
    quiz_id VARCHAR(50) UNIQUE NOT NULL,
    title VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS lms_quiz_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL, -- Assuming references users(id) is implicit or handled in code
    quiz_id VARCHAR(50) NOT NULL, -- references lms_quizzes(quiz_id)
    passed BOOLEAN NOT NULL,
    score_percentage DECIMAL(5, 2) NOT NULL,
    certificate_url VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. Vendor Ratings Extensions
-- Adding extra columns to vendor_reviews if they don't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='vendor_reviews' AND column_name='punctuality_score') THEN
        ALTER TABLE vendor_reviews ADD COLUMN punctuality_score INT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='vendor_reviews' AND column_name='quality_score') THEN
        ALTER TABLE vendor_reviews ADD COLUMN quality_score INT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='vendor_reviews' AND column_name='review_text') THEN
        ALTER TABLE vendor_reviews ADD COLUMN review_text TEXT;
    END IF;
END $$;

-- 5. Vendor Insurance
-- Ensuring there is a way to store COI for vendors if not present
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='vendors' AND column_name='policy_number') THEN
        ALTER TABLE vendors ADD COLUMN policy_number VARCHAR(100);
        ALTER TABLE vendors ADD COLUMN coverage_amount VARCHAR(100);
        ALTER TABLE vendors ADD COLUMN insurance_provider VARCHAR(255);
        ALTER TABLE vendors ADD COLUMN insurance_expiration_date DATE;
        ALTER TABLE vendors ADD COLUMN certificate_url VARCHAR(255);
    END IF;
END $$;
