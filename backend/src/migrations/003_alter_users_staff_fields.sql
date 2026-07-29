-- Migration 003: Add staff-related fields to users table
-- ======================================================

-- Add is_active flag (used for account suspension / staff deactivation)
ALTER TABLE users
  ADD COLUMN IF NOT EXISTS is_active BOOLEAN NOT NULL DEFAULT TRUE;

-- Add department for staff members
ALTER TABLE users
  ADD COLUMN IF NOT EXISTS department VARCHAR(100);

-- Add created_by (which admin/super_admin created this user)
ALTER TABLE users
  ADD COLUMN IF NOT EXISTS created_by UUID REFERENCES users(id) ON DELETE SET NULL;

-- Add wallet balance fields for vendors
ALTER TABLE users
  ADD COLUMN IF NOT EXISTS available_balance NUMERIC(14,2) NOT NULL DEFAULT 0.00;

ALTER TABLE users
  ADD COLUMN IF NOT EXISTS held_balance NUMERIC(14,2) NOT NULL DEFAULT 0.00;

-- Indexes
CREATE INDEX IF NOT EXISTS idx_users_department ON users(department) WHERE department IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_users_created_by ON users(created_by) WHERE created_by IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_users_is_active ON users(is_active);

COMMENT ON COLUMN users.is_active IS 'FALSE = account suspended/deactivated';
COMMENT ON COLUMN users.department IS 'Staff department e.g. Support, Finance, Operations';
COMMENT ON COLUMN users.available_balance IS 'Vendor: funds available for withdrawal';
COMMENT ON COLUMN users.held_balance IS 'Vendor: funds currently in 5-day payment hold';
