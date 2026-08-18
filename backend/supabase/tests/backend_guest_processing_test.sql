begin;
select plan(14);

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
      '[]'::jsonb,
      10,
      false
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
      '[]'::jsonb,
      10,
      false
    )
  ),
  (
    select id from public.processing_jobs
    where user_id = '00000000-0000-4000-8000-000000000055'
  ),
  'repeated creation returns the same job'
);

select throws_ok(
  $$
    select * from public.internal_create_processing_job(
      '00000000-0000-4000-8000-000000000055',
      'capture_grouping',
      '00000000-0000-4000-8000-000000000056',
      'capture-grouping-input-v1',
      'capture-grouping-result-v1',
      '2026-08-02',
      '[{"assetId":"not-a-uuid","contentType":"image/jpeg","byteSize":4}]'::jsonb,
      10,
      false
    )
  $$,
  'P0001',
  'Invalid processing asset manifest',
  'asset manifests require provider-compatible UUID identifiers'
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
    'public.internal_create_processing_job(uuid,text,text,text,text,text,jsonb,integer,boolean)',
    'execute'
  ),
  false,
  'clients cannot bypass the guest processing router'
);

select is(
  has_table_privilege(
    'authenticated',
    'public.processing_jobs',
    'select'
  ),
  false,
  'a guest cannot bypass the typed status route to read job payloads'
);

select throws_ok(
  $$
    select * from public.internal_submit_processing_job(
      '00000000-0000-4000-8000-000000000055',
      (select id from public.processing_jobs where user_id =
        '00000000-0000-4000-8000-000000000055'),
      '{"captures":[{"id":"bad","kind":"idea","ordinal":0}],"dishes":[]}'::jsonb
    )
  $$,
  'P0001',
  'Invalid capture grouping input',
  'typed submission rejects an incomplete idea capture'
);

select is(
  (
    select status::text from public.internal_submit_processing_job(
      '00000000-0000-4000-8000-000000000055',
      (select id from public.processing_jobs where user_id =
        '00000000-0000-4000-8000-000000000055'),
      '{"captures":[{"id":"00000000-0000-4000-8000-000000000057","kind":"idea","ordinal":0,"ideaText":"noodles"}],"dishes":[]}'::jsonb
    )
  ),
  'queued',
  'a complete typed idea capture can be submitted'
);

select is(
  (select attempt_count from public.internal_claim_processing_job()),
  1,
  'the first worker lease records one attempt'
);

update public.processing_jobs
set lease_expires_at = now() - interval '1 second'
where user_id = '00000000-0000-4000-8000-000000000055';

select is(
  (select attempt_count from public.internal_claim_processing_job()),
  2,
  'an expired worker lease is reclaimed with a bounded attempt count'
);

select * from finish();
rollback;
