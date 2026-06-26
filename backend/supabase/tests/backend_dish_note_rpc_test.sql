BEGIN;
SELECT plan(12);

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
  VALUES
    (
      '00000000-0000-4000-8000-000000000101',
      '00000000-0000-0000-0000-000000000000',
      'authenticated',
      'authenticated',
      'dish-note-rpc-a@example.com',
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
      'dish-note-rpc-b@example.com',
      '',
      now(),
      now(),
      now()
    )
  ON CONFLICT (id) DO NOTHING;
END
$$;

INSERT INTO public.dishes (
  id,
  user_id,
  title,
  description
)
VALUES
  (
    '20000000-0000-4000-8000-000000000101',
    '00000000-0000-4000-8000-000000000101',
    'Note Test Dish',
    'Owned by user A.'
  ),
  (
    '20000000-0000-4000-8000-000000000102',
    '00000000-0000-4000-8000-000000000102',
    'Other Dish',
    'Owned by user B.'
  );

SELECT is(
  (SELECT note_id FROM public.api_create_dish_note(
    '00000000-0000-4000-8000-000000000101',
    '30000000-0000-4000-8000-000000000101',
    '20000000-0000-4000-8000-000000000101',
    'Use more lemon.',
    0
  )),
  '30000000-0000-4000-8000-000000000101'::uuid,
  'api_create_dish_note returns note id'
);

SELECT is(
  (SELECT body FROM public.dish_notes WHERE id = '30000000-0000-4000-8000-000000000101'),
  'Use more lemon.',
  'api_create_dish_note stores note body'
);

SELECT is(
  (SELECT position FROM public.dish_notes WHERE id = '30000000-0000-4000-8000-000000000101'),
  0,
  'api_create_dish_note stores note position'
);

SELECT is(
  (SELECT note_id FROM public.api_update_dish_note(
    '00000000-0000-4000-8000-000000000101',
    '30000000-0000-4000-8000-000000000101',
    'Use more lemon zest.',
    2
  )),
  '30000000-0000-4000-8000-000000000101'::uuid,
  'api_update_dish_note returns note id'
);

SELECT is(
  (SELECT body FROM public.dish_notes WHERE id = '30000000-0000-4000-8000-000000000101'),
  'Use more lemon zest.',
  'api_update_dish_note updates body'
);

SELECT is(
  (SELECT position FROM public.dish_notes WHERE id = '30000000-0000-4000-8000-000000000101'),
  2,
  'api_update_dish_note updates position'
);

SELECT is(
  (SELECT count(*) FROM public.sync_events WHERE entity_type = 'dish_note'),
  2::bigint,
  'note create and update emit sync events'
);

SELECT throws_ok(
  $$ SELECT * FROM public.api_update_dish_note(
    '00000000-0000-4000-8000-000000000102',
    '30000000-0000-4000-8000-000000000101',
    'Wrong user.',
    null
  ) $$,
  'P0002',
  'Dish note not found',
  'api_update_dish_note enforces ownership'
);

SELECT is(
  (SELECT note_id FROM public.api_delete_dish_note(
    '00000000-0000-4000-8000-000000000101',
    '30000000-0000-4000-8000-000000000101'
  )),
  '30000000-0000-4000-8000-000000000101'::uuid,
  'api_delete_dish_note returns note id'
);

SELECT is(
  (SELECT deleted_at IS NOT NULL FROM public.dish_notes WHERE id = '30000000-0000-4000-8000-000000000101'),
  true,
  'api_delete_dish_note soft deletes note'
);

SELECT is(
  (SELECT count(*) FROM public.sync_events WHERE entity_type = 'dish_note'),
  3::bigint,
  'note delete emits sync event'
);

SELECT throws_ok(
  $$ SELECT * FROM public.api_create_dish_note(
    '00000000-0000-4000-8000-000000000101',
    '30000000-0000-4000-8000-000000000102',
    '20000000-0000-4000-8000-000000000102',
    'Wrong parent.',
    0
  ) $$,
  'P0002',
  'Dish note parent not found',
  'api_create_dish_note enforces parent ownership'
);

SELECT * FROM finish();
ROLLBACK;
