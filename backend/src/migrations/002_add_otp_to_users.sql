-- Add OTP columns to users table
ALTER TABLE users ADD COLUMN otp_code VARCHAR(10);
ALTER TABLE users ADD COLUMN otp_expires_at TIMESTAMPTZ;
