begin;
select plan(9);

insert into auth.users (
  id, instance_id, aud, role, email, encrypted_password,
  email_confirmed_at, created_at, updated_at
) values (
  '00000000-0000-4000-8000-000000000055',
  '00000000-0000-0000-0000-000000000000',
  'authenticated',
  'authenticated',
  'processing-guest@example.com',
  '',
  now(),
  now(),
  now()
);

select set_config('request.jwt.claim.role', 'service_role', true);

select is(
  (
    select operation
    from public.internal_create_processing_job(
      '00000000-0000-4000-8000-000000000055',
      'capture_grouping',
      '00000000-0000-4000-8000-000000000055',
      'capture-grouping-input-v1',
      'capture-grouping-result-v1',
      '2026-08-02',
      '[]'::jsonb
    )
  ),
  'capture_grouping',
  'guest processing creation returns the typed operation'
);

select is(
  (
    select id
    from public.internal_create_processing_job(
      '00000000-0000-4000-8000-000000000055',
      'capture_grouping',
      '00000000-0000-4000-8000-000000000055',
      'capture-grouping-input-v1',
      'capture-grouping-result-v1',
      '2026-08-02',
      '[]'::jsonb
    )
  ),
  (
    select id from public.processing_jobs
    where user_id = '00000000-0000-4000-8000-000000000055'
  ),
  'repeated creation returns the same job'
);

select is(
  (
    select count(*) from public.processing_jobs
    where user_id = '00000000-0000-4000-8000-000000000055'
  ),
  1::bigint,
  'idempotent creation stores one processing job'
);

select is(
  (
    select count(*) from public.ai_usage_records
    where user_id = '00000000-0000-4000-8000-000000000055'
  ),
  1::bigint,
  'idempotent creation atomically stores one usage record'
);

select is(
  (
    select count(*) from information_schema.columns
    where table_schema = 'public'
      and table_name = 'ai_usage_records'
      and column_name in (
        'input_payload', 'result_payload', 'prompt', 'filename', 'signed_url'
      )
  ),
  0::bigint,
  'usage records have no content-bearing columns'
);

select is(
  (
    select count(*) from cron.job
    where jobname = 'mymenu-cleanup-processing-jobs'
  ),
  1::bigint,
  'temporary processing cleanup is scheduled'
);

select ok(
  (
    select expires_at between now() + interval '23 hours 44 minutes'
      and now() + interval '23 hours 46 minutes'
    from public.processing_jobs
    where user_id = '00000000-0000-4000-8000-000000000055'
  ),
  'new jobs expire within 24 hours'
);

select is(
  has_function_privilege(
    'authenticated',
    'public.internal_create_processing_job(uuid,text,text,text,text,text,jsonb)',
    'execute'
  ),
  false,
  'clients cannot bypass the guest processing router'
);

set local role authenticated;
select set_config(
  'request.jwt.claim.sub',
  '00000000-0000-4000-8000-000000000055',
  true
);
select is(
  (select count(*) from public.processing_jobs),
  1::bigint,
  'a guest can read only its own content-free job status'
);

select * from finish();
rollback;
