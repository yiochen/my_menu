BEGIN;
SELECT plan(20);

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
  (SELECT capture_id FROM public.api_create_photo_capture(
    '00000000-0000-4000-8000-000000000001',
    '10000000-0000-4000-8000-000000000002',
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
  'classifying',
  'photo capture starts classifying'
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
    '10000000-0000-4000-8000-000000000004',
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

CREATE TEMP TABLE scheduled_photo_capture AS
SELECT *
FROM public.api_schedule_capture_processing(
  '00000000-0000-4000-8000-000000000001',
  '10000000-0000-4000-8000-000000000004',
  'http://127.0.0.1:54321/functions/v1/processCaptureAsync',
  'test-worker-key',
  'users/00000000-0000-4000-8000-000000000001/captures/10000000-0000-4000-8000-000000000004/original.jpg',
  null
);

SELECT is(
  (SELECT status FROM scheduled_photo_capture),
  'classifying',
  'api_schedule_capture_processing leaves photo capture classifying'
);

SELECT is(
  (SELECT request_id > 0 FROM scheduled_photo_capture),
  true,
  'api_schedule_capture_processing enqueues a pg_net request for photo captures'
);

CREATE TEMP TABLE scheduled_idea_capture AS
SELECT *
FROM public.api_schedule_capture_processing(
  '00000000-0000-4000-8000-000000000001',
  '10000000-0000-4000-8000-000000000005',
  'http://127.0.0.1:54321/functions/v1/processCaptureAsync',
  'test-worker-key',
  null,
  'fried egg rice'
);

SELECT is(
  (SELECT request_id > 0 FROM scheduled_idea_capture),
  true,
  'api_schedule_capture_processing enqueues a pg_net request for idea captures'
);

SELECT is(
  (SELECT idea_text FROM public.captures WHERE id = '10000000-0000-4000-8000-000000000005'),
  'fried egg rice',
  'api_schedule_capture_processing creates idea capture rows before enqueue'
);

SELECT * FROM finish();
ROLLBACK;
