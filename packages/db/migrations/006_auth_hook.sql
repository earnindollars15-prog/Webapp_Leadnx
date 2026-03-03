-- ============================================================
-- LEADNX – STAGE 2: CUSTOM ACCESS TOKEN HOOK
-- File: 006_auth_hook.sql
-- Run this in Supabase SQL Editor FIRST (before 007)
-- ============================================================
-- This function runs every time Supabase issues a JWT.
-- It injects role, client_id, branch_id, client_status
-- into user_metadata so RLS policies work correctly.
-- ============================================================

-- Step 1: Create the hook function
CREATE OR REPLACE FUNCTION public.custom_access_token_hook(event JSONB)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
  claims        JSONB;
  user_meta     JSONB;
  user_row      RECORD;
  v_client_status TEXT;
BEGIN
  -- Extract current claims from the event
  claims := event -> 'claims';

  -- Look up the user in public.users by their Supabase auth ID
  SELECT
    u.role::TEXT,
    u.client_id::TEXT,
    u.branch_id::TEXT,
    u.is_active
  INTO user_row
  FROM public.users u
  WHERE u.auth_user_id = (event ->> 'user_id')::UUID
  LIMIT 1;

  -- ⚠️ SECURITY: If user not found in public.users, BLOCK token issuance.
  -- A token without role/client_id metadata would break RLS unpredictably.
  -- NOTE: In PL/pgSQL, SELECT INTO with no rows does NOT set the record to NULL.
  -- It sets individual fields to NULL. We MUST use the FOUND variable instead.
  IF NOT FOUND THEN
    RAISE EXCEPTION 'User % not linked to public.users. Cannot issue token without role metadata.', (event ->> 'user_id');
  END IF;

  -- Look up client status (NULL for superadmin who has no client_id)
  IF user_row.client_id IS NOT NULL AND user_row.client_id != '' THEN
    SELECT c.status::TEXT
    INTO v_client_status
    FROM public.clients c
    WHERE c.id = user_row.client_id::UUID;
  ELSE
    v_client_status := NULL;
  END IF;

  -- Build the user_metadata object with exact keys RLS expects
  -- Keys: role, client_id, branch_id, client_status
  user_meta := jsonb_build_object(
    'role',          user_row.role,
    'client_id',     COALESCE(user_row.client_id, ''),
    'branch_id',     COALESCE(user_row.branch_id, ''),
    'client_status', COALESCE(v_client_status, '')
  );

  -- Merge into existing user_metadata (preserves any other fields)
  claims := jsonb_set(
    claims,
    '{user_metadata}',
    COALESCE(claims -> 'user_metadata', '{}'::JSONB) || user_meta
  );

  -- Update claims in the event and return
  event := jsonb_set(event, '{claims}', claims);

  RETURN event;
END;
$$;

-- Step 2: Grant execute permission to supabase_auth_admin
-- (Supabase Auth service calls this function internally)
GRANT USAGE ON SCHEMA public TO supabase_auth_admin;
GRANT EXECUTE ON FUNCTION public.custom_access_token_hook TO supabase_auth_admin;

-- Step 3: Revoke from public users (security)
REVOKE EXECUTE ON FUNCTION public.custom_access_token_hook FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.custom_access_token_hook FROM anon;
REVOKE EXECUTE ON FUNCTION public.custom_access_token_hook FROM authenticated;

-- ============================================================
-- ✅ DONE! Now do this in the Supabase Dashboard:
--
-- 1. Go to: Authentication (left sidebar)
-- 2. Click: Hooks (tab at top)
-- 3. Find: "Customize Access Token (JWT) Claims"
-- 4. Toggle it ON
-- 5. Select Schema: public
-- 6. Select Function: custom_access_token_hook
-- 7. Click: Save
--
-- ⚠️ If you skip this step, the hook won't run and
--     JWTs will NOT contain role/client_id/branch_id!
-- ============================================================
