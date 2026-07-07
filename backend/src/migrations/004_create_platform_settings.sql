-- Migration 004: Create platform_settings table (single-row global config)
-- =========================================================================

CREATE TABLE IF NOT EXISTS platform_settings (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  platform_fee_percentage  NUMERIC(5,2) NOT NULL DEFAULT 8.00,
  hold_period_days         SMALLINT     NOT NULL DEFAULT 5,
  updated_by               UUID REFERENCES users(id) ON DELETE SET NULL,
  updated_at               TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  created_at               TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE platform_settings IS
  'Single-row table storing global platform configuration. Always query with LIMIT 1.';
COMMENT ON COLUMN platform_settings.platform_fee_percentage IS
  'Percentage (0-100) charged as platform fee on every vendor payout.';
COMMENT ON COLUMN platform_settings.hold_period_days IS
  'Number of days vendor payments are held before automatic release.';

-- Seed the default row
INSERT INTO platform_settings (platform_fee_percentage, hold_period_days)
VALUES (8.00, 5)
ON CONFLICT DO NOTHING;
