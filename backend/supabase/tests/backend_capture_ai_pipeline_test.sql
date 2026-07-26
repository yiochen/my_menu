BEGIN;
SELECT plan(31);

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
  '00000000-0000-4000-8000-000000000301',
  '00000000-0000-0000-0000-000000000000',
  'authenticated',
  'authenticated',
  'capture-ai@example.com',
  '',
  now(),
  now(),
  now()
)
ON CONFLICT (id) DO NOTHING;

SELECT set_config('request.jwt.claim.role', 'service_role', true);

SELECT is(
  to_regprocedure('public.api_mark_capture_batch_ready(uuid)'),
  null::regprocedure,
  'the obsolete mark-ready RPC is removed'
);

SELECT is(
  to_regprocedure(
    'public.api_schedule_capture_processing(uuid,uuid,text,text,text,text)'
  ),
  null::regprocedure,
  'the obsolete classify scheduler RPC is removed'
);

SELECT is(
  (
    SELECT count(*)
    FROM cron.job
    WHERE jobname = 'mymenu-dispatch-ai-jobs'
  ),
  1::bigint,
  'a recurring dispatcher recovers queued AI jobs'
);

SELECT ok(
  (
    SELECT command like '%process-ai-jobs%'
    FROM cron.job
    WHERE jobname = 'mymenu-dispatch-ai-jobs'
  ),
  'cron recovery dispatches the protected Edge AI worker'
);

SELECT ok(
  to_regprocedure('public.internal_process_capture_ai_jobs(integer)') is null,
  'the obsolete database-native fake worker is removed'
);

INSERT INTO public.capture_batches (id, user_id, status, item_count)
VALUES (
  '30000000-0000-4000-8000-000000000301',
  '00000000-0000-4000-8000-000000000301',
  'pending_upload',
  5
);

DO $$
BEGIN
PERFORM *
FROM public.api_create_photo_capture(
  p_user_id => '00000000-0000-4000-8000-000000000301',
  p_batch_id => '30000000-0000-4000-8000-000000000301',
  p_capture_id => '40000000-0000-4000-8000-000000000301',
  p_ordinal => 0,
  p_storage_path => 'users/301/captures/301/original.jpg',
  p_content_type => 'image/jpeg',
  p_captured_at => '2026-07-20T19:00:00Z',
  p_captured_local_date => '2026-07-20',
  p_capture_date_source => 'exif_original'
);

PERFORM *
FROM public.api_create_photo_capture(
  p_user_id => '00000000-0000-4000-8000-000000000301',
  p_batch_id => '30000000-0000-4000-8000-000000000301',
  p_capture_id => '40000000-0000-4000-8000-000000000302',
  p_ordinal => 1,
  p_storage_path => 'users/301/captures/302/original.jpg',
  p_content_type => 'image/jpeg',
  p_captured_at => '2026-07-20T20:00:00Z',
  p_captured_local_date => '2026-07-20',
  p_capture_date_source => 'exif_original'
);

PERFORM *
FROM public.api_create_photo_capture(
  p_user_id => '00000000-0000-4000-8000-000000000301',
  p_batch_id => '30000000-0000-4000-8000-000000000301',
  p_capture_id => '40000000-0000-4000-8000-000000000303',
  p_ordinal => 2,
  p_storage_path => 'users/301/captures/303/original.jpg',
  p_content_type => 'image/jpeg',
  p_captured_at => '2026-07-21T19:00:00Z',
  p_captured_local_date => '2026-07-21',
  p_capture_date_source => 'exif_original'
);

PERFORM *
FROM public.api_create_photo_capture(
  p_user_id => '00000000-0000-4000-8000-000000000301',
  p_batch_id => '30000000-0000-4000-8000-000000000301',
  p_capture_id => '40000000-0000-4000-8000-000000000304',
  p_ordinal => 3,
  p_storage_path => 'users/301/captures/304/original.jpg',
  p_content_type => 'image/jpeg',
  p_captured_at => null,
  p_captured_local_date => null,
  p_capture_date_source => 'unknown'
);

PERFORM *
FROM public.api_create_photo_capture(
  p_user_id => '00000000-0000-4000-8000-000000000301',
  p_batch_id => '30000000-0000-4000-8000-000000000301',
  p_capture_id => '40000000-0000-4000-8000-000000000305',
  p_ordinal => 4,
  p_storage_path => 'users/301/captures/305/original.jpg',
  p_content_type => 'image/jpeg',
  p_captured_at => null,
  p_captured_local_date => null,
  p_capture_date_source => 'unknown'
);
END
$$;

