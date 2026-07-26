BEGIN;
SELECT plan(20);

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
VALUES (
  '00000000-0000-4000-8000-000000000601',
  '00000000-0000-0000-0000-000000000000',
  'authenticated',
  'authenticated',
  'real-ai-grouping@example.com',
  '',
  now(),
  now(),
  now()
)
ON CONFLICT (id) DO NOTHING;

SELECT set_config('request.jwt.claim.role', 'service_role', true);

INSERT INTO public.capture_batches (id, user_id, status, item_count)
VALUES (
  '30000000-0000-4000-8000-000000000601',
  '00000000-0000-4000-8000-000000000601',
  'pending_upload',
  2
);

SELECT *
FROM public.api_create_photo_capture(
  p_user_id => '00000000-0000-4000-8000-000000000601',
  p_batch_id => '30000000-0000-4000-8000-000000000601',
  p_capture_id => '40000000-0000-4000-8000-000000000601',
  p_ordinal => 0,
  p_storage_path => 'users/601/captures/601/original.jpg',
  p_content_type => 'image/jpeg',
  p_captured_local_date => '2026-07-20'
);

SELECT *
FROM public.api_create_photo_capture(
  p_user_id => '00000000-0000-4000-8000-000000000601',
  p_batch_id => '30000000-0000-4000-8000-000000000601',
  p_capture_id => '40000000-0000-4000-8000-000000000602',
  p_ordinal => 1,
  p_storage_path => 'users/601/captures/602/original.jpg',
  p_content_type => 'image/jpeg',
  p_captured_local_date => '2026-07-20'
);

CREATE TEMP TABLE real_ai_job AS
SELECT *
FROM public.internal_finalize_capture_batch_v2(
  '00000000-0000-4000-8000-000000000601',
  '30000000-0000-4000-8000-000000000601',
  'photo',
  null,
  null,
  null,
  null,
  '50000000-0000-4000-8000-000000000601',
  'batch:30000000-0000-4000-8000-000000000601:batch-grouping-v2',
  'hash-601',
  'batch-grouping-v2',
  'google',
  'batch-grouping-v2',
  'gemini-3.6-flash',
  'batch-grouping-v2',
  3
);

SELECT is(
  (SELECT provider FROM real_ai_job),
  'google',
  'the queued job records its direct provider'
);

SELECT is(
  (SELECT model_version FROM real_ai_job),
  'gemini-3.6-flash',
  'the queued job records the concrete model'
);

CREATE TEMP TABLE claimed_real_ai_job AS
SELECT *
FROM public.internal_claim_ai_job(
  ARRAY['batch_grouping'::public.ai_job_type]
);

SELECT is(
  (
    SELECT count(*)
    FROM public.internal_get_capture_grouping_input(
      (SELECT id FROM claimed_real_ai_job),
      (SELECT lease_token FROM claimed_real_ai_job)
    )
  ),
  2::bigint,
  'the leased worker receives every active capture'
);

SELECT ok(
  (
    SELECT lease_expires_at > now() + interval '2 minutes'
    FROM public.ai_jobs
    WHERE id = '50000000-0000-4000-8000-000000000601'
  ),
  'loading the input extends the model-call lease'
);

CREATE TEMP TABLE applied_real_ai_job AS
SELECT *
FROM public.internal_apply_capture_grouping_job(
  (SELECT id FROM claimed_real_ai_job),
  (SELECT lease_token FROM claimed_real_ai_job),
  jsonb_build_object(
    'groups',
    jsonb_build_array(
      jsonb_build_object(
        'captureIds',
        jsonb_build_array(
          '40000000-0000-4000-8000-000000000601',
          '40000000-0000-4000-8000-000000000602'
        ),
        'draft',
        jsonb_build_object(
          'title', 'Miso Salmon',
          'description', 'Glazed salmon with greens.',
          'labels', jsonb_build_array('dinner'),
          'visibleIngredients', jsonb_build_array('salmon', 'greens')
        ),
        'evidence',
        jsonb_build_array('Both photos show the same plated salmon.'),
        'uncertainty',
        '[]'::jsonb
      )
    ),
    'rejectedCaptures',
    '[]'::jsonb,
    'provenance',
    jsonb_build_object(
      'providerRequestId', 'request-601',
      'usage', jsonb_build_object('inputTokens', 100)
    )
  )
);

SELECT is(
  (SELECT status::text FROM applied_real_ai_job),
  'succeeded',
  'a valid model partition succeeds'
);

SELECT is(
  (SELECT normalized_result->'provenance'->>'provider'
   FROM applied_real_ai_job),
  'google',
  'the normalized result preserves provider provenance'
);

SELECT is(
  (SELECT normalized_result->'groups'->0->'draft'
     ->'visibleIngredients'->>0
   FROM applied_real_ai_job),
  'salmon',
  'visible ingredient suggestions remain in AI provenance'
);

SELECT is(
  (
    SELECT count(*)
    FROM public.dish_ingredients
    WHERE user_id = '00000000-0000-4000-8000-000000000601'
  ),
  0::bigint,
  'visible ingredient suggestions do not create recipe ingredients'
);

SELECT is(
  (
    SELECT count(*)
    FROM public.dishes
    WHERE user_id = '00000000-0000-4000-8000-000000000601'
      AND title = 'Miso Salmon'
  ),
  1::bigint,
  'the transaction creates one model-drafted dish'
);

SELECT is(
  (
    SELECT count(*)
    FROM public.dish_images
    WHERE user_id = '00000000-0000-4000-8000-000000000601'
      AND kind = 'source_photo'
      AND dish_id is not null
  ),
  2::bigint,
  'the transaction attaches both immutable source photos'
);

