create or replace function public.api_create_photo_capture(
  p_user_id uuid,
  p_capture_id uuid,
  p_storage_path text,
  p_content_type text,
  p_byte_size bigint default null,
  p_width integer default null,
  p_height integer default null,
  p_sha256 text default null,
  p_captured_at timestamptz default now()
)
returns table (
  capture_id uuid,
  image_id uuid,
  sync_cursor bigint
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_image_id uuid;
  v_cursor bigint;
begin
  insert into public.captures (
    id,
    user_id,
    kind,
    status,
    captured_at
  )
  values (
    p_capture_id,
    p_user_id,
    'photo',
    'classifying',
    coalesce(p_captured_at, now())
  )
  on conflict (id) do update set
    status = excluded.status,
    deleted_at = null
  where public.captures.user_id = p_user_id;

  insert into public.dish_images (
    id,
    user_id,
    capture_id,
    kind,
    storage_path,
    content_type,
    byte_size,
    width,
    height,
    sha256,
    captured_at
  )
  values (
    gen_random_uuid(),
    p_user_id,
    p_capture_id,
    'capture_photo',
    p_storage_path,
    p_content_type,
    p_byte_size,
    p_width,
    p_height,
    p_sha256,
    coalesce(p_captured_at, now())
  )
  on conflict (user_id, storage_bucket, storage_path) do update set
    capture_id = excluded.capture_id,
    kind = excluded.kind,
    content_type = excluded.content_type,
    byte_size = excluded.byte_size,
    width = excluded.width,
    height = excluded.height,
    sha256 = excluded.sha256,
    deleted_at = null
  returning id into v_image_id;

  v_cursor := public.emit_sync_event(
    p_user_id,
    'capture',
    p_capture_id,
    'upsert',
    jsonb_build_object('imageId', v_image_id)
  );

  return query select p_capture_id::uuid, v_image_id::uuid, v_cursor::bigint;
end;
$$;

create or replace function public.api_create_idea_capture(
  p_user_id uuid,
  p_capture_id uuid,
  p_idea_text text,
  p_captured_at timestamptz default now()
)
returns table (
  capture_id uuid,
  sync_cursor bigint
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_cursor bigint;
begin
  insert into public.captures (
    id,
    user_id,
    kind,
    status,
    idea_text,
    captured_at
  )
  values (
    p_capture_id,
    p_user_id,
    'idea',
    'classifying',
    p_idea_text,
    coalesce(p_captured_at, now())
  )
  on conflict (id) do update set
    status = excluded.status,
    idea_text = excluded.idea_text,
    deleted_at = null
  where public.captures.user_id = p_user_id;

  v_cursor := public.emit_sync_event(p_user_id, 'capture', p_capture_id, 'upsert');

  return query select p_capture_id::uuid, v_cursor::bigint;
end;
$$;

create or replace function public.api_create_dish_from_capture(
  p_user_id uuid,
  p_capture_id uuid,
  p_dish_id uuid,
  p_title text,
  p_description text default '',
  p_labels text[] default '{}',
  p_confidence_label text default null
)
returns table (
  capture_id uuid,
  dish_id uuid,
  source_image_id uuid,
  sync_cursor bigint
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_source_image_id uuid;
  v_cursor bigint;
begin
  insert into public.dishes (
    id,
    user_id,
    title,
    description,
    labels,
    creation_source,
    created_from_capture_id
  )
  values (
    p_dish_id,
    p_user_id,
    p_title,
    coalesce(p_description, ''),
    coalesce(p_labels, '{}'),
    'ai_capture',
    p_capture_id
  )
  on conflict (id) do update set
    title = excluded.title,
    description = excluded.description,
    labels = excluded.labels,
    deleted_at = null
  where public.dishes.user_id = p_user_id;

  update public.dish_images
  set
    dish_id = p_dish_id,
    kind = 'source_photo',
    confidence_label = p_confidence_label,
    deleted_at = null
  where public.dish_images.capture_id = p_capture_id
    and public.dish_images.user_id = p_user_id
    and public.dish_images.kind in ('capture_photo', 'source_photo')
  returning id into v_source_image_id;

  update public.captures
  set
    status = 'applied',
    applied_dish_id = p_dish_id,
    deleted_at = null
  where id = p_capture_id
    and user_id = p_user_id;

  v_cursor := public.emit_sync_event(
    p_user_id,
    'dish',
    p_dish_id,
    'upsert',
    jsonb_build_object(
      'captureId', p_capture_id,
      'sourceImageId', v_source_image_id
    )
  );

  return query select p_capture_id::uuid, p_dish_id::uuid, v_source_image_id::uuid, v_cursor::bigint;
end;
$$;

create or replace function public.api_discard_capture(
  p_user_id uuid,
  p_capture_id uuid
)
returns table (
  capture_id uuid,
  sync_cursor bigint
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_cursor bigint;
begin
  update public.captures
  set status = 'discarded'
  where id = p_capture_id
    and user_id = p_user_id;

  v_cursor := public.emit_sync_event(p_user_id, 'capture', p_capture_id, 'discard');

  return query select p_capture_id::uuid, v_cursor::bigint;
end;
$$;


notify pgrst, 'reload schema';
