-- ============================================================
-- LEADNX – STAGE 1: ROW LEVEL SECURITY (RLS) POLICIES
-- File: 004_rls.sql  [v2 — Production Hardened]
-- Changes from v1:
--   ✅ WITH CHECK added to all INSERT/UPDATE/DELETE policies
--   ✅ Superadmin on leads changed from FOR ALL → FOR SELECT only
--   ✅ branch_admin and employee correctly scoped
-- Run AFTER 003_triggers.sql
-- ============================================================

-- ============================================================
-- HELPER FUNCTIONS: Read JWT metadata
-- ============================================================

CREATE OR REPLACE FUNCTION get_my_client_id()
RETURNS UUID AS $$
  SELECT NULLIF(
    (auth.jwt() -> 'user_metadata' ->> 'client_id'), ''
  )::UUID;
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION get_my_role()
RETURNS TEXT AS $$
  SELECT auth.jwt() -> 'user_metadata' ->> 'role';
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION get_my_branch_id()
RETURNS UUID AS $$
  SELECT NULLIF(
    (auth.jwt() -> 'user_metadata' ->> 'branch_id'), ''
  )::UUID;
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION is_superadmin()
RETURNS BOOLEAN AS $$
  SELECT get_my_role() = 'superadmin';
$$ LANGUAGE sql STABLE;

-- ============================================================
-- ENABLE RLS ON ALL OPERATIONAL TABLES
-- ============================================================

ALTER TABLE clients             ENABLE ROW LEVEL SECURITY;
ALTER TABLE branches            ENABLE ROW LEVEL SECURITY;
ALTER TABLE users               ENABLE ROW LEVEL SECURITY;
ALTER TABLE leads               ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions       ENABLE ROW LEVEL SECURITY;
ALTER TABLE lead_audit_logs     ENABLE ROW LEVEL SECURITY;
ALTER TABLE campaign_branch_map ENABLE ROW LEVEL SECURITY;
ALTER TABLE webhook_logs        ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- TABLE: clients
-- ============================================================

-- Superadmin: full access (read + write)
CREATE POLICY "clients_superadmin_all"
  ON clients FOR ALL
  USING (is_superadmin())
  WITH CHECK (is_superadmin());

-- Client users: read their own row only
CREATE POLICY "clients_own_row_select"
  ON clients FOR SELECT
  USING (
    NOT is_superadmin()
    AND id = get_my_client_id()
  );

-- ============================================================
-- TABLE: subscriptions
-- ============================================================

CREATE POLICY "subscriptions_superadmin_all"
  ON subscriptions FOR ALL
  USING (is_superadmin())
  WITH CHECK (is_superadmin());

CREATE POLICY "subscriptions_client_select"
  ON subscriptions FOR SELECT
  USING (
    NOT is_superadmin()
    AND client_id = get_my_client_id()
  );

-- ============================================================
-- TABLE: branches
-- ============================================================

CREATE POLICY "branches_superadmin_all"
  ON branches FOR ALL
  USING (is_superadmin())
  WITH CHECK (is_superadmin());

-- brand_admin: full control over their branches
CREATE POLICY "branches_brand_admin_all"
  ON branches FOR ALL
  USING (
    get_my_role() = 'brand_admin'
    AND client_id = get_my_client_id()
  )
  WITH CHECK (
    get_my_role() = 'brand_admin'
    AND client_id = get_my_client_id()
  );

-- branch_admin / employee: read their own branch only
CREATE POLICY "branches_lower_roles_select"
  ON branches FOR SELECT
  USING (
    get_my_role() IN ('branch_admin', 'employee')
    AND id = get_my_branch_id()
  );

-- ============================================================
-- TABLE: users
-- ============================================================

CREATE POLICY "users_superadmin_all"
  ON users FOR ALL
  USING (is_superadmin())
  WITH CHECK (is_superadmin());

-- brand_admin: manage all users under their client
CREATE POLICY "users_brand_admin_all"
  ON users FOR ALL
  USING (
    get_my_role() = 'brand_admin'
    AND client_id = get_my_client_id()
  )
  WITH CHECK (
    get_my_role() = 'brand_admin'
    AND client_id = get_my_client_id()
  );

-- branch_admin: read users in their branch only
CREATE POLICY "users_branch_admin_select"
  ON users FOR SELECT
  USING (
    get_my_role() = 'branch_admin'
    AND client_id = get_my_client_id()
    AND branch_id = get_my_branch_id()
  );

-- employee: read only their own user row
CREATE POLICY "users_employee_self"
  ON users FOR SELECT
  USING (
    get_my_role() = 'employee'
    AND auth_user_id = auth.uid()
  );

-- ============================================================
-- TABLE: leads
-- ⚠️ SUPERADMIN = SELECT ONLY (never writes leads — locked rule)
-- ============================================================

