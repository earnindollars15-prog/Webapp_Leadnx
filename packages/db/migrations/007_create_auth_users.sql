-- ============================================================
-- LEADNX – STAGE 2: CREATE AUTH USERS FOR SEED DATA
-- File: 007_create_auth_users.sql
-- Run AFTER 006_auth_hook.sql AND enabling the hook in Dashboard
-- ============================================================
-- Creates Supabase Auth users for all 11 seed users
-- Password for ALL users: LeadNX@2025
-- Links each auth user to public.users via auth_user_id column
-- ============================================================

-- ============================================================
-- AUTH USER UUID MAP (deterministic for easy reference)
-- ============================================================
-- These UUIDs are for auth.users (different from public.users IDs)
-- Format: a0000000-0000-0000-0000-00000000XXXX
-- ============================================================

-- Use the supabase_auth_admin role to insert into auth.users
-- (Normal users cannot write to auth schema)

-- ============================================================
-- Step 1: Insert into auth.users
-- ============================================================

-- Password hash for "LeadNX@2025" using bcrypt
-- Generated via: SELECT crypt('LeadNX@2025', gen_salt('bf'));

DO $$
DECLARE
  password_hash TEXT;
  auth_uid_superadmin    UUID := 'a0000000-0000-0000-0000-000000000001';
  auth_uid_raj           UUID := 'a0000000-0000-0000-0000-000000000010';
  auth_uid_priya         UUID := 'a0000000-0000-0000-0000-000000000020';
  auth_uid_amit          UUID := 'a0000000-0000-0000-0000-000000000021';
  auth_uid_neha          UUID := 'a0000000-0000-0000-0000-000000000030';
  auth_uid_rohit         UUID := 'a0000000-0000-0000-0000-000000000031';
  auth_uid_sonia         UUID := 'a0000000-0000-0000-0000-000000000032';
  auth_uid_mark          UUID := 'a0000000-0000-0000-0000-000000000040';
  auth_uid_sunita        UUID := 'a0000000-0000-0000-0000-000000000050';
  auth_uid_karan         UUID := 'a0000000-0000-0000-0000-000000000051';
  auth_uid_maria         UUID := 'a0000000-0000-0000-0000-000000000060';
