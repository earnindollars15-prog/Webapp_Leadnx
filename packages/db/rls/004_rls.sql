-- ============================================================
-- LEADNX – STAGE 1: ROW LEVEL SECURITY (RLS) POLICIES
-- File: 004_rls.sql
-- Run AFTER 003_triggers.sql
-- ============================================================

-- ============================================================
-- HELPER: Get current user's metadata from JWT
-- These functions read from the JWT set by Supabase Auth
-- ============================================================

-- Get current user's client_id from JWT
CREATE OR REPLACE FUNCTION get_my_client_id()
RETURNS UUID AS $$
  SELECT NULLIF(
    (auth.jwt() -> 'user_metadata' ->> 'client_id'),
    ''
  )::UUID;
$$ LANGUAGE sql STABLE;

-- Get current user's role from JWT
CREATE OR REPLACE FUNCTION get_my_role()
RETURNS TEXT AS $$
  SELECT auth.jwt() -> 'user_metadata' ->> 'role';
$$ LANGUAGE sql STABLE;

-- Get current user's branch_id from JWT
CREATE OR REPLACE FUNCTION get_my_branch_id()
RETURNS UUID AS $$
  SELECT NULLIF(
    (auth.jwt() -> 'user_metadata' ->> 'branch_id'),
    ''
  )::UUID;
$$ LANGUAGE sql STABLE;

-- Check if current user is superadmin
CREATE OR REPLACE FUNCTION is_superadmin()
RETURNS BOOLEAN AS $$
  SELECT get_my_role() = 'superadmin';
$$ LANGUAGE sql STABLE;

-- ============================================================
-- ENABLE RLS ON ALL OPERATIONAL TABLES
-- ============================================================

ALTER TABLE clients            ENABLE ROW LEVEL SECURITY;
ALTER TABLE branches           ENABLE ROW LEVEL SECURITY;
ALTER TABLE users              ENABLE ROW LEVEL SECURITY;
ALTER TABLE leads              ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions      ENABLE ROW LEVEL SECURITY;
ALTER TABLE lead_audit_logs    ENABLE ROW LEVEL SECURITY;
ALTER TABLE campaign_branch_map ENABLE ROW LEVEL SECURITY;
ALTER TABLE webhook_logs       ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- TABLE: clients
-- Superadmin: full access
-- Others: only their own client row
-- ============================================================

CREATE POLICY "clients_superadmin_all"
  ON clients FOR ALL
  USING (is_superadmin());

CREATE POLICY "clients_own_row_select"
  ON clients FOR SELECT
  USING (
    NOT is_superadmin()
    AND id = get_my_client_id()
  );

-- ============================================================
-- TABLE: subscriptions
-- Superadmin: full access
-- brand_admin: see own client subscription
-- ============================================================

CREATE POLICY "subscriptions_superadmin_all"
  ON subscriptions FOR ALL
  USING (is_superadmin());

CREATE POLICY "subscriptions_brand_admin_select"
  ON subscriptions FOR SELECT
  USING (
    NOT is_superadmin()
    AND client_id = get_my_client_id()
  );

-- ============================================================
-- TABLE: branches
-- Superadmin: full access
-- brand_admin: all branches under their client
-- branch_admin/employee: only their own branch
-- ============================================================

CREATE POLICY "branches_superadmin_all"
  ON branches FOR ALL
  USING (is_superadmin());

CREATE POLICY "branches_brand_admin_all"
  ON branches FOR ALL
  USING (
    get_my_role() = 'brand_admin'
    AND client_id = get_my_client_id()
  );

CREATE POLICY "branches_branch_level_select"
  ON branches FOR SELECT
  USING (
    get_my_role() IN ('branch_admin', 'employee')
    AND id = get_my_branch_id()
  );

-- ============================================================
-- TABLE: users
-- Superadmin: full access
-- brand_admin: all users under their client
-- branch_admin: users in their branch
-- employee: only themselves
-- ============================================================

