-- ============================================================
-- LEADNX – STAGE 1: PERFORMANCE INDEXES
-- File: 002_indexes.sql
-- Run AFTER 001_schema.sql
-- ============================================================

-- leads: most queried table — client isolation (most important)
CREATE INDEX idx_leads_client_id              ON leads(client_id);

-- leads: filter by status (second most common filter)
CREATE INDEX idx_leads_client_status          ON leads(client_id, status);

-- leads: branch-level isolation
CREATE INDEX idx_leads_branch_id              ON leads(branch_id);

-- leads: employee-level isolation
CREATE INDEX idx_leads_assigned_to            ON leads(assigned_to);

-- leads: soft delete filter (always applied)
CREATE INDEX idx_leads_is_deleted             ON leads(is_deleted);

-- leads: follow-up date sorting/filtering
CREATE INDEX idx_leads_follow_up_date         ON leads(follow_up_date);

-- leads: phone for duplicate check (UNIQUE not enforced, check done in code)
CREATE INDEX idx_leads_client_phone           ON leads(client_id, phone);

-- branches: client isolation
CREATE INDEX idx_branches_client_id           ON branches(client_id);

-- users: client isolation
CREATE INDEX idx_users_client_id              ON users(client_id);

-- users: auth lookup
CREATE INDEX idx_users_auth_user_id           ON users(auth_user_id);

-- subscriptions: client lookup
CREATE INDEX idx_subscriptions_client_id      ON subscriptions(client_id);

-- lead_audit_logs: lead history
CREATE INDEX idx_audit_lead_id               ON lead_audit_logs(lead_id);

-- lead_audit_logs: client-level audit
CREATE INDEX idx_audit_client_id             ON lead_audit_logs(client_id);

-- campaign_branch_map: lookup by campaign name within a client
CREATE INDEX idx_campaign_map_client          ON campaign_branch_map(client_id, campaign_name);

-- webhook_logs: unprocessed jobs
CREATE INDEX idx_webhook_logs_processed       ON webhook_logs(processed);

-- leads: DASHBOARD OPTIMIZATION — composite partial index
-- Covers: branch performance queries, status breakdowns, analytics aggregations
-- WHERE is_deleted = FALSE means the index only covers active leads (smaller, faster)
CREATE INDEX idx_leads_client_branch_status
  ON leads(client_id, branch_id, status)
  WHERE is_deleted = FALSE;
