begin;

select plan(12);

insert into auth.users (
  id, instance_id, aud, role, email, encrypted_password,
  email_confirmed_at, created_at, updated_at, is_anonymous
) values
  (
    '00000000-0000-4000-8000-000000000101',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', null, '', null,
    now() - interval '100 days', now() - interval '100 days', true
  ),
  (
    '00000000-0000-4000-8000-000000000102',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', null, '', null,
    now() - interval '100 days', now() - interval '100 days', true
  ),
  (
    '00000000-0000-4000-8000-000000000103',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', null, '', null,
    now() - interval '100 days', now() - interval '100 days', true
  ),
  (
    '00000000-0000-4000-8000-000000000104',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'signed@example.com', '', now(),
    now() - interval '100 days', now() - interval '100 days', false
  );

insert into public.service_entitlements (user_id, plan_key, status)
values
  ('00000000-0000-4000-8000-000000000101', 'free', 'active'),
  ('00000000-0000-4000-8000-000000000104', 'pro', 'active');

insert into public.ai_usage_records (
  user_id, operation, units, outcome, idempotency_key, created_at, expires_at
) values
  (
    '00000000-0000-4000-8000-000000000101',
    'capture_grouping', 1, 'succeeded',
    '00000000-0000-4000-8000-000000000111',
    now() - interval '95 days', now() - interval '5 days'
  ),
  (
    '00000000-0000-4000-8000-000000000102',
    'capture_grouping', 1, 'succeeded',
    '00000000-0000-4000-8000-000000000112',
    now() - interval '1 day', now() + interval '89 days'
  );

insert into public.processing_jobs (
  id, user_id, operation, status, idempotency_key,
  input_schema_version, result_schema_version, privacy_notice_version
) values (
  '00000000-0000-4000-8000-000000000113',
  '00000000-0000-4000-8000-000000000103',
  'capture_grouping', 'created',
  '00000000-0000-4000-8000-000000000113',
  'capture-grouping-input-v2', 'capture-grouping-result-v2',
  '2026-08-04-cover-v1'
);

select set_config('request.jwt.claim.role', 'service_role', true);

select is(
  (
    select count(*)
    from public.internal_expire_inactive_guest_identities(
      now() - interval '90 days',
      100
    )
  ),
  1::bigint,
  'one inactive guest identity expires'
);

select is(
  (select count(*) from auth.users where id =
    '00000000-0000-4000-8000-000000000101'),
  0::bigint,
  'the inactive anonymous Auth identity is deleted'
);

select is(
  (select count(*) from public.service_entitlements where user_id =
    '00000000-0000-4000-8000-000000000101'),
  0::bigint,
  'the expired guest entitlement is deleted by ownership cascade'
);

select is(
  (select count(*) from public.ai_usage_records where user_id =
    '00000000-0000-4000-8000-000000000101'),
  0::bigint,
  'the expired guest detailed usage is deleted by ownership cascade'
);

select is(
  (select count(*) from auth.users where id =
    '00000000-0000-4000-8000-000000000102'),
  1::bigint,
  'recent processing keeps an old guest identity active'
);

select is(
  (select count(*) from auth.users where id =
    '00000000-0000-4000-8000-000000000103'),
  1::bigint,
  'an active processing job protects an inactive guest identity'
);

select is(
  (select count(*) from auth.users where id =
    '00000000-0000-4000-8000-000000000104'),
  1::bigint,
  'a signed account never expires through guest inactivity cleanup'
);

select is(
  (select plan_key from public.service_entitlements where user_id =
    '00000000-0000-4000-8000-000000000104'),
  'pro',
  'signed account entitlement remains intact'
);

select is(
  has_table_privilege('authenticated', 'public.service_entitlements', 'select'),
  false,
  'authenticated clients cannot read service entitlements directly'
);

select is(
  has_function_privilege(
    'authenticated',
    'public.internal_expire_inactive_guest_identities(timestamptz,integer)',
    'execute'
  ),
  false,
  'authenticated clients cannot expire service identities'
);

select set_config('request.jwt.claim.role', 'authenticated', true);

select throws_ok(
  $$
    select * from public.internal_expire_inactive_guest_identities(
      now() - interval '90 days',
      100
    )
  $$,
  'P0001',
  'Service role required',
  'the guest-expiry RPC enforces its service-only boundary'
);

select set_config('request.jwt.claim.role', 'service_role', true);

select is(
  (
    select count(*)
    from public.internal_expire_inactive_guest_identities(
      now() - interval '90 days',
      100
    )
  ),
  0::bigint,
  'repeated cleanup is idempotent and keeps protected identities'
);

select * from finish();
rollback;
