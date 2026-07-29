BEGIN;
SELECT plan(12);

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
  '00000000-0000-4000-8000-000000000801',
  '00000000-0000-0000-0000-000000000000',
  'authenticated',
  'authenticated',
  'unclassified-actions@example.com',
  '',
  now(),
  now(),
  now()
)
ON CONFLICT (id) DO NOTHING;

SELECT set_config('request.jwt.claim.role', 'service_role', true);

INSERT INTO public.capture_batches (
  id, user_id, status, item_count
)
VALUES (
  '30000000-0000-4000-8000-000000000801',
  '00000000-0000-4000-8000-000000000801',
  'applied',
  2
);

INSERT INTO public.dishes (
  id, user_id, title, creation_source
)
VALUES (
  '70000000-0000-4000-8000-000000000801',
  '00000000-0000-4000-8000-000000000801',
  'Existing Fruit Dish',
  'manual'
);

INSERT INTO public.captures (
  id,
  user_id,
  batch_id,
  ordinal,
  kind,
  status,
  failure_reason,
  captured_at,
  captured_local_date
)
VALUES
  (
    '40000000-0000-4000-8000-000000000801',
    '00000000-0000-4000-8000-000000000801',
    '30000000-0000-4000-8000-000000000801',
    0,
    'photo',
    'discarded',
    'No prepared dish was recognized.',
    '2026-07-27T14:00:00Z',
    '2026-07-27'
  ),
  (
    '40000000-0000-4000-8000-000000000802',
    '00000000-0000-4000-8000-000000000801',
    '30000000-0000-4000-8000-000000000801',
    1,
    'photo',
    'discarded',
    'The photo appears unrelated to food.',
    '2026-07-27T14:01:00Z',
    '2026-07-27'
  );

INSERT INTO public.dish_images (
  id,
  user_id,
  capture_id,
  kind,
  storage_path,
  content_type,
  captured_at
)
VALUES
  (
    '72000000-0000-4000-8000-000000000801',
    '00000000-0000-4000-8000-000000000801',
    '40000000-0000-4000-8000-000000000801',
    'capture_photo',
    'users/801/captures/a.jpg',
    'image/jpeg',
    '2026-07-27T14:00:00Z'
  ),
  (
    '72000000-0000-4000-8000-000000000802',
    '00000000-0000-4000-8000-000000000801',
    '40000000-0000-4000-8000-000000000802',
    'capture_photo',
    'users/801/captures/b.jpg',
    'image/jpeg',
    '2026-07-27T14:01:00Z'
  );

SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claim.role', 'authenticated', true);
SELECT set_config(
  'request.jwt.claim.sub',
  '00000000-0000-4000-8000-000000000801',
  true
);

SELECT is(
  (
    public.api_assign_unclassified_capture_grouping(
      '73000000-0000-4000-8000-000000000801',
      '30000000-0000-4000-8000-000000000801',
      'assign',
      ARRAY['40000000-0000-4000-8000-000000000801'::uuid],
      '70000000-0000-4000-8000-000000000801',
      null
    )->>'status'
  ),
  'applied',
  'an unclassified photo can be assigned to an existing dish'
);

SET LOCAL ROLE service_role;

SELECT is(
  (
    SELECT applied_dish_id
    FROM public.captures
    WHERE id = '40000000-0000-4000-8000-000000000801'
  ),
  '70000000-0000-4000-8000-000000000801'::uuid,
  'assignment updates the capture dish'
);

SELECT results_eq(
  $$
    SELECT kind::text, dish_id
    FROM public.dish_images
    WHERE capture_id = '40000000-0000-4000-8000-000000000801'
  $$,
  $$
    VALUES (
      'source_photo'::text,
      '70000000-0000-4000-8000-000000000801'::uuid
    )
  $$,
  'assignment promotes the original image to a source photo'
);

SELECT results_eq(
  $$
    SELECT organization_source, failure_reason
    FROM public.captures
    WHERE id = '40000000-0000-4000-8000-000000000801'
  $$,
  $$ VALUES ('user'::text, null::text) $$,
  'assignment records user intent and clears the rejection reason'
);

SELECT is(
  (
    public.api_undo_capture_grouping(
      '74000000-0000-4000-8000-000000000801',
      '73000000-0000-4000-8000-000000000801'
    )->>'status'
  ),
  'undone',
  'an unclassified assignment can be undone'
);

SET LOCAL ROLE service_role;

SELECT results_eq(
  $$
    SELECT status::text, applied_dish_id, failure_reason
    FROM public.captures
    WHERE id = '40000000-0000-4000-8000-000000000801'
  $$,
  $$
    VALUES (
      'discarded'::text,
      null::uuid,
      'No prepared dish was recognized.'::text
    )
  $$,
  'undo restores the unclassified capture state and reason'
);

SELECT results_eq(
  $$
    SELECT kind::text, dish_id
    FROM public.dish_images
    WHERE capture_id = '40000000-0000-4000-8000-000000000801'
  $$,
  $$ VALUES ('capture_photo'::text, null::uuid) $$,
  'undo removes the photo from dish history'
);

SET LOCAL ROLE authenticated;

SELECT is(
  (
    public.api_assign_unclassified_capture_grouping(
      '73000000-0000-4000-8000-000000000802',
      '30000000-0000-4000-8000-000000000801',
      'assignSplit',
      ARRAY['40000000-0000-4000-8000-000000000801'::uuid],
      '70000000-0000-4000-8000-000000000802',
      'Manually Identified Dish'
    )->>'createdDishId'
  ),
  '70000000-0000-4000-8000-000000000802',
  'an unclassified photo can create a new dish'
);

SET LOCAL ROLE service_role;

SELECT is(
  (
    SELECT count(*)
    FROM public.dishes
    WHERE id = '70000000-0000-4000-8000-000000000802'
      AND deleted_at is null
  ),
  1::bigint,
  'manual assignment creates exactly one active dish'
);

SET LOCAL ROLE authenticated;

SELECT is(
  (
    public.api_delete_capture(
      '40000000-0000-4000-8000-000000000802'
    )->>'status'
  ),
  'deleted',
  'an unclassified photo can be deleted'
);

SET LOCAL ROLE service_role;

SELECT ok(
  (
    SELECT deleted_at is not null
    FROM public.captures
    WHERE id = '40000000-0000-4000-8000-000000000802'
  ),
  'deleted capture is hidden from later hydration'
);

SELECT is(
  has_function_privilege(
    'anon',
    'public.api_delete_capture(uuid)',
    'EXECUTE'
  ),
  false,
  'anonymous users cannot delete captures'
);

SELECT * FROM finish();
ROLLBACK;