CREATE POLICY "users_superadmin_all"
  ON users FOR ALL
  USING (is_superadmin());

CREATE POLICY "users_brand_admin_all"
  ON users FOR ALL
  USING (
    get_my_role() = 'brand_admin'
    AND client_id = get_my_client_id()
  );

CREATE POLICY "users_branch_admin_branch"
  ON users FOR SELECT
  USING (
    get_my_role() = 'branch_admin'
    AND client_id = get_my_client_id()
    AND branch_id = get_my_branch_id()
  );

CREATE POLICY "users_employee_self"
  ON users FOR SELECT
  USING (
    get_my_role() = 'employee'
    AND auth_user_id = auth.uid()
  );

-- ============================================================
-- TABLE: leads
-- Superadmin: full access
-- brand_admin: all leads for their client
-- branch_admin: leads in their branch
-- employee: only assigned leads
-- ============================================================

CREATE POLICY "leads_superadmin_all"
  ON leads FOR ALL
  USING (is_superadmin());

CREATE POLICY "leads_brand_admin_all"
  ON leads FOR ALL
  USING (
    get_my_role() = 'brand_admin'
    AND client_id = get_my_client_id()
    AND is_deleted = FALSE
  );

CREATE POLICY "leads_branch_admin_branch"
  ON leads FOR ALL
  USING (
    get_my_role() = 'branch_admin'
    AND client_id = get_my_client_id()
    AND branch_id = get_my_branch_id()
    AND is_deleted = FALSE
  );

CREATE POLICY "leads_employee_assigned"
  ON leads FOR SELECT
  USING (
    get_my_role() = 'employee'
    AND client_id = get_my_client_id()
    AND assigned_to = (
      SELECT id FROM users WHERE auth_user_id = auth.uid() LIMIT 1
    )
    AND is_deleted = FALSE
  );

CREATE POLICY "leads_employee_update_assigned"
  ON leads FOR UPDATE
  USING (
    get_my_role() = 'employee'
    AND client_id = get_my_client_id()
    AND assigned_to = (
      SELECT id FROM users WHERE auth_user_id = auth.uid() LIMIT 1
    )
    AND is_deleted = FALSE
  );

-- ============================================================
-- TABLE: lead_audit_logs
-- Superadmin: full access
-- brand_admin: all logs for their client
-- branch_admin/employee: logs for leads in their scope
-- ============================================================

CREATE POLICY "audit_superadmin_all"
  ON lead_audit_logs FOR ALL
  USING (is_superadmin());

CREATE POLICY "audit_brand_admin_client"
  ON lead_audit_logs FOR SELECT
  USING (
    get_my_role() = 'brand_admin'
    AND client_id = get_my_client_id()
  );

CREATE POLICY "audit_insert_all_authenticated"
  ON lead_audit_logs FOR INSERT
  WITH CHECK (client_id = get_my_client_id());

-- ============================================================
-- TABLE: campaign_branch_map
-- Superadmin: full access
-- brand_admin: manage their own mappings
-- ============================================================

CREATE POLICY "campaign_map_superadmin_all"
  ON campaign_branch_map FOR ALL
  USING (is_superadmin());

CREATE POLICY "campaign_map_brand_admin_all"
  ON campaign_branch_map FOR ALL
  USING (
    get_my_role() = 'brand_admin'
    AND client_id = get_my_client_id()
  );

CREATE POLICY "campaign_map_read_branch"
  ON campaign_branch_map FOR SELECT
  USING (
    get_my_role() IN ('branch_admin', 'employee')
    AND client_id = get_my_client_id()
  );

-- ============================================================
-- TABLE: webhook_logs
-- Superadmin: full access
-- Others: no direct access (backend service role only)
-- ============================================================

CREATE POLICY "webhook_logs_superadmin_all"
  ON webhook_logs FOR ALL
  USING (is_superadmin());
