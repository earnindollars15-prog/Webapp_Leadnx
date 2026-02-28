-- ============================================================
-- LEADNX – STAGE 1: TRIGGERS
-- File: 003_triggers.sql
-- Run AFTER 002_indexes.sql
-- ============================================================

-- ============================================================
-- TRIGGER 1: Auto-generate lead_code (LNDX-00001 format)
-- Uses PostgreSQL SEQUENCE — safe for concurrent inserts
-- (MAX+1 approach is NOT safe under concurrency — race condition risk)
-- ============================================================

-- Create a dedicated sequence for lead codes
CREATE SEQUENCE IF NOT EXISTS lead_code_seq START 1 INCREMENT 1;

CREATE OR REPLACE FUNCTION generate_lead_code()
RETURNS TRIGGER AS $$
BEGIN
  -- nextval is atomic — no race condition possible, even at high concurrency
  NEW.lead_code := 'LNDX-' || LPAD(nextval('lead_code_seq')::TEXT, 5, '0');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_generate_lead_code
  BEFORE INSERT ON leads
  FOR EACH ROW
  WHEN (NEW.lead_code IS NULL)
  EXECUTE FUNCTION generate_lead_code();

-- ============================================================
-- TRIGGER 2: Auto-update updated_at timestamp
-- Shared function used by all tables
-- ============================================================

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to: clients
CREATE TRIGGER trg_clients_updated_at
  BEFORE UPDATE ON clients
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

-- Apply to: branches
CREATE TRIGGER trg_branches_updated_at
  BEFORE UPDATE ON branches
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

-- Apply to: users
CREATE TRIGGER trg_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

-- Apply to: leads
CREATE TRIGGER trg_leads_updated_at
  BEFORE UPDATE ON leads
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

-- Apply to: subscriptions
CREATE TRIGGER trg_subscriptions_updated_at
  BEFORE UPDATE ON subscriptions
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();
