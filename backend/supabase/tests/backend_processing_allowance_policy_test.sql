begin;

select plan(17);

insert into auth.users (
  id,
  instance_id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at,
  is_anonymous
) values (
  '00000000-0000-4000-8000-000000000401',
  '00000000-0000-0000-0000-000000000000',
  'authenticated',
  'authenticated',
  null,
  '',
  null,
  now(),
  now(),
  true
);

select is(
  has_function_privilege(
    'authenticated',
    'public.internal_create_processing_job(uuid,text,text,text,text,text,jsonb,integer,boolean)',
    'execute'
  ),
  false,
  'authenticated clients cannot pass allowance policy into job creation'
);

select is(
  has_function_privilege(
    'authenticated',
    'public.internal_get_processing_allowances(uuid,integer,boolean,integer,boolean)',
    'execute'
  ),
  false,
  'authenticated clients cannot pass allowance policy into status reads'
);

select set_config('request.jwt.claim.role', 'authenticated', true);

select throws_ok(
  $$
    select * from public.internal_get_processing_allowances(
      '00000000-0000-4000-8000-000000000401',
      10,
      false,
      10,
      false
    )
  $$,
  'P0001',
  'Service role required',
  'the database rejects direct authenticated allowance reads'
);

select set_config('request.jwt.claim.role', 'service_role', true);

select throws_ok(
  $$
    select * from public.internal_get_processing_allowances(
      '00000000-0000-4000-8000-000000000401',
      -1,
      false,
      10,
      false
    )
  $$,
  'P0001',
  'Invalid processing allowance policy',
  'negative limits are rejected'
);

select results_eq(
  $$
    select operation, status, enforcement_enabled, used_units,
      remaining_units, limit_units
    from public.internal_get_processing_allowances(
      '00000000-0000-4000-8000-000000000401',
      10,
      false,
      7,
      true
    )
    order by operation
  $$,
  $$ values
    ('capture_grouping', 'enforced', true, 0, 10, 10),
    ('cover_generation', 'enforcement_disabled', false, 0, null::integer, 7)
  $$,
  'organization and cover policies resolve independently'
);

insert into public.ai_usage_records (
  user_id,
  operation,
  units,
  outcome,
  idempotency_key
) values (
  '00000000-0000-4000-8000-000000000401',
  'capture_grouping',
  1,
  'succeeded',
  '00000000-0000-4000-8000-000000000410'
);

select results_eq(
  $$
    select status, used_units, remaining_units
    from public.internal_get_processing_allowances(
      '00000000-0000-4000-8000-000000000401',
      1,
      false,
      10,
      false
    )
    where operation = 'capture_grouping'
  $$,
  $$ values ('exhausted', 1, 0) $$,
  'the configured limit determines exhaustion'
);

select throws_ok(
  $$
    select * from public.internal_create_processing_job(
      '00000000-0000-4000-8000-000000000401',
      'capture_grouping',
      '00000000-0000-4000-8000-000000000411',
      'capture-grouping-input-v2',
      'capture-grouping-result-v2',
      '2026-08-04-cover-v1',
      '[]'::jsonb,
      1,
      false
    )
  $$,
  'P0001',
  'free_allowance_exhausted',
  'job creation enforces the supplied limit'
);

select is(
  (
    select operation from public.internal_create_processing_job(
      '00000000-0000-4000-8000-000000000401',
      'capture_grouping',
      '00000000-0000-4000-8000-000000000412',
      'capture-grouping-input-v2',
      'capture-grouping-result-v2',
      '2026-08-04-cover-v1',
      '[]'::jsonb,
      1,
      true
    )
  ),
  'capture_grouping',
  'a server-evaluated bypass permits job creation beyond the limit'
);

select is(
  (
    select count(*) from public.ai_usage_records
    where user_id = '00000000-0000-4000-8000-000000000401'
      and operation = 'capture_grouping'
  ),
  2::bigint,
  'bypassed work is still recorded in the usage ledger'
);

select is(
  (
    select id from public.internal_create_processing_job(
      '00000000-0000-4000-8000-000000000401',
      'capture_grouping',
      '00000000-0000-4000-8000-000000000412',
      'capture-grouping-input-v2',
      'capture-grouping-result-v2',
      '2026-08-04-cover-v1',
      '[]'::jsonb,
      1,
      false
    )
  ),
  (
    select id from public.processing_jobs
    where idempotency_key = '00000000-0000-4000-8000-000000000412'
  ),
  'an idempotent retry returns its existing job before rechecking allowance'
);

select is(
  (
    select count(*) from public.ai_usage_records
    where idempotency_key = '00000000-0000-4000-8000-000000000412'
  ),
  1::bigint,
  'an idempotent retry does not reserve another usage unit'
);

select results_eq(
  $$
    select status, enforcement_enabled, used_units, remaining_units, limit_units
    from public.internal_get_processing_allowances(
      '00000000-0000-4000-8000-000000000401',
      1,
      true,
      10,
      false
    )
    where operation = 'capture_grouping'
  $$,
  $$ values ('enforcement_disabled', false, 2, null::integer, 1) $$,
  'bypassed status keeps usage and configured limit visible'
);

select results_eq(
  $$
    select status, remaining_units
    from public.internal_get_processing_allowances(
      '00000000-0000-4000-8000-000000000401',
      0,
      false,
      10,
      false
    )
    where operation = 'capture_grouping'
  $$,
  $$ values ('exhausted', 0) $$,
  'a zero-unit policy safely denies new work'
);

select is(
  (
    select operation from public.internal_create_processing_job(
      '00000000-0000-4000-8000-000000000401',
      'cover_generation',
      '00000000-0000-4000-8000-000000000413',
      'cover-generation-input-v1',
      'cover-generation-result-v1',
      '2026-08-04-cover-v1',
      '[]'::jsonb,
      1,
      false
    )
  ),
  'cover_generation',
  'organization usage does not consume cover allowance'
);

select is(
  (
    select units from public.ai_usage_records
    where idempotency_key = '00000000-0000-4000-8000-000000000413'
  ),
  0,
  'cover generation continues to reserve before charging on acknowledgement'
);

select throws_ok(
  $$
    select * from public.internal_create_processing_job(
      '00000000-0000-4000-8000-000000000401',
      'cover_generation',
      '00000000-0000-4000-8000-000000000414',
      'cover-generation-input-v1',
      'cover-generation-result-v1',
      '2026-08-04-cover-v1',
      '[]'::jsonb,
      null,
      false
    )
  $$,
  'P0001',
  'Invalid processing allowance policy',
  'job creation rejects missing policy values'
);

select is(
  (
    select count(*)
    from information_schema.tables
    where table_schema = 'public'
      and table_name like 'server_feature_flag%'
  ),
  0::bigint,
  'Statsig policy does not create a duplicate database flag store'
);

select * from finish();
rollback;
