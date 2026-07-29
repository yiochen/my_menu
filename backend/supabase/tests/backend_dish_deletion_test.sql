begin;
select plan(21);

insert into auth.users (
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
values
  (
    '00000000-0000-4000-8000-000000000901',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'dish-delete-one@example.com',
    '',
    now(),
    now(),
    now()
  ),
  (
    '00000000-0000-4000-8000-000000000902',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'dish-delete-two@example.com',
    '',
    now(),
    now(),
    now()
  )
on conflict (id) do nothing;

select set_config('request.jwt.claim.role', 'service_role', true);

insert into public.capture_batches (id, user_id, status, item_count)
values (
  '30000000-0000-4000-8000-000000000901',
  '00000000-0000-4000-8000-000000000901',
  'applied',
  2
);

insert into public.dishes (
  id, user_id, title, description, creation_source
)
values
  (
    '70000000-0000-4000-8000-000000000901',
    '00000000-0000-4000-8000-000000000901',
    'Zero History Idea',
    'A valid idea without cooking history.',
    'manual'
  ),
  (
    '70000000-0000-4000-8000-000000000902',
    '00000000-0000-4000-8000-000000000901',
    'Cooked Dish',
    'Has every related record type.',
    'ai_capture'
  ),
  (
    '70000000-0000-4000-8000-000000000903',
    '00000000-0000-4000-8000-000000000901',
    'Keep Dish',
    'Shares the original capture group.',
    'ai_capture'
  ),
  (
    '70000000-0000-4000-8000-000000000999',
    '00000000-0000-4000-8000-000000000902',
    'Another User Dish',
    'Must never be deleted.',
    'manual'
  );

insert into public.captures (
  id, user_id, batch_id, ordinal, kind, status, applied_dish_id, captured_at
)
values
  (
    '40000000-0000-4000-8000-000000000901',
    '00000000-0000-4000-8000-000000000901',
    '30000000-0000-4000-8000-000000000901',
    0,
    'photo',
    'applied',
    '70000000-0000-4000-8000-000000000902',
    '2026-07-28T10:00:00Z'
  ),
  (
    '40000000-0000-4000-8000-000000000902',
    '00000000-0000-4000-8000-000000000901',
    '30000000-0000-4000-8000-000000000901',
    1,
    'photo',
    'applied',
    '70000000-0000-4000-8000-000000000903',
    '2026-07-28T10:01:00Z'
  );

insert into public.cooking_occasions (
  id, user_id, batch_id, dish_id, grouping_key, local_date
)
values
  (
    '71000000-0000-4000-8000-000000000901',
    '00000000-0000-4000-8000-000000000901',
    '30000000-0000-4000-8000-000000000901',
    '70000000-0000-4000-8000-000000000902',
    'delete:cooked',
    '2026-07-28'
  ),
  (
    '71000000-0000-4000-8000-000000000902',
    '00000000-0000-4000-8000-000000000901',
    '30000000-0000-4000-8000-000000000901',
    '70000000-0000-4000-8000-000000000903',
    'delete:keep',
    '2026-07-28'
  );

insert into public.dish_images (
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
values
  (
    '72000000-0000-4000-8000-000000000901',
    '00000000-0000-4000-8000-000000000901',
    '70000000-0000-4000-8000-000000000902',
    '40000000-0000-4000-8000-000000000901',
    '71000000-0000-4000-8000-000000000901',
    'source_photo',
    'users/901/captures/delete.jpg',
    'image/jpeg',
    '2026-07-28T10:00:00Z'
  ),
  (
    '72000000-0000-4000-8000-000000000902',
    '00000000-0000-4000-8000-000000000901',
    '70000000-0000-4000-8000-000000000902',
    null,
    null,
    'ai_generated',
    'users/901/covers/delete.png',
    'image/png',
    null
  ),
  (
    '72000000-0000-4000-8000-000000000903',
    '00000000-0000-4000-8000-000000000901',
    '70000000-0000-4000-8000-000000000903',
    '40000000-0000-4000-8000-000000000902',
    '71000000-0000-4000-8000-000000000902',
    'source_photo',
    'users/901/captures/keep.jpg',
    'image/jpeg',
    '2026-07-28T10:01:00Z'
  );

update public.dishes
set cover_image_id = '72000000-0000-4000-8000-000000000902'
where id = '70000000-0000-4000-8000-000000000902';

insert into public.dish_notes (
  id, user_id, dish_id, body, position
)
values
  (
    '74000000-0000-4000-8000-000000000901',
    '00000000-0000-4000-8000-000000000901',
    '70000000-0000-4000-8000-000000000902',
    'Delete this note.',
    0
  ),
  (
    '74000000-0000-4000-8000-000000000902',
    '00000000-0000-4000-8000-000000000901',
    '70000000-0000-4000-8000-000000000901',
    'Ideas can have notes too.',
    0
  );

insert into public.dish_ingredients (id, user_id, dish_id, body, position)
values (
  '75000000-0000-4000-8000-000000000901',
  '00000000-0000-4000-8000-000000000901',
  '70000000-0000-4000-8000-000000000902',
  'ingredient',
  0
);

insert into public.dish_steps (id, user_id, dish_id, body, position)
values (
  '76000000-0000-4000-8000-000000000901',
  '00000000-0000-4000-8000-000000000901',
  '70000000-0000-4000-8000-000000000902',
  'step',
  0
);

insert into public.planned_meals (
  id, user_id, dish_id, day_key, position
)
values (
  '77000000-0000-4000-8000-000000000901',
  '00000000-0000-4000-8000-000000000901',
  '70000000-0000-4000-8000-000000000902',
  '2026-07-30',
  0
);

insert into public.review_items (
  id,
  user_id,
  capture_id,
  status,
  summary,
  suggested_dish_ids
)
values (
  '78000000-0000-4000-8000-000000000901',
  '00000000-0000-4000-8000-000000000901',
  '40000000-0000-4000-8000-000000000902',
  'open',
  'Keep this review but remove the deleted suggestion.',
  array['70000000-0000-4000-8000-000000000902'::uuid]
);

insert into public.ai_jobs (
  id,
  user_id,
  job_type,
  subject_id,
  status,
  idempotency_key,
  input_hash,
  input_version
)
values
  (
    '79000000-0000-4000-8000-000000000901',
    '00000000-0000-4000-8000-000000000901',
    'cover_generation',
    '70000000-0000-4000-8000-000000000902',
    'succeeded',
    'delete-cover-job',
    'hash',
    '1'
  ),
  (
    '79000000-0000-4000-8000-000000000902',
    '00000000-0000-4000-8000-000000000901',
    'batch_grouping',
    '30000000-0000-4000-8000-000000000901',
    'succeeded',
    'keep-shared-batch-job',
    'hash',
    '1'
  );

insert into public.capture_grouping_actions (
  id,
  user_id,
  batch_id,
  action_type,
  capture_ids,
  target_dish_id,
  previous_assignments,
  status
)
values (
  '73000000-0000-4000-8000-000000000901',
  '00000000-0000-4000-8000-000000000901',
  '30000000-0000-4000-8000-000000000901',
  'move',
  array['40000000-0000-4000-8000-000000000901'::uuid],
  '70000000-0000-4000-8000-000000000903',
  jsonb_build_array(
    jsonb_build_object(
      'captureId', '40000000-0000-4000-8000-000000000901',
      'dishId', '70000000-0000-4000-8000-000000000902'
    )
  ),
  'applied'
);

update public.captures
set organization_action_id = '73000000-0000-4000-8000-000000000901'
where id = '40000000-0000-4000-8000-000000000901';

select is(
  jsonb_array_length(
    public.internal_prepare_dish_deletion(
      '00000000-0000-4000-8000-000000000901',
      array[
        '70000000-0000-4000-8000-000000000901'::uuid,
        '70000000-0000-4000-8000-000000000902'::uuid
      ]
    )->'storageObjects'
  ),
  2,
  'deletion plan includes source and generated cover objects'
);

select lives_ok(
  $$
    select *
    from public.internal_delete_dishes(
      '00000000-0000-4000-8000-000000000901',
      array[
        '70000000-0000-4000-8000-000000000901'::uuid,
        '70000000-0000-4000-8000-000000000902'::uuid,
        '70000000-0000-4000-8000-000000000999'::uuid
      ]
    )
  $$,
  'service deletion accepts ideas, cooked dishes, and inaccessible ids'
);

select is(
  (
    select count(*)
    from public.dishes
    where id in (
      '70000000-0000-4000-8000-000000000901',
      '70000000-0000-4000-8000-000000000902'
    )
  ),
  0::bigint,
  'owned idea and cooked dish rows are hard deleted'
);

select is(
  (
    select count(*)
    from public.dishes
    where id in (
      '70000000-0000-4000-8000-000000000903',
      '70000000-0000-4000-8000-000000000999'
    )
  ),
  2::bigint,
  'shared-batch and other-user dishes remain'
);

select is(
  (select count(*) from public.dish_notes where user_id = '00000000-0000-4000-8000-000000000901'),
  0::bigint,
  'notes for both selected dish states are deleted'
);
select is(
  (select count(*) from public.dish_ingredients where dish_id = '70000000-0000-4000-8000-000000000902'),
  0::bigint,
  'ingredients are deleted'
);
select is(
  (select count(*) from public.dish_steps where dish_id = '70000000-0000-4000-8000-000000000902'),
  0::bigint,
  'recipe steps are deleted'
);
select is(
  (select count(*) from public.planned_meals where dish_id = '70000000-0000-4000-8000-000000000902'),
  0::bigint,
  'planned meals are deleted'
);
select is(
  (select count(*) from public.cooking_occasions where dish_id = '70000000-0000-4000-8000-000000000902'),
  0::bigint,
  'cooking history occasions are deleted'
);
select is(
  (select count(*) from public.dish_images where id in (
    '72000000-0000-4000-8000-000000000901',
    '72000000-0000-4000-8000-000000000902'
  )),
  0::bigint,
  'source and generated image rows are deleted'
);
select is(
  (select count(*) from public.captures where id = '40000000-0000-4000-8000-000000000901'),
  0::bigint,
  'source capture is deleted'
);
select is(
  (select count(*) from public.capture_grouping_actions where id = '73000000-0000-4000-8000-000000000901'),
  0::bigint,
  'related correction audit is deleted'
);
select is(
  (select count(*) from public.ai_jobs where id = '79000000-0000-4000-8000-000000000901'),
  0::bigint,
  'dish-scoped AI metadata is deleted'
);
select is(
  (select count(*) from public.ai_jobs where id = '79000000-0000-4000-8000-000000000902'),
  1::bigint,
  'shared capture-group AI metadata remains'
);
select is(
  (select item_count from public.capture_batches where id = '30000000-0000-4000-8000-000000000901'),
  1,
  'shared capture group is retained with an accurate item count'
);
select is(
  (select count(*) from public.captures where id = '40000000-0000-4000-8000-000000000902'),
  1::bigint,
  'unselected source capture remains'
);
select is(
  (select count(*) from public.dish_images where id = '72000000-0000-4000-8000-000000000903'),
  1::bigint,
  'unselected source image remains'
);
select is(
  (
    select cardinality(suggested_dish_ids)
    from public.review_items
    where id = '78000000-0000-4000-8000-000000000901'
  ),
  0,
  'deleted dish ids are removed from surviving review suggestions'
);
select is(
  (
    select count(*)
    from public.sync_events
    where user_id = '00000000-0000-4000-8000-000000000901'
      and entity_type = 'dish'
      and operation = 'deleted'
  ),
  2::bigint,
  'one dish tombstone is emitted for each deleted dish'
);
select is(
  (
    select count(*)
    from public.sync_events
    where user_id = '00000000-0000-4000-8000-000000000901'
      and entity_type = 'capture'
      and operation = 'deleted'
  ),
  1::bigint,
  'deleted source capture emits a tombstone'
);
select is(
  has_function_privilege(
    'authenticated',
    'public.internal_delete_dishes(uuid,uuid[])',
    'EXECUTE'
  ),
  false,
  'authenticated clients cannot bypass the deletion edge function'
);

select * from finish();
rollback;
