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
VALUES
  (
    '00000000-0000-4000-8000-000000000101',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'batch-one@example.com',
    '',
    now(),
    now(),
    now()
  ),
  (
    '00000000-0000-4000-8000-000000000102',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'batch-two@example.com',
    '',
    now(),
    now(),
    now()
  )
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.capture_batches (
  id,
  user_id,
  status,
  item_count
)
VALUES (
  '30000000-0000-4000-8000-000000000102',
  '00000000-0000-4000-8000-000000000102',
  'pending_upload',
  1
);

SET LOCAL ROLE authenticated;
SELECT set_config(
  'request.jwt.claim.sub',
  '00000000-0000-4000-8000-000000000101',
  true
);

SELECT is(
  (
    SELECT batch_id
    FROM public.api_upsert_capture_batch(
      '30000000-0000-4000-8000-000000000101',
      3,
      '2026-07-25T12:00:00Z'::timestamptz
    )
  ),
  '30000000-0000-4000-8000-000000000101'::uuid,
  'authenticated user can create a locally identified batch'
);

SELECT lives_ok(
  $$
    SELECT *
    FROM public.api_upsert_capture_batch(
      '30000000-0000-4000-8000-000000000101',
      3,
      '2026-07-25T12:00:00Z'::timestamptz
    )
  $$,
  'repeating a batch upsert is idempotent'
);

SELECT is(
  (
    SELECT count(*)
    FROM public.capture_batches
    WHERE id = '30000000-0000-4000-8000-000000000101'
  ),
  1::bigint,
  'repeated upsert does not duplicate the batch'
);

SELECT is(
  (
    SELECT item_count
    FROM public.capture_batches
    WHERE id = '30000000-0000-4000-8000-000000000101'
  ),
  3,
  'batch stores its expected item count'
);

SELECT throws_ok(
  $$
    SELECT *
    FROM public.api_upsert_capture_batch(
      '30000000-0000-4000-8000-000000000109',
      10,
      now()
    )
  $$,
  'Capture batch item count must be between 1 and 9',
  'batch RPC enforces the nine-photo cap'
);

SELECT is(
  (
    SELECT count(*)
    FROM public.capture_batches
    WHERE id = '30000000-0000-4000-8000-000000000102'
  ),
  0::bigint,
  'RLS hides another user capture batch'
);

SELECT is(
  has_function_privilege(
    'authenticated',
    'public.api_upsert_capture_batch(uuid,integer,timestamp with time zone)',
    'EXECUTE'
  ),
  true,
  'authenticated users can upsert their own batches'
);

SELECT is(
  has_function_privilege(
    'anon',
    'public.api_create_photo_capture(uuid,uuid,uuid,integer,text,text,bigint,integer,integer,text,timestamp with time zone)',
    'EXECUTE'
  ),
  false,
  'anonymous clients cannot invoke the service-only ordered upload RPC'
);

SELECT is(
  has_function_privilege(
    'service_role',
    'public.api_create_photo_capture(uuid,uuid,uuid,integer,text,text,bigint,integer,integer,text,timestamp with time zone)',
    'EXECUTE'
  ),
  true,
  'Edge Functions can invoke the ordered upload RPC'
);

RESET ROLE;

SELECT lives_ok(
  $$
    SELECT *
    FROM public.api_create_photo_capture(
      p_user_id => '00000000-0000-4000-8000-000000000101',
      p_batch_id => '30000000-0000-4000-8000-000000000101',
      p_capture_id => '40000000-0000-4000-8000-000000000101',
      p_ordinal => 0,
      p_storage_path => 'users/00000000-0000-4000-8000-000000000101/captures/40000000-0000-4000-8000-000000000101/original.jpg',
      p_content_type => 'image/jpeg'
    );
    SELECT *
    FROM public.api_create_photo_capture(
      p_user_id => '00000000-0000-4000-8000-000000000101',
      p_batch_id => '30000000-0000-4000-8000-000000000101',
      p_capture_id => '40000000-0000-4000-8000-000000000102',
      p_ordinal => 1,
      p_storage_path => 'users/00000000-0000-4000-8000-000000000101/captures/40000000-0000-4000-8000-000000000102/original.jpg',
      p_content_type => 'image/jpeg'
    )
  $$,
  'items upload independently'
);

