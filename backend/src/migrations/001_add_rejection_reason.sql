-- Add rejection_reason column to verification_cases and users table
ALTER TABLE verification_cases ADD COLUMN IF NOT EXISTS rejection_reason TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS rejection_reason TEXT;