SELECT is(
  (
    SELECT count(*)
    FROM public.captures
    WHERE batch_id = '30000000-0000-4000-8000-000000000301'
      AND captured_local_date is not null
  ),
  3::bigint,
  'original local dates are persisted for dated photos'
);

SELECT is(
  (
    SELECT count(*)
    FROM public.captures
    WHERE batch_id = '30000000-0000-4000-8000-000000000301'
      AND capture_date_source = 'exif_original'
  ),
  3::bigint,
  'the EXIF metadata source is persisted'
);

CREATE TEMP TABLE finalized_photo_job AS
SELECT *
FROM public.internal_finalize_capture_batch(
  '00000000-0000-4000-8000-000000000301',
  '30000000-0000-4000-8000-000000000301',
  'photo',
  null,
  null,
  null,
  null,
  '50000000-0000-4000-8000-000000000301',
  'batch:30000000-0000-4000-8000-000000000301:date-v1',
  'hash-301',
  'date-v1',
  3
);

SELECT is(
  (SELECT status::text FROM finalized_photo_job),
  'queued',
  'finalizing a complete photo batch queues durable AI work'
);

SELECT is(
  (
    SELECT status::text
    FROM public.capture_batches
    WHERE id = '30000000-0000-4000-8000-000000000301'
  ),
  'processing',
  'the queued photo batch is visibly processing'
);

SELECT lives_ok(
  $$
    SELECT *
    FROM public.internal_finalize_capture_batch(
      '00000000-0000-4000-8000-000000000301',
      '30000000-0000-4000-8000-000000000301',
      'photo',
      null,
      null,
      null,
      null,
      '50000000-0000-4000-8000-000000000399',
      'batch:30000000-0000-4000-8000-000000000301:date-v1',
      'hash-301',
      'date-v1',
      3
    )
  $$,
  'repeating finalization reuses the active job'
);

SELECT is(
  (
    SELECT count(*)
    FROM public.ai_jobs
    WHERE subject_id = '30000000-0000-4000-8000-000000000301'
  ),
  1::bigint,
  'repeated finalization does not duplicate the AI job'
);

CREATE TEMP TABLE claimed_photo_job AS
SELECT *
FROM public.internal_claim_ai_job(
  ARRAY['batch_grouping'::public.ai_job_type]
);

SELECT is(
  (SELECT status::text FROM claimed_photo_job),
  'running',
  'the worker claims the queued grouping job'
);

SELECT isnt(
  (SELECT lease_token FROM claimed_photo_job),
  null::uuid,
  'the claimed job has an ownership lease'
);

SELECT is(
  (
    SELECT status::text
    FROM public.internal_complete_capture_grouping_job(
      (SELECT id FROM claimed_photo_job),
      (SELECT lease_token FROM claimed_photo_job)
    )
  ),
  'succeeded',
  'the worker atomically completes date grouping'
);

SELECT is(
  (
    SELECT status::text
    FROM public.capture_batches
    WHERE id = '30000000-0000-4000-8000-000000000301'
  ),
  'applied',
  'completion marks the batch applied'
);

SELECT is(
  (
    SELECT count(*)
    FROM public.cooking_occasions
    WHERE batch_id = '30000000-0000-4000-8000-000000000301'
  ),
  4::bigint,
  'two shared dates and two unknown dates produce four occasions'
);

SELECT is(
  (
    SELECT count(distinct dish_id)
    FROM public.cooking_occasions
    WHERE batch_id = '30000000-0000-4000-8000-000000000301'
  ),
  4::bigint,
  'fake AI always creates a new dish for each occasion'
);

SELECT is(
  (
    SELECT applied_dish_id
    FROM public.captures
    WHERE id = '40000000-0000-4000-8000-000000000301'
  ),
  (
    SELECT applied_dish_id
    FROM public.captures
    WHERE id = '40000000-0000-4000-8000-000000000302'
  ),
  'photos from the same local date share a dish'
);

SELECT isnt(
  (
    SELECT applied_dish_id
    FROM public.captures
    WHERE id = '40000000-0000-4000-8000-000000000301'
  ),
  (
    SELECT applied_dish_id
    FROM public.captures
    WHERE id = '40000000-0000-4000-8000-000000000303'
  ),
  'photos from different local dates use different dishes'
);

