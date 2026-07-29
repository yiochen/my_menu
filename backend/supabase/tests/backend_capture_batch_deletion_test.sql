begin;
select plan(14);

insert into auth.users (
  id, instance_id, aud, role, email, encrypted_password,
  email_confirmed_at, created_at, updated_at
)
values
  (
    '00000000-0000-4000-8000-000000000920',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'batch-delete@example.com', '',
    now(), now(), now()
  ),
  (
    '00000000-0000-4000-8000-000000000921',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'batch-keep@example.com', '',
    now(), now(), now()
  )
on conflict (id) do nothing;

select set_config('request.jwt.claim.role', 'service_role', true);

insert into public.capture_batches (
  id, user_id, status, item_count
)
values
  (
    '30000000-0000-4000-8000-000000000920',
    '00000000-0000-4000-8000-000000000920',
    'uploading',
    2
  ),
  (
    '30000000-0000-4000-8000-000000000921',
    '00000000-0000-4000-8000-000000000920',
    'applied',
    1
  ),
  (
    '30000000-0000-4000-8000-000000000922',
    '00000000-0000-4000-8000-000000000921',
    'uploading',
    1
  );

insert into public.captures (
  id, user_id, batch_id, ordinal, kind, status
)
values
  (
    '40000000-0000-4000-8000-000000000920',
    '00000000-0000-4000-8000-000000000920',
    '30000000-0000-4000-8000-000000000920',
    0, 'photo', 'uploaded'
  ),
  (
    '40000000-0000-4000-8000-000000000921',
    '00000000-0000-4000-8000-000000000920',
    '30000000-0000-4000-8000-000000000920',
    1, 'photo', 'classifying'
  ),
  (
    '40000000-0000-4000-8000-000000000922',
    '00000000-0000-4000-8000-000000000920',
    '30000000-0000-4000-8000-000000000921',
    0, 'photo', 'applied'
  );

insert into public.dishes (
  id, user_id, title, description, creation_source
)
values (
  '70000000-0000-4000-8000-000000000920',
  '00000000-0000-4000-8000-000000000920',
  'Race Result Dish',
  'Grouping finished during the Undo window.',
  'ai_capture'
);

update public.captures
set applied_dish_id = '70000000-0000-4000-8000-000000000920'
where id = '40000000-0000-4000-8000-000000000922';

update public.dishes
set created_from_capture_id = '40000000-0000-4000-8000-000000000922'
where id = '70000000-0000-4000-8000-000000000920';

insert into public.dish_images (
  id, user_id, capture_id, kind, storage_path, content_type
)
values (
  '50000000-0000-4000-8000-000000000920',
  '00000000-0000-4000-8000-000000000920',
  '40000000-0000-4000-8000-000000000920',
  'capture_photo',
  'users/920/captures/pending.jpg',
  'image/jpeg'
);

insert into public.review_items (
  id, user_id, capture_id, summary
)
values (
  '60000000-0000-4000-8000-000000000920',
  '00000000-0000-4000-8000-000000000920',
  '40000000-0000-4000-8000-000000000921',
  'Pending review'
);

insert into public.ai_jobs (
  id, user_id, job_type, subject_id, status, idempotency_key,
  input_hash, input_version
)
values (
  '80000000-0000-4000-8000-000000000920',
  '00000000-0000-4000-8000-000000000920',
  'batch_grouping',
  '30000000-0000-4000-8000-000000000920',
  'queued',
  'delete-pending-batch',
  'hash',
  '1'
);

select is(
  jsonb_array_length(
    public.internal_prepare_capture_batch_deletion(
      '00000000-0000-4000-8000-000000000920',
      '30000000-0000-4000-8000-000000000920'
    )->'storageObjects'
  ),
  1,
  'deletion plan contains the partially uploaded storage object'
);

select is(
  (
    select status::text
    from public.capture_batches
    where id = '30000000-0000-4000-8000-000000000920'
  ),
  'discarded',
  'preparing deletion stops further batch processing'
);

select lives_ok(
  $$
    select public.internal_delete_capture_batch(
      '00000000-0000-4000-8000-000000000920',
      '30000000-0000-4000-8000-000000000920'
    )
  $$,
  'pending batch deletion succeeds'
);

select is(
  (select count(*) from public.capture_batches
   where id = '30000000-0000-4000-8000-000000000920'),
  0::bigint,
  'pending batch row is deleted'
);

select is(
  (select count(*) from public.captures
   where batch_id = '30000000-0000-4000-8000-000000000920'),
  0::bigint,
  'pending captures are deleted'
);

select is(
  (
    select count(*)
    from public.dish_images
    where id = '50000000-0000-4000-8000-000000000920'
  ) + (
    select count(*)
    from public.review_items
    where id = '60000000-0000-4000-8000-000000000920'
  ),
  0::bigint,
  'pending media and review rows are deleted'
);

select is(
  (select count(*) from public.ai_jobs
   where id = '80000000-0000-4000-8000-000000000920'),
  0::bigint,
  'pending organization job is deleted'
);

select lives_ok(
  $$
    select public.internal_prepare_capture_batch_deletion(
      '00000000-0000-4000-8000-000000000920',
      '30000000-0000-4000-8000-000000000921'
    )
  $$,
  'a grouping result that arrived during Undo can still be removed'
);

select lives_ok(
  $$
    select public.internal_delete_capture_batch(
      '00000000-0000-4000-8000-000000000920',
      '30000000-0000-4000-8000-000000000921'
    )
  $$,
  'committing the staged removal deletes the completed grouping'
);

select is(
  (
    select count(*) from public.capture_batches
    where id = '30000000-0000-4000-8000-000000000921'
  ) + (
    select count(*) from public.dishes
    where id = '70000000-0000-4000-8000-000000000920'
  ) + (
    select count(*) from public.captures
    where id = '40000000-0000-4000-8000-000000000922'
  ),
  0::bigint,
  'the completed result dish, capture, and batch are deleted together'
);

select is(
  (select count(*) from public.capture_batches
   where id = '30000000-0000-4000-8000-000000000922'),
  1::bigint,
  'another user batch is preserved'
);

select is(
  (
    select count(*)
    from public.sync_events
    where user_id = '00000000-0000-4000-8000-000000000920'
      and entity_type = 'capture_batch'
      and entity_id = '30000000-0000-4000-8000-000000000920'
      and operation = 'deleted'
  ),
  1::bigint,
  'deleted batch emits a sync tombstone'
);

select lives_ok(
  $$
    select public.internal_delete_capture_batch(
      '00000000-0000-4000-8000-000000000920',
      '30000000-0000-4000-8000-000000000920'
    )
  $$,
  'repeating deletion is safe'
);

select is(
  has_function_privilege(
    'authenticated',
    'public.internal_delete_capture_batch(uuid,uuid)',
    'EXECUTE'
  ),
  false,
  'authenticated clients cannot bypass the deletion edge function'
);

select * from finish();
rollback;
