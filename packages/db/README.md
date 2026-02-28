# LeadNX Database

This folder contains all Supabase SQL migrations for the LeadNX project.

## Folder Structure

```
db/
├── migrations/
│   ├── 001_schema.sql     — All 8 tables + enums
│   ├── 002_indexes.sql    — 15 performance indexes
│   └── 003_triggers.sql   — lead_code auto-gen + updated_at triggers
├── rls/
│   └── 004_rls.sql        — Row Level Security policies (all 4 roles)
└── seed/
    └── 005_seed.sql       — Dev seed data (3 clients, 5 branches, 15 leads)
```

## Run Order

Always run in this exact order:

1. `001_schema.sql`
2. `002_indexes.sql`
3. `003_triggers.sql`
4. `004_rls.sql`
5. `005_seed.sql` *(dev only — never run in production)*

## Tables Created

| Table | Purpose |
|---|---|
| `clients` | One row per onboarded business |
| `subscriptions` | Razorpay subscription per client |
| `branches` | Physical/virtual branches under a client |
| `users` | All platform users (4 roles) |
| `leads` | Core CRM data |
| `lead_audit_logs` | Immutable change trail |
| `campaign_branch_map` | Facebook campaign → branch routing |
| `webhook_logs` | Raw webhook payload storage |

## Supabase Project

- URL: `https://rwrbizmdimjmwwrciern.supabase.co`
- Dashboard: https://supabase.com/dashboard/project/rwrbizmdimjmwwrciern/sql/new