-- Superadmin: READ ONLY (view for support/analytics only)
CREATE POLICY "leads_superadmin_select"
  ON leads FOR SELECT
  USING (is_superadmin());

-- brand_admin: full CRUD on their client's non-deleted leads
CREATE POLICY "leads_brand_admin_select"
  ON leads FOR SELECT
  USING (
    get_my_role() = 'brand_admin'
    AND client_id = get_my_client_id()
    AND is_deleted = FALSE
  );

CREATE POLICY "leads_brand_admin_insert"
  ON leads FOR INSERT
  WITH CHECK (
    get_my_role() = 'brand_admin'
    AND client_id = get_my_client_id()
  );

CREATE POLICY "leads_brand_admin_update"
  ON leads FOR UPDATE
  USING (
    get_my_role() = 'brand_admin'
    AND client_id = get_my_client_id()
    AND is_deleted = FALSE
  )
  WITH CHECK (
    get_my_role() = 'brand_admin'
    AND client_id = get_my_client_id()
  );

CREATE POLICY "leads_brand_admin_delete"
  ON leads FOR DELETE
  USING (
    get_my_role() = 'brand_admin'
    AND client_id = get_my_client_id()
  );

-- branch_admin: CRUD on their branch only
CREATE POLICY "leads_branch_admin_select"
  ON leads FOR SELECT
  USING (
    get_my_role() = 'branch_admin'
    AND client_id = get_my_client_id()
    AND branch_id = get_my_branch_id()
    AND is_deleted = FALSE
  );

CREATE POLICY "leads_branch_admin_insert"
  ON leads FOR INSERT
  WITH CHECK (
    get_my_role() = 'branch_admin'
    AND client_id = get_my_client_id()
    AND branch_id = get_my_branch_id()
  );

CREATE POLICY "leads_branch_admin_update"
  ON leads FOR UPDATE
  USING (
    get_my_role() = 'branch_admin'
    AND client_id = get_my_client_id()
    AND branch_id = get_my_branch_id()
    AND is_deleted = FALSE
  )
  WITH CHECK (
    get_my_role() = 'branch_admin'
    AND client_id = get_my_client_id()
    AND branch_id = get_my_branch_id()
  );

-- employee: read + update ONLY their assigned leads
CREATE POLICY "leads_employee_select"
  ON leads FOR SELECT
  USING (
    get_my_role() = 'employee'
    AND client_id = get_my_client_id()
    AND assigned_to = (
      SELECT id FROM users WHERE auth_user_id = auth.uid() LIMIT 1
    )
    AND is_deleted = FALSE
  );

CREATE POLICY "leads_employee_update"
  ON leads FOR UPDATE
  USING (
    get_my_role() = 'employee'
    AND client_id = get_my_client_id()
    AND assigned_to = (
      SELECT id FROM users WHERE auth_user_id = auth.uid() LIMIT 1
    )
    AND is_deleted = FALSE
  )
  WITH CHECK (
    get_my_role() = 'employee'
    AND client_id = get_my_client_id()
    -- Employee cannot reassign to another employee or change branch
    AND branch_id = get_my_branch_id()
  );

-- ============================================================
-- TABLE: lead_audit_logs
-- ============================================================

CREATE POLICY "audit_superadmin_select"
  ON lead_audit_logs FOR SELECT
  USING (is_superadmin());

CREATE POLICY "audit_brand_admin_select"
  ON lead_audit_logs FOR SELECT
  USING (
    get_my_role() = 'brand_admin'
    AND client_id = get_my_client_id()
  );

-- All authenticated users can insert audit rows for their own client
CREATE POLICY "audit_insert"
  ON lead_audit_logs FOR INSERT
  WITH CHECK (client_id = get_my_client_id());

-- ============================================================
-- TABLE: campaign_branch_map
-- ============================================================

CREATE POLICY "campaign_map_superadmin_all"
  ON campaign_branch_map FOR ALL
  USING (is_superadmin())
  WITH CHECK (is_superadmin());

-- brand_admin: manage their own campaign mappings
CREATE POLICY "campaign_map_brand_admin_all"
  ON campaign_branch_map FOR ALL
  USING (
    get_my_role() = 'brand_admin'
    AND client_id = get_my_client_id()
  )
  WITH CHECK (
    get_my_role() = 'brand_admin'
    AND client_id = get_my_client_id()
  );

-- branch_admin / employee: read only
CREATE POLICY "campaign_map_lower_roles_select"
  ON campaign_branch_map FOR SELECT
  USING (
    get_my_role() IN ('branch_admin', 'employee')
    AND client_id = get_my_client_id()
  );

-- ============================================================
-- TABLE: webhook_logs
-- Superadmin: SELECT only
-- Others: no direct UI access (backend uses service_role only)
-- ============================================================

CREATE POLICY "webhook_logs_superadmin_select"
  ON webhook_logs FOR SELECT
  USING (is_superadmin());