SET LOCAL ROLE authenticated;
SELECT set_config(
  'request.jwt.claim.sub',
  '00000000-0000-4000-8000-000000000101',
  true
);

SELECT is(
  (
    SELECT ready
    FROM public.api_mark_capture_batch_ready(
      '30000000-0000-4000-8000-000000000101'
    )
  ),
  false,
  'two of three uploads do not mark the batch ready'
);

SELECT is(
  (
    SELECT status
    FROM public.capture_batches
    WHERE id = '30000000-0000-4000-8000-000000000101'
  ),
  'uploading',
  'partial upload state stays distinct from an item failure'
);

RESET ROLE;

SELECT lives_ok(
  $$
    SELECT *
    FROM public.api_create_photo_capture(
      p_user_id => '00000000-0000-4000-8000-000000000101',
      p_batch_id => '30000000-0000-4000-8000-000000000101',
      p_capture_id => '40000000-0000-4000-8000-000000000103',
      p_ordinal => 2,
      p_storage_path => 'users/00000000-0000-4000-8000-000000000101/captures/40000000-0000-4000-8000-000000000103/original.jpg',
      p_content_type => 'image/jpeg'
    );
    SELECT *
    FROM public.api_create_photo_capture(
      p_user_id => '00000000-0000-4000-8000-000000000101',
      p_batch_id => '30000000-0000-4000-8000-000000000101',
      p_capture_id => '40000000-0000-4000-8000-000000000103',
      p_ordinal => 2,
      p_storage_path => 'users/00000000-0000-4000-8000-000000000101/captures/40000000-0000-4000-8000-000000000103/original.jpg',
      p_content_type => 'image/jpeg'
    )
  $$,
  'repeating an item create/upload metadata request is idempotent'
);

SELECT is(
  (
    SELECT count(*)
    FROM public.captures
    WHERE batch_id = '30000000-0000-4000-8000-000000000101'
  ),
  3::bigint,
  'repeated item request does not duplicate captures'
);

SELECT is(
  (
    SELECT count(*)
    FROM public.dish_images
    WHERE capture_id IN (
      SELECT id
      FROM public.captures
      WHERE batch_id = '30000000-0000-4000-8000-000000000101'
    )
  ),
  3::bigint,
  'repeated item request does not duplicate storage metadata'
);

SET LOCAL ROLE authenticated;
SELECT set_config(
  'request.jwt.claim.sub',
  '00000000-0000-4000-8000-000000000101',
  true
);

SELECT is(
  (
    SELECT ready
    FROM public.api_mark_capture_batch_ready(
      '30000000-0000-4000-8000-000000000101'
    )
  ),
  true,
  'batch becomes ready after every expected item has media metadata'
);

SELECT is(
  (
    SELECT status
    FROM public.capture_batches
    WHERE id = '30000000-0000-4000-8000-000000000101'
  ),
  'ready_for_ai',
  'ready transition is stored on the batch'
);

SELECT is(
  (
    SELECT captures
    FROM public.api_get_capture_batches(
      ARRAY['30000000-0000-4000-8000-000000000101'::uuid]
    )
  ) -> 0 ->> 'ordinal',
  '0',
  'batch read API returns captures in ordinal order'
);

RESET ROLE;

SELECT is(
  (
    SELECT operation
    FROM public.sync_events
    WHERE entity_type = 'capture_batch'
      AND entity_id = '30000000-0000-4000-8000-000000000101'
    ORDER BY id DESC
    LIMIT 1
  ),
  'ready_for_ai',
  'ready transition emits a capture-batch sync event'
);

DO $$
BEGIN
  PERFORM *
  FROM public.api_create_photo_capture(
    '00000000-0000-4000-8000-000000000101',
    '40000000-0000-4000-8000-000000000109',
    'users/00000000-0000-4000-8000-000000000101/captures/40000000-0000-4000-8000-000000000109/original.jpg',
    'image/jpeg',
    null,
    null,
    null,
    null,
    now()
  );
END
$$;

SELECT is(
  (
    SELECT count(*)
    FROM public.captures
    WHERE captures.id = '40000000-0000-4000-8000-000000000109'
      AND captures.batch_id = captures.id
      AND captures.ordinal = 0
  ),
  1::bigint,
  'legacy single-photo API produces the same valid one-item batch shape'
);

SELECT * FROM finish();
ROLLBACK;
