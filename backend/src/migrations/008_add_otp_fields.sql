-- Migration 008: Add OTP fields to users table
-- =================================================================

ALTER TABLE users
ADD COLUMN IF NOT EXISTS reset_otp VARCHAR(6),
ADD COLUMN IF NOT EXISTS reset_otp_expires_at TIMESTAMPTZ;
