BEGIN;
SELECT plan(34);

DO $$
BEGIN
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
    '00000000-0000-4000-8000-000000000001',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'capture-rpc-test@example.com',
    '',
    now(),
    now(),
    now()
  )
  ON CONFLICT (id) DO NOTHING;
END
$$;

INSERT INTO public.capture_batches (id, user_id, status, item_count)
VALUES (
  '30000000-0000-4000-8000-000000000001',
  '00000000-0000-4000-8000-000000000001',
  'pending_upload',
  3
);

SELECT is(
  (SELECT public.emit_sync_event(
    '00000000-0000-4000-8000-000000000001',
    'test',
    '10000000-0000-4000-8000-000000000001',
    'upsert',
    '{}'::jsonb
  ) > 0),
  true,
  'emit_sync_event returns a positive cursor'
);

SELECT is(
  (SELECT count(*) FROM storage.buckets WHERE id = 'menu-media'),
  1::bigint,
  'menu-media bucket exists'
);

SELECT is(
  has_schema_privilege('service_role', 'public', 'USAGE'),
  true,
  'service_role can use the public schema for Edge Function hydration'
);

SELECT is(
  has_table_privilege('service_role', 'public.dishes', 'SELECT'),
  true,
  'service_role can select dishes for Edge Function hydration'
);

SELECT is(
  has_table_privilege('service_role', 'public.captures', 'SELECT'),
  true,
  'service_role can select captures for Edge Function hydration'
);

SELECT is(
  has_table_privilege('service_role', 'public.dish_cooking_stats', 'SELECT'),
  true,
  'service_role can select dish cooking stats for Edge Function hydration'
);

SELECT is(
  has_sequence_privilege('service_role', 'public.sync_events_id_seq', 'USAGE'),
  true,
  'service_role can insert sync events with generated cursors'
);

SELECT is(
  (SELECT capture_id FROM public.api_create_photo_capture(
    '00000000-0000-4000-8000-000000000001',
    '30000000-0000-4000-8000-000000000001',
    '10000000-0000-4000-8000-000000000002',
    0,
    'users/00000000-0000-4000-8000-000000000001/captures/10000000-0000-4000-8000-000000000002/original.jpg',
    'image/jpeg',
    1234,
    640,
    480,
    'hash-one',
    '2026-06-22T00:00:00Z'::timestamptz
  )),
  '10000000-0000-4000-8000-000000000002'::uuid,
  'api_create_photo_capture returns capture id'
);

SELECT is(
  (SELECT kind::text FROM public.captures WHERE id = '10000000-0000-4000-8000-000000000002'),
  'photo',
  'photo capture row is created'
);

SELECT is(
  (SELECT status::text FROM public.captures WHERE id = '10000000-0000-4000-8000-000000000002'),
  'uploaded',
  'photo capture starts uploaded'
);

SELECT is(
  (
    SELECT operation
    FROM public.sync_events
    WHERE entity_id = '10000000-0000-4000-8000-000000000002'
    ORDER BY id DESC
    LIMIT 1
  ),
  'uploaded',
  'photo capture emits an uploaded sync event'
);

SELECT is(
  (SELECT kind::text FROM public.dish_images WHERE capture_id = '10000000-0000-4000-8000-000000000002'),
  'capture_photo',
  'capture image row is created'
);

SELECT is(
  (SELECT dish_id FROM public.api_create_dish_from_capture(
    '00000000-0000-4000-8000-000000000001',
    '10000000-0000-4000-8000-000000000002',
    '20000000-0000-4000-8000-000000000001',
    'Test Capture Dish',
    'Created by pgTAP.',
    ARRAY['capture', 'test'],
    'Draft'
  )),
  '20000000-0000-4000-8000-000000000001'::uuid,
  'api_create_dish_from_capture returns dish id'
);

SELECT is(
  (SELECT title FROM public.dishes WHERE id = '20000000-0000-4000-8000-000000000001'),
  'Test Capture Dish',
  'dish row is created from capture'
);

SELECT is(
  (SELECT status::text FROM public.captures WHERE id = '10000000-0000-4000-8000-000000000002'),
  'applied',
  'capture is marked applied'
);

SELECT is(
  (SELECT applied_dish_id FROM public.captures WHERE id = '10000000-0000-4000-8000-000000000002'),
  '20000000-0000-4000-8000-000000000001'::uuid,
  'capture points at applied dish'
);

SELECT is(
  (SELECT kind::text FROM public.dish_images WHERE capture_id = '10000000-0000-4000-8000-000000000002'),
  'source_photo',
  'capture image is promoted to source photo'
);

SELECT is(
  (SELECT dish_id FROM public.dish_images WHERE capture_id = '10000000-0000-4000-8000-000000000002'),
  '20000000-0000-4000-8000-000000000001'::uuid,
  'source image points at dish'
);

SELECT is(
  (
    SELECT operation
    FROM public.sync_events
    WHERE entity_id = '10000000-0000-4000-8000-000000000002'
    ORDER BY id DESC
    LIMIT 1
  ),
  'applied_to_new_dish',
  'new dish capture emits an applied-to-new-dish sync event'
);

