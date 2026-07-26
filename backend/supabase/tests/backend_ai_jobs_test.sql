BEGIN;
SELECT plan(33);

INSERT INTO auth.users (
  id,
  instance_id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at
)
VALUES
  (
    '00000000-0000-4000-8000-000000000201',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'ai-one@example.com',
    '',
    now(),
    now(),
    now()
  ),
  (
    '00000000-0000-4000-8000-000000000202',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'ai-two@example.com',
    '',
    now(),
    now(),
    now()
  )
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.ai_jobs (
  id,
  user_id,
  job_type,
  subject_id,
  status,
  idempotency_key,
  input_hash,
  input_version
)
VALUES (
  '50000000-0000-4000-8000-000000000202',
  '00000000-0000-4000-8000-000000000202',
  'batch_grouping',
  '60000000-0000-4000-8000-000000000202',
  'canceled',
  'other-user-key',
  'other-user-hash',
  '1'
);

SET LOCAL ROLE authenticated;
SELECT set_config(
  'request.jwt.claim.sub',
  '00000000-0000-4000-8000-000000000201',
  true
);

SELECT is(
  (
    SELECT id
    FROM public.api_schedule_ai_job(
      '50000000-0000-4000-8000-000000000201',
      'batch_grouping',
      '60000000-0000-4000-8000-000000000201',
      'batch_grouping:60000000-0000-4000-8000-000000000201:1',
      'hash-201',
      '1'
    )
  ),
  '50000000-0000-4000-8000-000000000201'::uuid,
  'authenticated scheduling preserves the locally generated job id'
);

SELECT is(
  (
    SELECT id
    FROM public.api_schedule_ai_job(
      '50000000-0000-4000-8000-000000000299',
      'batch_grouping',
      '60000000-0000-4000-8000-000000000201',
      'batch_grouping:60000000-0000-4000-8000-000000000201:1',
      'hash-201',
      '1'
    )
  ),
  '50000000-0000-4000-8000-000000000201'::uuid,
  'repeated scheduling returns the active job'
);

SELECT is(
  (
    SELECT count(*)
    FROM public.ai_jobs
    WHERE user_id = '00000000-0000-4000-8000-000000000201'
      AND idempotency_key =
        'batch_grouping:60000000-0000-4000-8000-000000000201:1'
      AND status in ('queued', 'running', 'retrying')
  ),
  1::bigint,
  'repeated scheduling creates exactly one active backend job'
);

SELECT is(
  (SELECT count(*) FROM public.ai_jobs),
  1::bigint,
  'RLS hides another user job'
);

SELECT is(
  (
    SELECT count(*)
    FROM public.api_get_ai_jobs(
      ARRAY['50000000-0000-4000-8000-000000000202'::uuid]
    )
  ),
  0::bigint,
  'status API cannot read another user job'
);

SELECT is(
  has_function_privilege(
    'authenticated',
    'public.api_schedule_ai_job(uuid,public.ai_job_type,uuid,text,text,text,text,text,text,integer)',
    'EXECUTE'
  ),
  true,
  'authenticated clients can schedule jobs'
);

SELECT is(
  has_function_privilege(
    'authenticated',
    'public.internal_claim_ai_job(public.ai_job_type[])',
    'EXECUTE'
  ),
  false,
  'authenticated clients cannot claim worker jobs'
);

SELECT is(
  has_function_privilege(
    'service_role',
    'public.internal_claim_ai_job(public.ai_job_type[])',
    'EXECUTE'
  ),
  true,
  'service workers can claim jobs'
);

SELECT ok(
  position(
    'for update skip locked' in lower(
      pg_get_functiondef(
        'public.internal_claim_ai_job(public.ai_job_type[])'::regprocedure
      )
    )
  ) > 0,
  'claim contract uses skip-locked concurrency control'
);

RESET ROLE;

