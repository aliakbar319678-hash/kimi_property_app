-- Migration: Add US/CA onboarding fields
ALTER TABLE user_profiles
ADD COLUMN IF NOT EXISTS ssn_sin_last4 VARCHAR(4),
ADD COLUMN IF NOT EXISTS tax_identifier TEXT, -- Encrypted field for full SSN/SIN
ADD COLUMN IF NOT EXISTS credit_score SMALLINT,
ADD COLUMN IF NOT EXISTS background_check_status VARCHAR(20) DEFAULT 'pending' CHECK (background_check_status IN ('pending', 'passed', 'failed', 'reviewing'));
