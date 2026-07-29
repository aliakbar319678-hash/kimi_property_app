-- Migration 006: Create tickets + ticket_comments relational tables
-- =================================================================

CREATE TABLE IF NOT EXISTS tickets (
  id                    UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title                 VARCHAR(255)  NOT NULL,
  description           TEXT,
  category              VARCHAR(50)   NOT NULL DEFAULT 'general'
    CHECK (category IN ('general','payment_hold','maintenance','billing','access','other')),
  priority              VARCHAR(20)   NOT NULL DEFAULT 'medium'
    CHECK (priority IN ('low','medium','high','urgent')),
  status                VARCHAR(30)   NOT NULL DEFAULT 'open'
    CHECK (status IN ('open','in_progress','pending_response','resolved','closed','cancelled')),

  -- Relational references (replaces legacy string fields)
  created_by            UUID REFERENCES users(id) ON DELETE SET NULL,
  assigned_staff_id     UUID REFERENCES users(id) ON DELETE SET NULL,

  -- Link to the triggering transaction (for payment_hold tickets)
  linked_transaction_id UUID REFERENCES transactions(id) ON DELETE SET NULL,

  -- Auto-generation flag (set when system creates the ticket)
  is_auto_generated     BOOLEAN NOT NULL DEFAULT FALSE,

  -- Attachment
  attachment_url        VARCHAR(500),
  attachment_size       VARCHAR(50),

  -- Resolution
  resolution_notes      TEXT,
  resolved_at           TIMESTAMPTZ,

  created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at            TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Comments / reply thread per ticket
CREATE TABLE IF NOT EXISTS ticket_comments (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  ticket_id   UUID NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
  sender_id   UUID REFERENCES users(id) ON DELETE SET NULL,
  sender_role VARCHAR(30) NOT NULL DEFAULT 'user',
  message     TEXT NOT NULL,
  is_internal BOOLEAN NOT NULL DEFAULT FALSE,  -- staff-only notes
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Performance indexes
CREATE INDEX IF NOT EXISTS idx_tickets_status           ON tickets(status);
CREATE INDEX IF NOT EXISTS idx_tickets_created_by       ON tickets(created_by);
CREATE INDEX IF NOT EXISTS idx_tickets_assigned_staff   ON tickets(assigned_staff_id) WHERE assigned_staff_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_tickets_linked_txn       ON tickets(linked_transaction_id) WHERE linked_transaction_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_tickets_category_status  ON tickets(category, status);
CREATE INDEX IF NOT EXISTS idx_ticket_comments_ticket   ON ticket_comments(ticket_id, created_at);

-- Trigger: auto-update tickets.updated_at on any row change
CREATE OR REPLACE FUNCTION update_ticket_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_ticket_updated_at ON tickets;
CREATE TRIGGER trg_ticket_updated_at
  BEFORE UPDATE ON tickets
  FOR EACH ROW EXECUTE FUNCTION update_ticket_updated_at();

-- Extend notifications type check to include ticket-related types
ALTER TABLE notifications DROP CONSTRAINT IF EXISTS notifications_type_check;
ALTER TABLE notifications
  ADD CONSTRAINT notifications_type_check
  CHECK (type IN (
    'payment','maintenance','lease','course','system','fraud_alert',
    'ticket','staff','payment_hold'
  ));

-- Also extend wallet_ledger table if it exists (optional; skip if not present)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'wallet_ledger') THEN
    -- Already exists; ensure vendor_hold and vendor_release types are supported
    RAISE NOTICE 'wallet_ledger exists – ensure type constraint includes vendor_hold/vendor_release';
  ELSE
    CREATE TABLE wallet_ledger (
      id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
      user_id        UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      amount         NUMERIC(12,2) NOT NULL,
      type           VARCHAR(30) NOT NULL
        CHECK (type IN ('vendor_hold','vendor_release','rent_credit','refund','platform_fee')),
      transaction_id UUID REFERENCES transactions(id) ON DELETE SET NULL,
      note           TEXT,
      created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );
    CREATE INDEX idx_wallet_ledger_user ON wallet_ledger(user_id, created_at);
  END IF;
END
$$;