SELECT isnt(
  (
    SELECT applied_dish_id
    FROM public.captures
    WHERE id = '40000000-0000-4000-8000-000000000304'
  ),
  (
    SELECT applied_dish_id
    FROM public.captures
    WHERE id = '40000000-0000-4000-8000-000000000305'
  ),
  'photos without date metadata remain separate occasions'
);

SELECT results_eq(
  $$
    SELECT title
    FROM public.dishes
    WHERE id IN (
      SELECT dish_id
      FROM public.cooking_occasions
      WHERE batch_id = '30000000-0000-4000-8000-000000000301'
    )
    ORDER BY title
  $$,
  $$
    VALUES
      ('Captured Dish'::text),
      ('Captured Dish'::text),
      ('Captured Dish · Jul 20'::text),
      ('Captured Dish · Jul 21'::text)
  $$,
  'date-grouped dishes include their local date in the title'
);

SELECT is(
  (
    SELECT count(*)
    FROM public.dish_images
    WHERE capture_id IN (
      SELECT id
      FROM public.captures
      WHERE batch_id = '30000000-0000-4000-8000-000000000301'
    )
      AND kind = 'source_photo'
      AND cooking_occasion_id is not null
  ),
  5::bigint,
  'all captured photos become source images for their occasion'
);

SELECT is(
  (
    SELECT count(*)
    FROM public.dish_cooking_stats
    WHERE dish_id IN (
      SELECT dish_id
      FROM public.cooking_occasions
      WHERE batch_id = '30000000-0000-4000-8000-000000000301'
    )
      AND made_count = 1
  ),
  4::bigint,
  'multiple photos from one occasion count as one cooking event'
);

SELECT is(
  (
    SELECT count(*)
    FROM public.captures
    WHERE batch_id = '30000000-0000-4000-8000-000000000301'
      AND status = 'applied'
  ),
  5::bigint,
  'every photo capture is applied'
);

SELECT is(
  (
    SELECT jsonb_array_length(normalized_result->'occasions')
    FROM public.ai_jobs
    WHERE id = '50000000-0000-4000-8000-000000000301'
  ),
  4,
  'the durable job stores its normalized occasion result'
);

SELECT is(
  (
    SELECT count(*)
    FROM public.sync_events
    WHERE entity_type = 'capture'
      AND entity_id IN (
        SELECT id
        FROM public.captures
        WHERE batch_id = '30000000-0000-4000-8000-000000000301'
      )
      AND operation = 'applied_to_new_dish'
  ),
  5::bigint,
  'completion emits one applied event per capture'
);

CREATE TEMP TABLE finalized_idea_job AS
SELECT *
FROM public.internal_finalize_capture_batch(
  '00000000-0000-4000-8000-000000000301',
  '30000000-0000-4000-8000-000000000302',
  'idea',
  'kimchi rice',
  '2026-07-22T12:00:00Z',
  '2026-07-22',
  'device_clock',
  '50000000-0000-4000-8000-000000000302',
  'batch:30000000-0000-4000-8000-000000000302:date-v1',
  'hash-302',
  'date-v1',
  3
);

SELECT is(
  (SELECT status::text FROM finalized_idea_job),
  'queued',
  'ideas use the same durable grouping pipeline'
);

SELECT is(
  (
    SELECT idea_text
    FROM public.captures
    WHERE id = '30000000-0000-4000-8000-000000000302'
  ),
  'kimchi rice',
  'idea finalization creates its capture'
);

CREATE TEMP TABLE claimed_idea_job AS
SELECT *
FROM public.internal_claim_ai_job(
  ARRAY['batch_grouping'::public.ai_job_type]
);

SELECT is(
  (
    SELECT status::text
    FROM public.internal_complete_capture_grouping_job(
      (SELECT id FROM claimed_idea_job),
      (SELECT lease_token FROM claimed_idea_job)
    )
  ),
  'succeeded',
  'the worker completes an idea grouping job'
);

SELECT is(
  (
    SELECT title
    FROM public.dishes
    WHERE id = (
      SELECT applied_dish_id
      FROM public.captures
      WHERE id = '30000000-0000-4000-8000-000000000302'
    )
  ),
  'Kimchi Rice',
  'an idea becomes a newly titled dish'
);

SELECT is(
  (
    SELECT made_count
    FROM public.dish_cooking_stats
    WHERE dish_id = (
      SELECT applied_dish_id
      FROM public.captures
      WHERE id = '30000000-0000-4000-8000-000000000302'
    )
  ),
  0::bigint,
  'an idea does not count as a photographed cooking occasion'
);

SELECT * FROM finish();
ROLLBACK;
