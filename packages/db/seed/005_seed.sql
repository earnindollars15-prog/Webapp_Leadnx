-- ============================================================
-- LEADNX – STAGE 1: SEED DATA
-- File: 005_seed.sql
-- Run AFTER 004_rls.sql
-- ⚠️ FOR DEVELOPMENT & TESTING ONLY — not for production
-- ============================================================

-- ============================================================
-- SEED: 3 Clients
-- ============================================================

INSERT INTO clients (id, name, email, phone, status) VALUES
  ('11111111-1111-1111-1111-111111111111', 'Alpha Real Estate',    'admin@alpha.com',  '9800000001', 'active'),
  ('22222222-2222-2222-2222-222222222222', 'Beta Auto Group',      'admin@beta.com',   '9800000002', 'active'),
  ('33333333-3333-3333-3333-333333333333', 'Gamma Education Ltd',  'admin@gamma.com',  '9800000003', 'suspended');

-- ============================================================
-- SEED: 5 Branches (2 for Alpha, 2 for Beta, 1 for Gamma)
-- ============================================================

INSERT INTO branches (id, client_id, name, location) VALUES
  ('aaaa0001-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', 'Alpha South Delhi',  'South Delhi'),
  ('aaaa0002-0000-0000-0000-000000000002', '11111111-1111-1111-1111-111111111111', 'Alpha Gurgaon',      'Gurgaon'),
  ('bbbb0001-0000-0000-0000-000000000001', '22222222-2222-2222-2222-222222222222', 'Beta Noida',         'Noida'),
  ('bbbb0002-0000-0000-0000-000000000002', '22222222-2222-2222-2222-222222222222', 'Beta Pitampura',     'Pitampura'),
  ('cccc0001-0000-0000-0000-000000000001', '33333333-3333-3333-3333-333333333333', 'Gamma Main',         'Connaught Place');

-- ============================================================
-- SEED: Users
-- (auth_user_id is NULL here — set when Supabase Auth users are created)
-- ============================================================

INSERT INTO users (id, client_id, branch_id, role, full_name, email, phone) VALUES
  -- Superadmin (no client_id)
  ('user-sa-01', NULL, NULL, 'superadmin', 'John Doe (SuperAdmin)', 'superadmin@leadnx.com', '9900000000'),

  -- Alpha brand_admin
  ('user-ba-01', '11111111-1111-1111-1111-111111111111', NULL, 'brand_admin', 'Raj Sharma', 'raj@alpha.com', '9800000101'),

  -- Alpha branch admins
  ('user-bra-01', '11111111-1111-1111-1111-111111111111', 'aaaa0001-0000-0000-0000-000000000001', 'branch_admin', 'Priya Singh', 'priya@alpha.com', '9800000102'),
  ('user-bra-02', '11111111-1111-1111-1111-111111111111', 'aaaa0002-0000-0000-0000-000000000002', 'branch_admin', 'Amit Verma', 'amit@alpha.com', '9800000103'),

  -- Alpha employees
  ('user-emp-01', '11111111-1111-1111-1111-111111111111', 'aaaa0001-0000-0000-0000-000000000001', 'employee', 'Neha Gupta',   'neha@alpha.com',   '9800000201'),
  ('user-emp-02', '11111111-1111-1111-1111-111111111111', 'aaaa0001-0000-0000-0000-000000000001', 'employee', 'Rohit Kumar',  'rohit@alpha.com',  '9800000202'),
  ('user-emp-03', '11111111-1111-1111-1111-111111111111', 'aaaa0002-0000-0000-0000-000000000002', 'employee', 'Sonia Mehta',  'sonia@alpha.com',  '9800000203'),

  -- Beta brand_admin
  ('user-ba-02', '22222222-2222-2222-2222-222222222222', NULL, 'brand_admin', 'Mark Spencer', 'mark@beta.com', '9800000301'),

  -- Beta employees
  ('user-emp-04', '22222222-2222-2222-2222-222222222222', 'bbbb0001-0000-0000-0000-000000000001', 'employee', 'Sunita Joshi', 'sunita@beta.com', '9800000401'),
  ('user-emp-05', '22222222-2222-2222-2222-222222222222', 'bbbb0002-0000-0000-0000-000000000002', 'employee', 'Karan Nair',   'karan@beta.com',  '9800000402'),

  -- Gamma brand_admin (suspended client)
  ('user-ba-03', '33333333-3333-3333-3333-333333333333', NULL, 'brand_admin', 'Maria Garcia', 'maria@gamma.com', '9800000501');

-- ============================================================
-- SEED: Campaign → Branch mappings (for Facebook webhook test)
-- ============================================================

INSERT INTO campaign_branch_map (client_id, branch_id, campaign_name) VALUES
  ('11111111-1111-1111-1111-111111111111', 'aaaa0001-0000-0000-0000-000000000001', 'Summer Offer'),
  ('11111111-1111-1111-1111-111111111111', 'aaaa0001-0000-0000-0000-000000000001', 'SEO Campaign'),
  ('11111111-1111-1111-1111-111111111111', 'aaaa0002-0000-0000-0000-000000000002', 'Facebook Ads'),
  ('22222222-2222-2222-2222-222222222222', 'bbbb0001-0000-0000-0000-000000000001', 'Google Ads'),
  ('22222222-2222-2222-2222-222222222222', 'bbbb0002-0000-0000-0000-000000000002', 'WhatsApp Campaign');