SELECT is(
  (SELECT capture_id FROM public.api_create_idea_capture(
    '00000000-0000-4000-8000-000000000001',
    '10000000-0000-4000-8000-000000000003',
    'kimchi rice',
    '2026-06-22T00:01:00Z'::timestamptz
  )),
  '10000000-0000-4000-8000-000000000003'::uuid,
  'api_create_idea_capture returns capture id'
);

SELECT is(
  (SELECT idea_text FROM public.captures WHERE id = '10000000-0000-4000-8000-000000000003'),
  'kimchi rice',
  'idea capture stores idea text'
);

SELECT is(
  (SELECT capture_id FROM public.api_discard_capture(
    '00000000-0000-4000-8000-000000000001',
    '10000000-0000-4000-8000-000000000003'
  )),
  '10000000-0000-4000-8000-000000000003'::uuid,
  'api_discard_capture returns capture id'
);

SELECT is(
  (SELECT status::text FROM public.captures WHERE id = '10000000-0000-4000-8000-000000000003'),
  'discarded',
  'discard RPC marks capture discarded'
);

DO $$
BEGIN
  PERFORM *
  FROM public.api_create_photo_capture(
    '00000000-0000-4000-8000-000000000001',
    '30000000-0000-4000-8000-000000000001',
    '10000000-0000-4000-8000-000000000006',
    1,
    'users/00000000-0000-4000-8000-000000000001/captures/10000000-0000-4000-8000-000000000006/original.jpg',
    'image/jpeg',
    1234,
    640,
    480,
    'hash-six',
    '2026-06-22T00:03:00Z'::timestamptz
  );
END
$$;

SELECT is(
  (SELECT dish_id FROM public.api_apply_capture_to_dish(
    '00000000-0000-4000-8000-000000000001',
    '10000000-0000-4000-8000-000000000006',
    '20000000-0000-4000-8000-000000000001',
    'Existing',
    'Added to an existing dish.',
    ARRAY['repeat']
  )),
  '20000000-0000-4000-8000-000000000001'::uuid,
  'api_apply_capture_to_dish returns the existing dish id'
);

SELECT is(
  (SELECT status::text FROM public.captures WHERE id = '10000000-0000-4000-8000-000000000006'),
  'applied',
  'existing dish capture is marked applied'
);

SELECT is(
  (
    SELECT body
    FROM public.dish_notes
    WHERE dish_id = '20000000-0000-4000-8000-000000000001'
      AND body = 'Added to an existing dish.'
  ),
  'Added to an existing dish.',
  'legacy capture notes become standalone dish notes'
);

SELECT is(
  (
    SELECT operation
    FROM public.sync_events
    WHERE entity_id = '10000000-0000-4000-8000-000000000006'
    ORDER BY id DESC
    LIMIT 1
  ),
  'applied_to_existing_dish',
  'existing dish capture emits an applied-to-existing-dish sync event'
);

DO $$
BEGIN
  PERFORM *
  FROM public.api_create_photo_capture(
    '00000000-0000-4000-8000-000000000001',
    '30000000-0000-4000-8000-000000000001',
    '10000000-0000-4000-8000-000000000004',
    2,
    'users/00000000-0000-4000-8000-000000000001/captures/10000000-0000-4000-8000-000000000004/original.jpg',
    'image/jpeg',
    1234,
    640,
    480,
    'hash-two',
    '2026-06-22T00:02:00Z'::timestamptz
  );
END
$$;

CREATE TEMP TABLE pulled_events AS
SELECT *
FROM public.api_pull_events(
  '00000000-0000-4000-8000-000000000001',
  0,
  200
);

SELECT is(
  (SELECT has_more FROM pulled_events),
  false,
  'api_pull_events reports no more pages when under the limit'
);

SELECT is(
  (
    SELECT events @> '[{"type": "capture.applied_to_existing_dish"}]'::jsonb
    FROM pulled_events
  ),
  true,
  'api_pull_events returns semantic event types'
);

SELECT is(
  (
    SELECT events @> jsonb_build_array(
      jsonb_build_object(
        'type',
        'capture.applied_to_existing_dish',
        'entityIds',
        jsonb_build_object(
          'captureId',
          '10000000-0000-4000-8000-000000000006'::uuid,
          'dishId',
          '20000000-0000-4000-8000-000000000001'::uuid
        )
      )
    )
    FROM pulled_events
  ),
  true,
  'api_pull_events includes entity ids needed for batch hydration'
);

SELECT is(
  (SELECT requires_bootstrap FROM pulled_events),
  false,
  'api_pull_events does not require bootstrap while all events are retained'
);

CREATE TEMP TABLE pulled_first_page AS
SELECT *
FROM public.api_pull_events(
  '00000000-0000-4000-8000-000000000001',
  0,
  1
);

SELECT is(
  (SELECT jsonb_array_length(events) FROM pulled_first_page),
  1,
  'api_pull_events honors the requested page limit'
);

SELECT is(
  (SELECT has_more FROM pulled_first_page),
  true,
  'api_pull_events reports more pages when events exceed the limit'
);

CREATE TEMP TABLE pulled_after_latest AS
SELECT *
FROM public.api_pull_events(
  '00000000-0000-4000-8000-000000000001',
  (SELECT cursor FROM pulled_events),
  200
);

SELECT is(
  (SELECT events FROM pulled_after_latest),
  '[]'::jsonb,
  'api_pull_events filters out events at or before the cursor'
);

SELECT * FROM finish();
ROLLBACK;