BEGIN
  -- Generate bcrypt hash for the shared password
  password_hash := crypt('LeadNX@2025', gen_salt('bf'));

  -- ============================================================
  -- Insert Auth Users (11 total)
  -- ============================================================

  -- 1. Superadmin
  INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password,
    email_confirmed_at, created_at, updated_at,
    confirmation_token, raw_app_meta_data, raw_user_meta_data
  ) VALUES (
    '00000000-0000-0000-0000-000000000000',
    auth_uid_superadmin, 'authenticated', 'authenticated',
    'superadmin@leadnx.com', password_hash,
    NOW(), NOW(), NOW(), '',
    '{"provider": "email", "providers": ["email"]}'::JSONB,
    '{"full_name": "John Doe (SuperAdmin)"}'::JSONB
  );

  -- 2. Raj (Alpha brand_admin)
  INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password,
    email_confirmed_at, created_at, updated_at,
    confirmation_token, raw_app_meta_data, raw_user_meta_data
  ) VALUES (
    '00000000-0000-0000-0000-000000000000',
    auth_uid_raj, 'authenticated', 'authenticated',
    'raj@alpha.com', password_hash,
    NOW(), NOW(), NOW(), '',
    '{"provider": "email", "providers": ["email"]}'::JSONB,
    '{"full_name": "Raj Sharma"}'::JSONB
  );

  -- 3. Priya (Alpha branch_admin, South Delhi)
  INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password,
    email_confirmed_at, created_at, updated_at,
    confirmation_token, raw_app_meta_data, raw_user_meta_data
  ) VALUES (
    '00000000-0000-0000-0000-000000000000',
    auth_uid_priya, 'authenticated', 'authenticated',
    'priya@alpha.com', password_hash,
    NOW(), NOW(), NOW(), '',
    '{"provider": "email", "providers": ["email"]}'::JSONB,
    '{"full_name": "Priya Singh"}'::JSONB
  );

  -- 4. Amit (Alpha branch_admin, Gurgaon)
  INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password,
    email_confirmed_at, created_at, updated_at,
    confirmation_token, raw_app_meta_data, raw_user_meta_data
  ) VALUES (
    '00000000-0000-0000-0000-000000000000',
    auth_uid_amit, 'authenticated', 'authenticated',
    'amit@alpha.com', password_hash,
    NOW(), NOW(), NOW(), '',
    '{"provider": "email", "providers": ["email"]}'::JSONB,
    '{"full_name": "Amit Verma"}'::JSONB
  );

  -- 5. Neha (Alpha employee, South Delhi)
  INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password,
    email_confirmed_at, created_at, updated_at,
    confirmation_token, raw_app_meta_data, raw_user_meta_data
  ) VALUES (
    '00000000-0000-0000-0000-000000000000',
    auth_uid_neha, 'authenticated', 'authenticated',
    'neha@alpha.com', password_hash,
    NOW(), NOW(), NOW(), '',
    '{"provider": "email", "providers": ["email"]}'::JSONB,
    '{"full_name": "Neha Gupta"}'::JSONB
  );

  -- 6. Rohit (Alpha employee, South Delhi)
  INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password,
    email_confirmed_at, created_at, updated_at,
    confirmation_token, raw_app_meta_data, raw_user_meta_data
  ) VALUES (
    '00000000-0000-0000-0000-000000000000',
    auth_uid_rohit, 'authenticated', 'authenticated',
    'rohit@alpha.com', password_hash,
    NOW(), NOW(), NOW(), '',
    '{"provider": "email", "providers": ["email"]}'::JSONB,
    '{"full_name": "Rohit Kumar"}'::JSONB
  );

  -- 7. Sonia (Alpha employee, Gurgaon)
  INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password,
    email_confirmed_at, created_at, updated_at,
    confirmation_token, raw_app_meta_data, raw_user_meta_data
  ) VALUES (
    '00000000-0000-0000-0000-000000000000',
    auth_uid_sonia, 'authenticated', 'authenticated',
    'sonia@alpha.com', password_hash,
    NOW(), NOW(), NOW(), '',
    '{"provider": "email", "providers": ["email"]}'::JSONB,
    '{"full_name": "Sonia Mehta"}'::JSONB
  );

  -- 8. Mark (Beta brand_admin)
  INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password,
    email_confirmed_at, created_at, updated_at,
    confirmation_token, raw_app_meta_data, raw_user_meta_data
  ) VALUES (
    '00000000-0000-0000-0000-000000000000',
    auth_uid_mark, 'authenticated', 'authenticated',
    'mark@beta.com', password_hash,
    NOW(), NOW(), NOW(), '',
    '{"provider": "email", "providers": ["email"]}'::JSONB,
    '{"full_name": "Mark Spencer"}'::JSONB
  );

  -- 9. Sunita (Beta employee, Noida)
  INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password,
    email_confirmed_at, created_at, updated_at,
    confirmation_token, raw_app_meta_data, raw_user_meta_data
  ) VALUES (
    '00000000-0000-0000-0000-000000000000',
    auth_uid_sunita, 'authenticated', 'authenticated',
    'sunita@beta.com', password_hash,
    NOW(), NOW(), NOW(), '',
    '{"provider": "email", "providers": ["email"]}'::JSONB,
    '{"full_name": "Sunita Joshi"}'::JSONB
  );

  -- 10. Karan (Beta employee, Pitampura)
  INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password,
    email_confirmed_at, created_at, updated_at,
    confirmation_token, raw_app_meta_data, raw_user_meta_data
  ) VALUES (
    '00000000-0000-0000-0000-000000000000',
    auth_uid_karan, 'authenticated', 'authenticated',
    'karan@beta.com', password_hash,
    NOW(), NOW(), NOW(), '',
    '{"provider": "email", "providers": ["email"]}'::JSONB,
    '{"full_name": "Karan Nair"}'::JSONB
  );

  -- 11. Maria (Gamma brand_admin — SUSPENDED client)
  INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password,
    email_confirmed_at, created_at, updated_at,
    confirmation_token, raw_app_meta_data, raw_user_meta_data
  ) VALUES (
    '00000000-0000-0000-0000-000000000000',
    auth_uid_maria, 'authenticated', 'authenticated',
    'maria@gamma.com', password_hash,
    NOW(), NOW(), NOW(), '',
    '{"provider": "email", "providers": ["email"]}'::JSONB,
    '{"full_name": "Maria Garcia"}'::JSONB
  );

  -- ============================================================
  -- Step 2: Create identities for each user (required by Supabase)
  -- ============================================================

  INSERT INTO auth.identities (id, user_id, provider_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
  VALUES
    (auth_uid_superadmin, auth_uid_superadmin, 'superadmin@leadnx.com', jsonb_build_object('sub', auth_uid_superadmin, 'email', 'superadmin@leadnx.com'), 'email', NOW(), NOW(), NOW()),
    (auth_uid_raj,        auth_uid_raj,        'raj@alpha.com',         jsonb_build_object('sub', auth_uid_raj,        'email', 'raj@alpha.com'),         'email', NOW(), NOW(), NOW()),
    (auth_uid_priya,      auth_uid_priya,      'priya@alpha.com',       jsonb_build_object('sub', auth_uid_priya,      'email', 'priya@alpha.com'),       'email', NOW(), NOW(), NOW()),
    (auth_uid_amit,       auth_uid_amit,       'amit@alpha.com',        jsonb_build_object('sub', auth_uid_amit,       'email', 'amit@alpha.com'),        'email', NOW(), NOW(), NOW()),
    (auth_uid_neha,       auth_uid_neha,       'neha@alpha.com',        jsonb_build_object('sub', auth_uid_neha,       'email', 'neha@alpha.com'),        'email', NOW(), NOW(), NOW()),
    (auth_uid_rohit,      auth_uid_rohit,      'rohit@alpha.com',       jsonb_build_object('sub', auth_uid_rohit,      'email', 'rohit@alpha.com'),       'email', NOW(), NOW(), NOW()),
    (auth_uid_sonia,      auth_uid_sonia,      'sonia@alpha.com',       jsonb_build_object('sub', auth_uid_sonia,      'email', 'sonia@alpha.com'),       'email', NOW(), NOW(), NOW()),
    (auth_uid_mark,       auth_uid_mark,       'mark@beta.com',         jsonb_build_object('sub', auth_uid_mark,       'email', 'mark@beta.com'),         'email', NOW(), NOW(), NOW()),
    (auth_uid_sunita,     auth_uid_sunita,     'sunita@beta.com',       jsonb_build_object('sub', auth_uid_sunita,     'email', 'sunita@beta.com'),       'email', NOW(), NOW(), NOW()),
    (auth_uid_karan,      auth_uid_karan,      'karan@beta.com',        jsonb_build_object('sub', auth_uid_karan,      'email', 'karan@beta.com'),        'email', NOW(), NOW(), NOW()),
    (auth_uid_maria,      auth_uid_maria,      'maria@gamma.com',       jsonb_build_object('sub', auth_uid_maria,      'email', 'maria@gamma.com'),       'email', NOW(), NOW(), NOW());

  -- ============================================================
  -- Step 3: Link auth users to public.users (set auth_user_id)
  -- ============================================================

  UPDATE public.users SET auth_user_id = auth_uid_superadmin WHERE email = 'superadmin@leadnx.com';
  UPDATE public.users SET auth_user_id = auth_uid_raj        WHERE email = 'raj@alpha.com';
  UPDATE public.users SET auth_user_id = auth_uid_priya      WHERE email = 'priya@alpha.com';
  UPDATE public.users SET auth_user_id = auth_uid_amit       WHERE email = 'amit@alpha.com';
  UPDATE public.users SET auth_user_id = auth_uid_neha       WHERE email = 'neha@alpha.com';
  UPDATE public.users SET auth_user_id = auth_uid_rohit      WHERE email = 'rohit@alpha.com';
  UPDATE public.users SET auth_user_id = auth_uid_sonia      WHERE email = 'sonia@alpha.com';
  UPDATE public.users SET auth_user_id = auth_uid_mark       WHERE email = 'mark@beta.com';
  UPDATE public.users SET auth_user_id = auth_uid_sunita     WHERE email = 'sunita@beta.com';
  UPDATE public.users SET auth_user_id = auth_uid_karan      WHERE email = 'karan@beta.com';
  UPDATE public.users SET auth_user_id = auth_uid_maria      WHERE email = 'maria@gamma.com';

  RAISE NOTICE '✅ All 11 auth users created and linked to public.users';
END;
$$;

-- ============================================================
-- ✅ VERIFICATION: Run this query to confirm linking worked
-- ============================================================
-- SELECT u.email, u.role, u.auth_user_id, u.client_id, u.branch_id
-- FROM public.users u
-- ORDER BY u.role, u.email;
--
-- Expected: All 11 rows should have auth_user_id populated
-- ============================================================
