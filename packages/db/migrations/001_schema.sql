-- ============================================================
-- LEADNX – STAGE 1: FULL SCHEMA MIGRATION
-- File: 001_schema.sql
-- Run this FIRST in Supabase SQL Editor
-- ============================================================

-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- ENUMS
-- ============================================================

CREATE TYPE user_role AS ENUM (
  'superadmin',
  'brand_admin',
  'branch_admin',
  'employee'
);

CREATE TYPE client_status AS ENUM (
  'active',
  'suspended',
  'cancelled',
  'trial'
);

CREATE TYPE lead_status AS ENUM (
  'new',
  'follow_up',
  'recce',
  'hot_lead',
  'closure',
  'dead'
);

CREATE TYPE subscription_status AS ENUM (
  'active',
  'cancelled',
  'past_due',
  'expired'
);

CREATE TYPE plan_type AS ENUM (
  'monthly',
  'yearly'
);

-- ============================================================
-- TABLE 1: clients
-- One row per onboarded business/brand
-- ============================================================

CREATE TABLE clients (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name                TEXT NOT NULL,
  email               TEXT NOT NULL UNIQUE,
  phone               TEXT,
  logo_url            TEXT,
  status              client_status NOT NULL DEFAULT 'trial',
  payment_failed_at   TIMESTAMPTZ,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- TABLE 2: subscriptions
-- Tracks Razorpay subscription per client
-- ============================================================

CREATE TABLE subscriptions (
  id                      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  client_id               UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  razorpay_subscription_id TEXT,
  plan_type               plan_type NOT NULL DEFAULT 'monthly',
  status                  subscription_status NOT NULL DEFAULT 'active',
  current_period_start    TIMESTAMPTZ,
  current_period_end      TIMESTAMPTZ,
  cancelled_at            TIMESTAMPTZ,
  created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- TABLE 3: branches
-- Physical or virtual branches under a client
-- ============================================================

CREATE TABLE branches (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  client_id   UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  name        TEXT NOT NULL,
  location    TEXT,
  is_active   BOOLEAN NOT NULL DEFAULT TRUE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- TABLE 4: users
-- All platform users (superadmin + client users)
-- ============================================================

CREATE TABLE users (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  auth_user_id  UUID UNIQUE,                          -- Supabase auth.users.id
  client_id     UUID REFERENCES clients(id),          -- NULL for superadmin
  branch_id     UUID REFERENCES branches(id),         -- NULL for brand_admin and above
  role          user_role NOT NULL,
  full_name     TEXT NOT NULL,
  email         TEXT NOT NULL UNIQUE,
  phone         TEXT,
  is_active     BOOLEAN NOT NULL DEFAULT TRUE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- TABLE 5: leads
-- Core CRM data — one row per lead
-- ============================================================

CREATE TABLE leads (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  lead_code       TEXT UNIQUE,                          -- Auto: LNDX-001, LNDX-002 ...
  client_id       UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  branch_id       UUID REFERENCES branches(id),
  assigned_to     UUID REFERENCES users(id),
  name            TEXT NOT NULL,
  phone           TEXT NOT NULL,
  email           TEXT,
  source          TEXT,                                 -- organic, google_ads, facebook, etc.
  campaign        TEXT,                                 -- campaign name (for FB mapping)
  cost            NUMERIC(12, 2) DEFAULT 0,
  revenue         NUMERIC(12, 2) DEFAULT 0,
  status          lead_status NOT NULL DEFAULT 'new',
  follow_up_date  DATE,
  remarks         TEXT,
  is_deleted      BOOLEAN NOT NULL DEFAULT FALSE,       -- Soft delete ONLY
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- TABLE 6: lead_audit_logs
-- Immutable trail of every change to a lead
-- ============================================================

CREATE TABLE lead_audit_logs (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  lead_id       UUID NOT NULL REFERENCES leads(id) ON DELETE CASCADE,
  client_id     UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  changed_by    UUID REFERENCES users(id),
  field_changed TEXT NOT NULL,                          -- 'status', 'remarks', 'assigned_to'
  old_value     TEXT,
  new_value     TEXT,
  changed_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- TABLE 7: campaign_branch_map
-- Maps Facebook campaign names to branches for auto-routing
-- ============================================================

CREATE TABLE campaign_branch_map (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  client_id     UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  branch_id     UUID NOT NULL REFERENCES branches(id) ON DELETE CASCADE,
  campaign_name TEXT NOT NULL,
  is_active     BOOLEAN NOT NULL DEFAULT TRUE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(client_id, campaign_name)                      -- One campaign → one branch per client
);

-- ============================================================
-- TABLE 8: webhook_logs
-- Stores raw Razorpay + Facebook payloads for debugging
-- ============================================================

CREATE TABLE webhook_logs (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  client_id     UUID REFERENCES clients(id),
  source        TEXT NOT NULL,                          -- 'razorpay' or 'facebook'
  event_type    TEXT,                                   -- e.g. 'subscription.activated'
  payload       JSONB NOT NULL,
  processed     BOOLEAN NOT NULL DEFAULT FALSE,
  error_message TEXT,
  received_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
