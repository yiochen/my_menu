BEGIN;
SELECT plan(28);

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
    '00000000-0000-4000-8000-000000000701',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'capture-correction-one@example.com',
    '',
    now(),
    now(),
    now()
  ),
  (
    '00000000-0000-4000-8000-000000000702',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'capture-correction-two@example.com',
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
VALUES
  (
    '30000000-0000-4000-8000-000000000701',
    '00000000-0000-4000-8000-000000000701',
    'applied',
    3
  ),
  (
    '30000000-0000-4000-8000-000000000702',
    '00000000-0000-4000-8000-000000000702',
    'applied',
    1
  );

INSERT INTO public.dishes (
  id,
  user_id,
  title,
  creation_source,
  created_from_capture_id
)
VALUES
  (
    '70000000-0000-4000-8000-000000000701',
    '00000000-0000-4000-8000-000000000701',
    'Miso Salmon Bowl',
    'ai_capture',
    '40000000-0000-4000-8000-000000000701'
  ),
  (
    '70000000-0000-4000-8000-000000000702',
    '00000000-0000-4000-8000-000000000701',
    'Charred Corn Ramen',
    'ai_capture',
    '40000000-0000-4000-8000-000000000703'
  ),
  (
    '70000000-0000-4000-8000-000000000799',
    '00000000-0000-4000-8000-000000000702',
    'Another User Dish',
    'ai_capture',
    null
  );

INSERT INTO public.captures (
  id,
  user_id,
  batch_id,
  ordinal,
  kind,
  status,
  applied_dish_id,
  captured_at,
  captured_local_date
)
VALUES
  (
    '40000000-0000-4000-8000-000000000701',
    '00000000-0000-4000-8000-000000000701',
    '30000000-0000-4000-8000-000000000701',
    0,
    'photo',
    'applied',
    '70000000-0000-4000-8000-000000000701',
    '2026-07-27T12:00:00Z',
    '2026-07-27'
  ),
  (
    '40000000-0000-4000-8000-000000000702',
    '00000000-0000-4000-8000-000000000701',
    '30000000-0000-4000-8000-000000000701',
    1,
    'photo',
    'applied',
    '70000000-0000-4000-8000-000000000701',
    '2026-07-27T12:01:00Z',
    '2026-07-27'
  ),
  (
    '40000000-0000-4000-8000-000000000703',
    '00000000-0000-4000-8000-000000000701',
    '30000000-0000-4000-8000-000000000701',
    2,
    'photo',
    'applied',
    '70000000-0000-4000-8000-000000000702',
    '2026-07-27T12:02:00Z',
    '2026-07-27'
  );

INSERT INTO public.cooking_occasions (
  id, user_id, batch_id, dish_id, grouping_key, local_date
)
VALUES
  (
    '71000000-0000-4000-8000-000000000701',
    '00000000-0000-4000-8000-000000000701',
    '30000000-0000-4000-8000-000000000701',
    '70000000-0000-4000-8000-000000000701',
    'ai:40000000-0000-4000-8000-000000000701',
    '2026-07-27'
  ),
  (
    '71000000-0000-4000-8000-000000000702',
    '00000000-0000-4000-8000-000000000701',
    '30000000-0000-4000-8000-000000000701',
    '70000000-0000-4000-8000-000000000702',
    'ai:40000000-0000-4000-8000-000000000703',
    '2026-07-27'
  );

INSERT INTO public.dish_images (
  id,
  user_id,
  dish_id,
  capture_id,
  cooking_occasion_id,
  kind,
  storage_path,
  content_type,
  captured_at
)
VALUES
  (
    '72000000-0000-4000-8000-000000000701',
    '00000000-0000-4000-8000-000000000701',
    '70000000-0000-4000-8000-000000000701',
    '40000000-0000-4000-8000-000000000701',
    '71000000-0000-4000-8000-000000000701',
    'source_photo',
    'users/701/captures/a.jpg',
    'image/jpeg',
    '2026-07-27T12:00:00Z'
  ),
  (
    '72000000-0000-4000-8000-000000000702',
    '00000000-0000-4000-8000-000000000701',
    '70000000-0000-4000-8000-000000000701',
    '40000000-0000-4000-8000-000000000702',
    '71000000-0000-4000-8000-000000000701',
    'source_photo',
    'users/701/captures/b.jpg',
    'image/jpeg',
    '2026-07-27T12:01:00Z'
  ),
  (
    '72000000-0000-4000-8000-000000000703',
    '00000000-0000-4000-8000-000000000701',
    '70000000-0000-4000-8000-000000000702',
    '40000000-0000-4000-8000-000000000703',
    '71000000-0000-4000-8000-000000000702',
    'source_photo',
    'users/701/captures/c.jpg',
    'image/jpeg',
    '2026-07-27T12:02:00Z'
  );

SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claim.role', 'authenticated', true);
SELECT set_config(
  'request.jwt.claim.sub',
  '00000000-0000-4000-8000-000000000701',
  true
);

SELECT is(
  (
    public.api_correct_capture_grouping(
      '73000000-0000-4000-8000-000000000701',
      '30000000-0000-4000-8000-000000000701',
      'move',
      ARRAY['40000000-0000-4000-8000-000000000702'::uuid],
      '70000000-0000-4000-8000-000000000702',
      null
    )->>'status'
  ),
  'applied',
  'move correction applies'
);

SET LOCAL ROLE service_role;

SELECT is(
  (
    SELECT applied_dish_id
    FROM public.captures
    WHERE id = '40000000-0000-4000-8000-000000000702'
  ),
  '70000000-0000-4000-8000-000000000702'::uuid,
  'move updates the capture assignment'
);

SELECT is(
  (
    SELECT dish_id
    FROM public.dish_images
    WHERE id = '72000000-0000-4000-8000-000000000702'
  ),
  '70000000-0000-4000-8000-000000000702'::uuid,
  'move reuses the original source image association'
);

SELECT is(
  (
    SELECT count(*)
    FROM public.dish_images
    WHERE capture_id = '40000000-0000-4000-8000-000000000702'
      AND deleted_at is null
  ),
  1::bigint,
  'move does not duplicate the source image'
);

SELECT results_eq(
  $$
    SELECT dish_id, made_count::bigint
    FROM public.dish_cooking_stats
    WHERE dish_id in (
      '70000000-0000-4000-8000-000000000701',
      '70000000-0000-4000-8000-000000000702'
    )
    ORDER BY dish_id
  $$,
  $$
    VALUES
      ('70000000-0000-4000-8000-000000000701'::uuid, 1::bigint),
      ('70000000-0000-4000-8000-000000000702'::uuid, 1::bigint)
  $$,
  'move keeps both derived cooking counts correct'
);

SELECT lives_ok(
  $$
    SELECT public.api_correct_capture_grouping(
      '73000000-0000-4000-8000-000000000701',
      '30000000-0000-4000-8000-000000000701',
      'move',
      ARRAY['40000000-0000-4000-8000-000000000702'::uuid],
      '70000000-0000-4000-8000-000000000702',
      null
    )
  $$,
  'repeating a move mutation is idempotent'
);

SELECT is(
  (
    SELECT count(*)
    FROM public.capture_grouping_actions
    WHERE id = '73000000-0000-4000-8000-000000000701'
  ),
  1::bigint,
  'idempotent move creates one audit action'
);

SELECT is(
  (
    SELECT organization_source
    FROM public.captures
    WHERE id = '40000000-0000-4000-8000-000000000702'
  ),
  'user',
  'corrected capture is marked user-authored'
);

SELECT throws_ok(
  $$
    SELECT set_config('mymenu.allow_user_capture_correction', 'off', true);
    UPDATE public.captures
    SET applied_dish_id = '70000000-0000-4000-8000-000000000701'
    WHERE id = '40000000-0000-4000-8000-000000000702'
  $$,
  'P0001',
  'User-authored organization for capture 40000000-0000-4000-8000-000000000702 cannot be overwritten',
  'a later grouping replay cannot overwrite user intent'
);

SELECT is(
  (
    public.api_correct_capture_grouping(
      '73000000-0000-4000-8000-000000000702',
      '30000000-0000-4000-8000-000000000701',
      'split',
      ARRAY['40000000-0000-4000-8000-000000000701'::uuid],
      '70000000-0000-4000-8000-000000000703',
      'Glazed Salmon'
    )->>'createdDishId'
  ),
  '70000000-0000-4000-8000-000000000703',
  'split returns the one client-identified dish'
);

SELECT is(
  (
    SELECT count(*)
    FROM public.dishes
    WHERE id = '70000000-0000-4000-8000-000000000703'
      AND deleted_at is null
  ),
  1::bigint,
  'split creates exactly one dish'
);

SELECT is(
  (
    SELECT count(*)
    FROM public.dish_images
    WHERE capture_id = '40000000-0000-4000-8000-000000000701'
      AND dish_id = '70000000-0000-4000-8000-000000000703'
      AND deleted_at is null
  ),
  1::bigint,
  'split creates exactly one active source association'
);

SELECT ok(
  (
    SELECT deleted_at is not null
    FROM public.dishes
    WHERE id = '70000000-0000-4000-8000-000000000701'
  ),
  'split removes an AI dish when all of its photos move away'
);

SELECT lives_ok(
  $$
    SELECT public.api_correct_capture_grouping(
      '73000000-0000-4000-8000-000000000702',
      '30000000-0000-4000-8000-000000000701',
      'split',
      ARRAY['40000000-0000-4000-8000-000000000701'::uuid],
      '70000000-0000-4000-8000-000000000703',
      'Glazed Salmon'
    )
  $$,
  'repeating a split mutation is idempotent'
);

SELECT is(
  (
    SELECT count(*)
    FROM public.capture_grouping_actions
    WHERE id = '73000000-0000-4000-8000-000000000702'
  ),
  1::bigint,
  'idempotent split keeps one audit action'
);

SELECT throws_ok(
  $$
    SELECT public.api_undo_capture_grouping(
      '74000000-0000-4000-8000-000000000701',
      '73000000-0000-4000-8000-000000000701'
    )
  $$,
  'P0001',
  'Only the latest correction can be undone',
  'an older correction cannot be undone out of order'
);

SELECT is(
  (
    public.api_undo_capture_grouping(
      '74000000-0000-4000-8000-000000000702',
      '73000000-0000-4000-8000-000000000702'
    )->>'status'
  ),
  'undone',
  'latest split can be undone'
);

SELECT is(
  (
    SELECT applied_dish_id
    FROM public.captures
    WHERE id = '40000000-0000-4000-8000-000000000701'
  ),
  '70000000-0000-4000-8000-000000000701'::uuid,
  'undo restores the previous capture assignment'
);

SELECT ok(
  (
    SELECT deleted_at is null
    FROM public.dishes
    WHERE id = '70000000-0000-4000-8000-000000000701'
  ),
  'undo restores the AI dish emptied by the split'
);

SELECT ok(
  (
    SELECT deleted_at is not null
    FROM public.dishes
    WHERE id = '70000000-0000-4000-8000-000000000703'
  ),
  'undo removes the empty dish created by split'
);

SELECT lives_ok(
  $$
    SELECT public.api_undo_capture_grouping(
      '74000000-0000-4000-8000-000000000799',
      '73000000-0000-4000-8000-000000000702'
    )
  $$,
  'repeating undo is idempotent'
);

SELECT is(
  (
    public.api_undo_capture_grouping(
      '74000000-0000-4000-8000-000000000703',
      '73000000-0000-4000-8000-000000000701'
    )->>'status'
  ),
  'undone',
  'move can be undone after the later action is removed'
);

SELECT is(
  (
    SELECT count(*)
    FROM public.captures
    WHERE batch_id = '30000000-0000-4000-8000-000000000701'
      AND applied_dish_id = '70000000-0000-4000-8000-000000000701'
  ),
  2::bigint,
  'undo atomically restores the original two-photo group'
);

SELECT throws_ok(
  $$
    SELECT public.api_correct_capture_grouping(
      '73000000-0000-4000-8000-000000000798',
      '30000000-0000-4000-8000-000000000702',
      'move',
      ARRAY['40000000-0000-4000-8000-000000000701'::uuid],
      '70000000-0000-4000-8000-000000000701',
      null
    )
  $$,
  'P0001',
  'Capture group is unavailable',
  'ownership prevents correcting another user batch'
);

SET LOCAL ROLE authenticated;

SELECT is(
  (
    SELECT count(*)
    FROM public.capture_grouping_actions
    WHERE user_id = '00000000-0000-4000-8000-000000000702'
  ),
  0::bigint,
  'RLS hides another user correction audit'
);

SET LOCAL ROLE service_role;

SELECT is(
  has_function_privilege(
    'authenticated',
    'public.api_correct_capture_grouping(uuid,uuid,text,uuid[],uuid,text)',
    'EXECUTE'
  ),
  true,
  'authenticated users can call the correction transaction'
);

SELECT is(
  has_function_privilege(
    'anon',
    'public.api_undo_capture_grouping(uuid,uuid)',
    'EXECUTE'
  ),
  false,
  'anonymous users cannot undo corrections'
);

SELECT is(
  (
    SELECT count(*)
    FROM public.sync_events
    WHERE user_id = '00000000-0000-4000-8000-000000000701'
      AND payload ? 'correctionActionId'
  ) > 0,
  true,
  'correction emits capture sync events'
);

SELECT * FROM finish();
ROLLBACK;