-- ============================================================
-- SEED: 50 Sample Leads (for Alpha client)
-- (For full 10,000 leads test, run the bulk generator below)
-- ============================================================

INSERT INTO leads (client_id, branch_id, assigned_to, name, phone, source, campaign, cost, revenue, status, remarks) VALUES
  ('11111111-1111-1111-1111-111111111111', 'aaaa0001-0000-0000-0000-000000000001', 'user-emp-01', 'Aakash Jain',     '8800000001', 'facebook',   'Summer Offer',  400, 2500, 'new',       'Interested in 2BHK'),
  ('11111111-1111-1111-1111-111111111111', 'aaaa0001-0000-0000-0000-000000000001', 'user-emp-01', 'Bina Sharma',     '8800000002', 'google',     'SEO Campaign',  350, 0,    'follow_up', 'Called twice, no pickup'),
  ('11111111-1111-1111-1111-111111111111', 'aaaa0001-0000-0000-0000-000000000001', 'user-emp-02', 'Chetan Yadav',    '8800000003', 'organic',    NULL,            0,   0,    'recce',     'Site visit scheduled'),
  ('11111111-1111-1111-1111-111111111111', 'aaaa0001-0000-0000-0000-000000000001', 'user-emp-02', 'Divya Patel',     '8800000004', 'facebook',   'Summer Offer',  400, 0,    'hot_lead',  'Very interested, budget confirmed'),
  ('11111111-1111-1111-1111-111111111111', 'aaaa0001-0000-0000-0000-000000000001', 'user-emp-01', 'Esha Kapoor',     '8800000005', 'google',     'SEO Campaign',  350, 5000, 'closure',   'Booked 3BHK flat'),
  ('11111111-1111-1111-1111-111111111111', 'aaaa0001-0000-0000-0000-000000000001', 'user-emp-02', 'Farhan Khan',     '8800000006', 'facebook',   'Facebook Ads',  500, 0,    'dead',      'Not interested anymore'),
  ('11111111-1111-1111-1111-111111111111', 'aaaa0001-0000-0000-0000-000000000001', 'user-emp-01', 'Geeta Mishra',    '8800000007', 'organic',    NULL,            0,   0,    'new',       NULL),
  ('11111111-1111-1111-1111-111111111111', 'aaaa0002-0000-0000-0000-000000000002', 'user-emp-03', 'Harsh Tiwari',    '8800000008', 'facebook',   'Facebook Ads',  500, 0,    'follow_up', 'Wants Friday callback'),
  ('11111111-1111-1111-1111-111111111111', 'aaaa0002-0000-0000-0000-000000000002', 'user-emp-03', 'Isha Bansal',     '8800000009', 'google',     'SEO Campaign',  350, 3000,'hot_lead',   'Budget 40L confirmed'),
  ('11111111-1111-1111-1111-111111111111', 'aaaa0002-0000-0000-0000-000000000002', 'user-emp-03', 'Jaideep Nair',    '8800000010', 'organic',    NULL,            0,   0,    'dead',      'Moved to another city'),
  -- Beta leads
  ('22222222-2222-2222-2222-222222222222', 'bbbb0001-0000-0000-0000-000000000001', 'user-emp-04', 'Kavita Rawat',    '8800000011', 'google',     'Google Ads',    300, 0,    'new',       NULL),
  ('22222222-2222-2222-2222-222222222222', 'bbbb0001-0000-0000-0000-000000000001', 'user-emp-04', 'Lalit Saxena',    '8800000012', 'facebook',   'Google Ads',    300, 8000,'closure',   'Car booked'),
  ('22222222-2222-2222-2222-222222222222', 'bbbb0002-0000-0000-0000-000000000002', 'user-emp-05', 'Meena Dubey',     '8800000013', 'organic',    NULL,            0,   0,    'follow_up', 'Test drive pending'),
  ('22222222-2222-2222-2222-222222222222', 'bbbb0002-0000-0000-0000-000000000002', 'user-emp-05', 'Naveen Choudhary','8800000014', 'whatsapp',   'WhatsApp Campaign', 200, 0, 'recce',  'Visited showroom'),
  ('22222222-2222-2222-2222-222222222222', 'bbbb0002-0000-0000-0000-000000000002', 'user-emp-05', 'Ojaswi Thakur',   '8800000015', 'google',     'Google Ads',    300, 0,    'dead',      'Budget mismatch');

-- ============================================================
-- BULK SEED GENERATOR: 10,000 leads for performance testing
-- Uncomment and run separately if needed
-- ============================================================

/*
INSERT INTO leads (client_id, branch_id, assigned_to, name, phone, source, status, cost)
SELECT
  '11111111-1111-1111-1111-111111111111',
  CASE WHEN random() > 0.5
    THEN 'aaaa0001-0000-0000-0000-000000000001'::UUID
    ELSE 'aaaa0002-0000-0000-0000-000000000002'::UUID
  END,
  CASE WHEN random() > 0.5 THEN 'user-emp-01' ELSE 'user-emp-02' END,
  'Test Lead ' || i,
  '7' || LPAD((floor(random() * 999999999)::BIGINT)::TEXT, 9, '0'),
  (ARRAY['facebook', 'google', 'organic', 'referral'])[floor(random() * 4 + 1)],
  (ARRAY['new', 'follow_up', 'recce', 'hot_lead', 'closure', 'dead']::lead_status[])[floor(random() * 6 + 1)],
  floor(random() * 1000)
FROM generate_series(1, 10000) i;
*/
