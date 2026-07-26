create or replace function public.api_upsert_capture_batch(
  p_batch_id uuid,
  p_item_count integer,
  p_created_at timestamptz default now()
)
returns table (
  batch_id uuid,
  status text,
  item_count integer,
  uploaded_item_count integer,
  sync_cursor bigint
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_batch public.capture_batches%rowtype;
  v_cursor bigint;
begin
  if v_user_id is null then
    raise exception 'Authentication required';
  end if;
  if p_item_count < 1 or p_item_count > 9 then
    raise exception 'Capture batch item count must be between 1 and 9';
  end if;

  insert into public.capture_batches (
    id,
    user_id,
    status,
    item_count,
    created_at,
    deleted_at
  )
  values (
    p_batch_id,
    v_user_id,
    'pending_upload',
    p_item_count,
    coalesce(p_created_at, now()),
    null
  )
  on conflict (id) do update set
    item_count = excluded.item_count,
    deleted_at = null
  where public.capture_batches.user_id = v_user_id
  returning * into v_batch;

  if v_batch.id is null then
    raise exception 'Capture batch % belongs to another user', p_batch_id;
  end if;

  v_cursor := public.emit_sync_event(
    v_user_id,
    'capture_batch',
    p_batch_id,
    v_batch.status::text,
    jsonb_build_object(
      'batchId', p_batch_id,
      'itemCount', v_batch.item_count
    )
  );

  return query
  select
    v_batch.id,
    v_batch.status::text,
    v_batch.item_count,
    (
      select count(*)::integer
      from public.captures
      join public.dish_images
        on dish_images.capture_id = captures.id
       and dish_images.deleted_at is null
      where captures.batch_id = v_batch.id
        and captures.user_id = v_user_id
        and captures.deleted_at is null
    ),
    v_cursor;
end;
$$;

create or replace function public.api_create_photo_capture(
  p_user_id uuid,
  p_batch_id uuid,
  p_capture_id uuid,
  p_ordinal integer,
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
  v_batch_cursor bigint;
  v_affected integer;
begin
  if p_ordinal < 0 or p_ordinal > 8 then
    raise exception 'Capture ordinal must be between 0 and 8';
  end if;
  if not exists (
    select 1
    from public.capture_batches
    where id = p_batch_id
      and user_id = p_user_id
      and p_ordinal < item_count
      and deleted_at is null
  ) then
    raise exception 'Capture batch % does not exist or ordinal is invalid', p_batch_id;
  end if;

  insert into public.captures (
    id,
    user_id,
    batch_id,
    ordinal,
    kind,
    status,
    captured_at
  )
  values (
    p_capture_id,
    p_user_id,
    p_batch_id,
    p_ordinal,
    'photo',
    'uploaded',
    coalesce(p_captured_at, now())
  )
  on conflict (id) do update set
    status = 'uploaded',
    deleted_at = null
  where public.captures.user_id = p_user_id
    and public.captures.batch_id = p_batch_id
    and public.captures.ordinal = p_ordinal;

  get diagnostics v_affected = row_count;
  if v_affected = 0 then
    raise exception 'Capture % conflicts with a different user, batch, or ordinal', p_capture_id;
  end if;

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

  update public.capture_batches
  set
    status = 'uploading',
    failure_reason = null,
    deleted_at = null
  where id = p_batch_id
    and user_id = p_user_id;

  v_cursor := public.emit_sync_event(
    p_user_id,
    'capture',
    p_capture_id,
    'uploaded',
    jsonb_build_object(
      'captureId', p_capture_id,
      'batchId', p_batch_id,
      'ordinal', p_ordinal,
      'imageId', v_image_id
    )
  );
  v_batch_cursor := public.emit_sync_event(
    p_user_id,
    'capture_batch',
    p_batch_id,
    'uploading',
    jsonb_build_object('batchId', p_batch_id)
  );

  return query select p_capture_id, v_image_id, greatest(v_cursor, v_batch_cursor);
end;
$$;

-- Keep the original single-photo RPC valid for older clients. It now creates a
-- one-item batch first, which is also the shape used by the legacy migration.
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
  v_result record;
  v_cursor bigint;
begin
  insert into public.capture_batches (
    id,
    user_id,
    status,
    item_count,
    created_at,
    deleted_at
  )
  values (
    p_capture_id,
    p_user_id,
    'processing',
    1,
    coalesce(p_captured_at, now()),
    null
  )
  on conflict (id) do update set
    deleted_at = null
  where public.capture_batches.user_id = p_user_id;

  select *
  into v_result
  from public.api_create_photo_capture(
    p_user_id => p_user_id,
    p_batch_id => p_capture_id,
    p_capture_id => p_capture_id,
    p_ordinal => 0,
    p_storage_path => p_storage_path,
    p_content_type => p_content_type,
    p_byte_size => p_byte_size,
    p_width => p_width,
    p_height => p_height,
    p_sha256 => p_sha256,
    p_captured_at => p_captured_at
  );

  update public.captures
  set status = 'classifying'
  where id = p_capture_id
    and user_id = p_user_id;

  update public.capture_batches
  set status = 'processing'
  where id = p_capture_id
    and user_id = p_user_id;

  v_cursor := public.emit_sync_event(
    p_user_id,
    'capture',
    p_capture_id,
    'classifying',
    jsonb_build_object(
      'captureId', p_capture_id,
      'batchId', p_capture_id,
      'ordinal', 0,
      'imageId', v_result.image_id
    )
  );

  return query select p_capture_id, v_result.image_id::uuid, v_cursor;
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
  insert into public.capture_batches (
    id,
    user_id,
    status,
    item_count,
    created_at,
    deleted_at
  )
  values (
    p_capture_id,
    p_user_id,
    'processing',
    1,
    coalesce(p_captured_at, now()),
    null
  )
  on conflict (id) do update set
    status = 'processing',
    deleted_at = null
  where public.capture_batches.user_id = p_user_id;

  insert into public.captures (
    id,
    user_id,
    batch_id,
    ordinal,
    kind,
    status,
    idea_text,
    captured_at
  )
  values (
    p_capture_id,
    p_user_id,
    p_capture_id,
    0,
    'idea',
    'classifying',
    p_idea_text,
    coalesce(p_captured_at, now())
  )
  on conflict (id) do update set
    status = excluded.status,
    idea_text = excluded.idea_text,
    deleted_at = null
  where public.captures.user_id = p_user_id
    and public.captures.batch_id = p_capture_id
    and public.captures.ordinal = 0;

  v_cursor := public.emit_sync_event(
    p_user_id,
    'capture',
    p_capture_id,
    'classifying',
    jsonb_build_object(
      'captureId', p_capture_id,
      'batchId', p_capture_id,
      'ordinal', 0
    )
  );

  return query select p_capture_id, v_cursor;
end;
$$;

create or replace function public.api_mark_capture_batch_ready(
  p_batch_id uuid
)
returns table (
  batch_id uuid,
  status text,
  ready boolean,
  uploaded_item_count integer,
  sync_cursor bigint
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_expected integer;
  v_uploaded integer;
  v_ready boolean;
  v_status public.capture_batch_status;
  v_cursor bigint;
begin
  if v_user_id is null then
    raise exception 'Authentication required';
  end if;

  select capture_batches.item_count
  into v_expected
  from public.capture_batches
  where capture_batches.id = p_batch_id
    and capture_batches.user_id = v_user_id
    and capture_batches.deleted_at is null;

  if v_expected is null then
    raise exception 'Capture batch % does not exist', p_batch_id;
  end if;

  select count(distinct captures.id)::integer
  into v_uploaded
  from public.captures
  join public.dish_images
    on dish_images.capture_id = captures.id
   and dish_images.deleted_at is null
  where captures.batch_id = p_batch_id
    and captures.user_id = v_user_id
    and captures.status <> 'discarded'
    and captures.deleted_at is null;

  v_ready := v_uploaded = v_expected;
  v_status := case
    when v_ready then 'ready_for_ai'::public.capture_batch_status
    else 'uploading'::public.capture_batch_status
  end;

  update public.capture_batches
  set status = v_status
  where id = p_batch_id
    and user_id = v_user_id;

  v_cursor := public.emit_sync_event(
    v_user_id,
    'capture_batch',
    p_batch_id,
    v_status::text,
    jsonb_build_object(
      'batchId', p_batch_id,
      'uploadedItemCount', v_uploaded,
      'itemCount', v_expected
    )
  );

  return query
  select p_batch_id, v_status::text, v_ready, v_uploaded, v_cursor;
end;
$$;

create or replace function public.api_get_capture_batches(
  p_ids uuid[] default null
)
returns table (
  batch_id uuid,
  status text,
  item_count integer,
  uploaded_item_count integer,
  captures jsonb,
  created_at timestamptz,
  updated_at timestamptz
)
language sql
security definer
set search_path = public
as $$
  select
    batches.id,
    batches.status::text,
    batches.item_count,
    count(images.id)::integer,
    coalesce(
      jsonb_agg(
        jsonb_build_object(
          'captureId', captures.id,
          'ordinal', captures.ordinal,
          'status', captures.status::text,
          'imageId', images.id
        )
        order by captures.ordinal
      ) filter (where captures.id is not null),
      '[]'::jsonb
    ),
    batches.created_at,
    batches.updated_at
  from public.capture_batches batches
  left join public.captures captures
    on captures.batch_id = batches.id
   and captures.deleted_at is null
  left join public.dish_images images
    on images.capture_id = captures.id
   and images.deleted_at is null
  where batches.user_id = auth.uid()
    and batches.deleted_at is null
    and (p_ids is null or batches.id = any(p_ids))
  group by batches.id
  order by batches.created_at desc;
$$;

create or replace function public.api_pull_events(
  p_user_id uuid,
  p_after_cursor bigint default 0,
  p_limit integer default 200
)
returns table (
  cursor bigint,
  has_more boolean,
  events jsonb,
  requires_bootstrap boolean
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_after_cursor bigint := greatest(coalesce(p_after_cursor, 0), 0);
  v_limit integer := least(greatest(coalesce(p_limit, 200), 1), 200);
begin
  return query
  with candidate as (
    select
      sync_events.id,
      sync_events.entity_type,
      sync_events.entity_id,
      sync_events.operation,
      sync_events.payload
    from public.sync_events
    where sync_events.user_id = p_user_id
      and sync_events.id > v_after_cursor
    order by sync_events.id
    limit v_limit + 1
  ),
  stats as (
    select count(*) as total_count from candidate
  ),
  returned as (
    select * from candidate order by candidate.id limit v_limit
  )
  select
    coalesce(max(returned.id), v_after_cursor)::bigint,
    ((select total_count from stats) > v_limit)::boolean,
    coalesce(
      jsonb_agg(
        jsonb_build_object(
          'cursor', returned.id,
          'type', returned.entity_type || '.' || returned.operation,
          'entityIds',
            coalesce(returned.payload, '{}'::jsonb) ||
            jsonb_build_object(
              case returned.entity_type
                when 'capture_batch' then 'batchId'
                when 'capture' then 'captureId'
                when 'dish' then 'dishId'
                when 'review_item' then 'reviewItemId'
                when 'planned_meal' then 'plannedMealId'
                else 'entityId'
              end,
              returned.entity_id
            )
        )
        order by returned.id
      ),
      '[]'::jsonb
    ),
    false::boolean
  from returned;
end;
$$;

revoke all on function public.api_upsert_capture_batch(
  uuid,
  integer,
  timestamptz
) from public, anon, authenticated;

grant execute on function public.api_upsert_capture_batch(
  uuid,
  integer,
  timestamptz
) to authenticated;

revoke all on function public.api_create_photo_capture(
  uuid,
  uuid,
  uuid,
  integer,
  text,
  text,
  bigint,
  integer,
  integer,
  text,
  timestamptz
) from public, anon, authenticated;

grant execute on function public.api_create_photo_capture(
  uuid,
  uuid,
  uuid,
  integer,
  text,
  text,
  bigint,
  integer,
  integer,
  text,
  timestamptz
) to service_role;

-- The legacy overloads also accept an explicit user id. Keep them callable by
-- trusted backend code and older Edge Functions, but not directly by clients.
revoke all on function public.api_create_photo_capture(
  uuid,
  uuid,
  text,
  text,
  bigint,
  integer,
  integer,
  text,
  timestamptz
) from public, anon, authenticated;

grant execute on function public.api_create_photo_capture(
  uuid,
  uuid,
  text,
  text,
  bigint,
  integer,
  integer,
  text,
  timestamptz
) to service_role;

revoke all on function public.api_create_idea_capture(
  uuid,
  uuid,
  text,
  timestamptz
) from public, anon, authenticated;

grant execute on function public.api_create_idea_capture(
  uuid,
  uuid,
  text,
  timestamptz
) to service_role;

revoke all on function public.api_mark_capture_batch_ready(uuid)
from public, anon, authenticated;

grant execute on function public.api_mark_capture_batch_ready(uuid)
to authenticated;

revoke all on function public.api_get_capture_batches(uuid[])
from public, anon, authenticated;

grant execute on function public.api_get_capture_batches(uuid[])
to authenticated;

notify pgrst, 'reload schema';