SELECT is(
  (
    SELECT status::text
    FROM public.internal_claim_ai_job(
      ARRAY['batch_grouping'::public.ai_job_type]
    )
  ),
  'running',
  'worker claim transitions a queued job to running'
);

SELECT is(
  (
    SELECT attempt_count
    FROM public.ai_jobs
    WHERE id = '50000000-0000-4000-8000-000000000201'
  ),
  1,
  'claim persists the attempt count'
);

SELECT is(
  (
    SELECT status::text
    FROM public.internal_fail_ai_job(
      '50000000-0000-4000-8000-000000000201',
      (
        SELECT lease_token
        FROM public.ai_jobs
        WHERE id = '50000000-0000-4000-8000-000000000201'
      ),
      true,
      '{"code":"provider_timeout"}'::jsonb
    )
  ),
  'retrying',
  'retryable worker failure enters retrying state'
);

SELECT isnt(
  (
    SELECT next_retry_at
    FROM public.ai_jobs
    WHERE id = '50000000-0000-4000-8000-000000000201'
  ),
  null::timestamptz,
  'retryable failure persists the next retry time'
);

SELECT is(
  (
    SELECT normalized_error ->> 'code'
    FROM public.ai_jobs
    WHERE id = '50000000-0000-4000-8000-000000000201'
  ),
  'provider_timeout',
  'retryable failure stores a normalized error'
);

UPDATE public.ai_jobs
SET next_retry_at = now() - interval '1 second'
WHERE id = '50000000-0000-4000-8000-000000000201';

SELECT is(
  (
    SELECT attempt_count
    FROM public.internal_claim_ai_job(null)
  ),
  2,
  'retrying job is claimed for its next bounded attempt'
);

SELECT is(
  (
    SELECT status::text
    FROM public.internal_complete_ai_job(
      '50000000-0000-4000-8000-000000000201',
      (
        SELECT lease_token
        FROM public.ai_jobs
        WHERE id = '50000000-0000-4000-8000-000000000201'
      ),
      '{"groups":["dish-a"]}'::jsonb
    )
  ),
  'succeeded',
  'worker completion persists success'
);

SELECT is(
  (
    SELECT normalized_result -> 'groups' ->> 0
    FROM public.ai_jobs
    WHERE id = '50000000-0000-4000-8000-000000000201'
  ),
  'dish-a',
  'worker completion stores a normalized result'
);

INSERT INTO public.ai_jobs (
  id,
  user_id,
  job_type,
  subject_id,
  idempotency_key,
  input_hash,
  input_version,
  max_attempts
)
VALUES (
  '50000000-0000-4000-8000-000000000203',
  '00000000-0000-4000-8000-000000000201',
  'recipe_enrichment',
  '60000000-0000-4000-8000-000000000203',
  'recipe:terminal',
  'terminal-hash',
  '1',
  1
);

SELECT is(
  (
    SELECT attempt_count
    FROM public.internal_claim_ai_job(
      ARRAY['recipe_enrichment'::public.ai_job_type]
    )
  ),
  1,
  'terminal-failure fixture is claimed once'
);

SELECT is(
  (
    SELECT status::text
    FROM public.internal_fail_ai_job(
      '50000000-0000-4000-8000-000000000203',
      (
        SELECT lease_token
        FROM public.ai_jobs
        WHERE id = '50000000-0000-4000-8000-000000000203'
      ),
      true,
      '{"code":"invalid_output"}'::jsonb
    )
  ),
  'failed',
  'failure becomes terminal when attempts are exhausted'
);

SELECT is(
  (
    SELECT next_retry_at
    FROM public.ai_jobs
    WHERE id = '50000000-0000-4000-8000-000000000203'
  ),
  null::timestamptz,
  'terminal failure has no automatic retry time'
);

SET LOCAL ROLE authenticated;
SELECT set_config(
  'request.jwt.claim.sub',
  '00000000-0000-4000-8000-000000000201',
  true
);

SELECT is(
  (
    SELECT status::text
    FROM public.api_retry_ai_job(
      '50000000-0000-4000-8000-000000000203'
    )
  ),
  'queued',
  'user can explicitly retry a terminal failure'
);

