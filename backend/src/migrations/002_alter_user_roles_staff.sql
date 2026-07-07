-- Migration 002: Add 'staff' role + permissions JSONB to user_roles
-- ================================================================

-- Step 1: Drop the existing check constraint on the role column
ALTER TABLE user_roles DROP CONSTRAINT IF EXISTS user_roles_role_check;

-- Step 2: Re-add the constraint with 'staff' included
ALTER TABLE user_roles
  ADD CONSTRAINT user_roles_role_check
  CHECK (role IN ('super_admin','admin','landlord','property_manager','tenant','vendor','lms_instructor','staff'));

-- Step 3: Add permissions JSONB column (default empty object)
ALTER TABLE user_roles
  ADD COLUMN IF NOT EXISTS permissions JSONB NOT NULL DEFAULT '{}';

-- Step 4: Create a comment for documentation
COMMENT ON COLUMN user_roles.permissions IS
  'Granular permission flags e.g. {"can_manage_staff":true,"can_view_tickets":true,"can_resolve_tickets":false}';

-- Step 5: Seed default permissions for existing admin/super_admin rows
UPDATE user_roles
SET permissions = '{
  "can_manage_staff": true,
  "can_view_tickets": true,
  "can_resolve_tickets": true,
  "can_manage_payments": true,
  "can_view_reports": true,
  "can_manage_settings": true
}'::jsonb
WHERE role IN ('admin', 'super_admin');