SELECT is(
  (
    SELECT count(*)
    FROM public.cooking_occasions
    WHERE batch_id = '30000000-0000-4000-8000-000000000601'
  ),
  1::bigint,
  'the group creates exactly one cooking occasion'
);

SELECT is(
  (
    SELECT count(*)
    FROM public.captures
    WHERE batch_id = '30000000-0000-4000-8000-000000000601'
      AND status = 'applied'
  ),
  2::bigint,
  'all partition members are atomically applied'
);

INSERT INTO public.capture_batches (id, user_id, status, item_count)
VALUES (
  '30000000-0000-4000-8000-000000000603',
  '00000000-0000-4000-8000-000000000601',
  'pending_upload',
  2
);

SELECT *
FROM public.api_create_photo_capture(
  p_user_id => '00000000-0000-4000-8000-000000000601',
  p_batch_id => '30000000-0000-4000-8000-000000000603',
  p_capture_id => '40000000-0000-4000-8000-000000000603',
  p_ordinal => 0,
  p_storage_path => 'users/601/captures/603/original.jpg',
  p_content_type => 'image/jpeg',
  p_captured_local_date => '2026-07-26'
);

SELECT *
FROM public.api_create_photo_capture(
  p_user_id => '00000000-0000-4000-8000-000000000601',
  p_batch_id => '30000000-0000-4000-8000-000000000603',
  p_capture_id => '40000000-0000-4000-8000-000000000604',
  p_ordinal => 1,
  p_storage_path => 'users/601/captures/604/original.jpg',
  p_content_type => 'image/jpeg',
  p_captured_local_date => '2026-07-26'
);

CREATE TEMP TABLE rejected_ai_job AS
SELECT *
FROM public.internal_finalize_capture_batch_v2(
  '00000000-0000-4000-8000-000000000601',
  '30000000-0000-4000-8000-000000000603',
  'photo',
  null,
  null,
  null,
  null,
  '50000000-0000-4000-8000-000000000603',
  'batch:30000000-0000-4000-8000-000000000603:batch-grouping-v2',
  'hash-603',
  'batch-grouping-v2',
  'google',
  'batch-grouping-v2',
  'gemini-3.6-flash',
  'batch-grouping-v2',
  3
);

CREATE TEMP TABLE claimed_rejected_ai_job AS
SELECT *
FROM public.internal_claim_ai_job(
  ARRAY['batch_grouping'::public.ai_job_type]
);

CREATE TEMP TABLE applied_rejected_ai_job AS
SELECT *
FROM public.internal_apply_capture_grouping_job(
  (SELECT id FROM claimed_rejected_ai_job),
  (SELECT lease_token FROM claimed_rejected_ai_job),
  jsonb_build_object(
    'groups',
    '[]'::jsonb,
    'rejectedCaptures',
    jsonb_build_array(
      jsonb_build_object(
        'captureId', '40000000-0000-4000-8000-000000000603',
        'classification', 'not_a_dish',
        'reason', 'The photo shows an ocean sunset.'
      ),
      jsonb_build_object(
        'captureId', '40000000-0000-4000-8000-000000000604',
        'classification', 'not_a_dish',
        'reason', 'The photo shows a living bird on grass.'
      )
    ),
    'provenance',
    jsonb_build_object('providerRequestId', 'request-603')
  )
);

SELECT is(
  (SELECT status::text FROM applied_rejected_ai_job),
  'succeeded',
  'an all-negative model partition succeeds'
);

SELECT is(
  (
    SELECT count(*)
    FROM public.captures
    WHERE batch_id = '30000000-0000-4000-8000-000000000603'
      AND status = 'discarded'
  ),
  2::bigint,
  'non-dish captures are discarded instead of applied'
);

SELECT is(
  (
    SELECT count(*)
    FROM public.cooking_occasions
    WHERE batch_id = '30000000-0000-4000-8000-000000000603'
  ),
  0::bigint,
  'non-dish captures create no cooking occasions'
);

SELECT is(
  (
    SELECT count(*)
    FROM public.dishes
    WHERE created_from_capture_id IN (
      '40000000-0000-4000-8000-000000000603',
      '40000000-0000-4000-8000-000000000604'
    )
  ),
  0::bigint,
  'non-dish captures create no dishes'
);

SELECT is(
  (
    SELECT jsonb_array_length(normalized_result->'rejectedCaptures')
    FROM applied_rejected_ai_job
  ),
  2,
  'the normalized result preserves every rejection decision'
);

SELECT is(
  (
    SELECT status::text
    FROM public.capture_batches
    WHERE id = '30000000-0000-4000-8000-000000000603'
  ),
  'applied',
  'an all-negative batch reaches a terminal applied state'
);

SELECT throws_ok(
  $$
    SELECT *
    FROM public.internal_apply_capture_grouping_job(
      '50000000-0000-4000-8000-000000000699',
      '60000000-0000-4000-8000-000000000699',
      '{"groups":[]}'::jsonb
    )
  $$,
  'P0001',
  'AI job 50000000-0000-4000-8000-000000000699 does not have the active lease',
  'an unowned lease cannot apply model output'
);

SELECT is(
  has_function_privilege(
    'authenticated',
    'public.internal_apply_capture_grouping_job(uuid,uuid,jsonb)',
    'EXECUTE'
  ),
  false,
  'authenticated clients cannot apply model output'
);

SELECT * FROM finish();
ROLLBACK;