SELECT is(
  (
    SELECT max_attempts
    FROM public.ai_jobs
    WHERE id = '50000000-0000-4000-8000-000000000203'
  ),
  2,
  'explicit retry extends the bounded attempt allowance once'
);

SELECT is(
  (
    SELECT status::text
    FROM public.api_cancel_ai_job(
      '50000000-0000-4000-8000-000000000203'
    )
  ),
  'canceled',
  'queued job can be canceled'
);

SELECT throws_ok(
  $$
    SELECT *
    FROM public.api_cancel_ai_job(
      '50000000-0000-4000-8000-000000000201'
    )
  $$,
  'AI job 50000000-0000-4000-8000-000000000201 cannot be canceled',
  'completed jobs cannot be canceled'
);

RESET ROLE;

SELECT is(
  (
    SELECT count(*)
    FROM public.sync_events
    WHERE entity_type = 'ai_job'
      AND entity_id = '50000000-0000-4000-8000-000000000201'
  ),
  5::bigint,
  'queued, running, retrying, running, and success emit sync events'
);

SELECT is(
  (
    SELECT operation
    FROM public.sync_events
    WHERE entity_type = 'ai_job'
      AND entity_id = '50000000-0000-4000-8000-000000000203'
    ORDER BY id DESC
    LIMIT 1
  ),
  'canceled',
  'cancel emits a user-visible sync event'
);

SELECT is(
  (
    SELECT count(*)
    FROM unnest(enum_range(null::public.ai_job_type))
  ),
  4::bigint,
  'all four initial job types are supported'
);

INSERT INTO public.ai_jobs (
  id,
  user_id,
  job_type,
  subject_id,
  status,
  idempotency_key,
  input_hash,
  input_version,
  attempt_count,
  max_attempts,
  lease_token,
  lease_expires_at
)
VALUES (
  '50000000-0000-4000-8000-000000000204',
  '00000000-0000-4000-8000-000000000201',
  'recipe_enrichment',
  '60000000-0000-4000-8000-000000000204',
  'running',
  'recipe:expired-lease',
  'expired-hash',
  '1',
  1,
  2,
  '70000000-0000-4000-8000-000000000204',
  now() - interval '1 second'
);

SELECT is(
  (
    SELECT status::text
    FROM public.internal_claim_ai_job(
      ARRAY['recipe_enrichment'::public.ai_job_type]
    )
  ),
  'running',
  'an expired worker lease is recovered and reclaimed'
);

SELECT is(
  (
    SELECT attempt_count
    FROM public.ai_jobs
    WHERE id = '50000000-0000-4000-8000-000000000204'
  ),
  2,
  'lease recovery consumes the next bounded attempt'
);

SELECT is(
  (
    SELECT count(*)
    FROM public.sync_events
    WHERE entity_type = 'ai_job'
      AND entity_id = '50000000-0000-4000-8000-000000000204'
      AND operation = 'retrying'
  ),
  1::bigint,
  'lease recovery emits a visible retrying event'
);

SELECT is(
  (
    SELECT status::text
    FROM public.internal_complete_ai_job(
      '50000000-0000-4000-8000-000000000204',
      (
        SELECT lease_token
        FROM public.ai_jobs
        WHERE id = '50000000-0000-4000-8000-000000000204'
      ),
      '{}'::jsonb
    )
  ),
  'succeeded',
  'the reclaimed job can complete with its new lease'
);

SELECT is(
  (
    SELECT count(*)
    FROM public.internal_claim_ai_job(null)
  ),
  0::bigint,
  'claim returns no row when no job is ready'
);

SELECT is(
  (SELECT status::text FROM public.ai_jobs
   WHERE id = '50000000-0000-4000-8000-000000000201'),
  'succeeded',
  'completed job remains durable and usable'
);

SELECT * FROM finish();
ROLLBACK;
