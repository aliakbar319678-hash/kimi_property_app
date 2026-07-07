-- Migration 005: Add vendor payment hold fields to transactions table
-- ===================================================================

-- Extend the type check to include vendor_hold and vendor_release
ALTER TABLE transactions DROP CONSTRAINT IF EXISTS transactions_type_check;
ALTER TABLE transactions
  ADD CONSTRAINT transactions_type_check
  CHECK (type IN (
    'rent','deposit','vendor_payout','vendor_hold','vendor_release',
    'refund','late_fee','maintenance_charge','platform_fee'
  ));

-- work_reference: e.g. work order number or invoice ref shown to vendor
ALTER TABLE transactions
  ADD COLUMN IF NOT EXISTS work_reference VARCHAR(255);

-- hold_status lifecycle: holding → released / disputed / cancelled
ALTER TABLE transactions
  ADD COLUMN IF NOT EXISTS hold_status VARCHAR(20)
  CHECK (hold_status IN ('holding','released','disputed','cancelled'));

ALTER TABLE transactions
  ADD COLUMN IF NOT EXISTS hold_start_date    TIMESTAMPTZ;

ALTER TABLE transactions
  ADD COLUMN IF NOT EXISTS hold_release_date  TIMESTAMPTZ;

ALTER TABLE transactions
  ADD COLUMN IF NOT EXISTS released_at        TIMESTAMPTZ;

-- Fee snapshot at the time of payment (in case global fee changes later)
ALTER TABLE transactions
  ADD COLUMN IF NOT EXISTS platform_fee_percentage NUMERIC(5,2);

ALTER TABLE transactions
  ADD COLUMN IF NOT EXISTS platform_fee_amount     NUMERIC(12,2);

ALTER TABLE transactions
  ADD COLUMN IF NOT EXISTS net_amount              NUMERIC(12,2);

-- Indexes for cron job performance
CREATE INDEX IF NOT EXISTS idx_transactions_hold_status
  ON transactions(hold_status) WHERE hold_status IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_transactions_hold_release_date
  ON transactions(hold_release_date) WHERE hold_status = 'holding';

COMMENT ON COLUMN transactions.hold_status IS
  'NULL for non-hold transactions. holding=funds frozen, released=paid out, disputed=under review, cancelled=voided.';
COMMENT ON COLUMN transactions.net_amount IS
  'Amount vendor actually receives after platform_fee_amount is deducted.';
