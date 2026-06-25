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
    'classifying',
    jsonb_build_object(
      'captureId', p_capture_id,
      'imageId', v_image_id
    )
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

  v_cursor := public.emit_sync_event(
    p_user_id,
    'capture',
    p_capture_id,
    'classifying',
    jsonb_build_object('captureId', p_capture_id)
  );

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
    'capture',
    p_capture_id,
    'applied_to_new_dish',
    jsonb_build_object(
      'captureId', p_capture_id,
      'dishId', p_dish_id,
      'sourceImageId', v_source_image_id
    )
  );

  return query select
    p_capture_id::uuid,
    p_dish_id::uuid,
    v_source_image_id::uuid,
    v_cursor::bigint;
end;
$$;

create or replace function public.api_apply_capture_to_dish(
  p_user_id uuid,
  p_capture_id uuid,
  p_dish_id uuid,
  p_confidence_label text default null,
  p_note text default null,
  p_labels text[] default '{}'
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
  update public.dishes
  set
    labels = (
      select coalesce(array_agg(distinct label order by label), '{}')
      from unnest(public.dishes.labels || coalesce(p_labels, '{}')) as label
    ),
    deleted_at = null
  where id = p_dish_id
    and user_id = p_user_id;

  if not found then
    raise exception 'Dish % does not exist for user %', p_dish_id, p_user_id;
  end if;

  update public.dish_images
  set
    dish_id = p_dish_id,
    kind = 'source_photo',
    note = nullif(p_note, ''),
    labels = coalesce(p_labels, '{}'),
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

  if not found then
    raise exception 'Capture % does not exist for user %', p_capture_id, p_user_id;
  end if;

  v_cursor := public.emit_sync_event(
    p_user_id,
    'capture',
    p_capture_id,
    'applied_to_existing_dish',
    jsonb_build_object(
      'captureId', p_capture_id,
      'dishId', p_dish_id,
      'sourceImageId', v_source_image_id
    )
  );

  return query select
    p_capture_id::uuid,
    p_dish_id::uuid,
    v_source_image_id::uuid,
    v_cursor::bigint;
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

  v_cursor := public.emit_sync_event(
    p_user_id,
    'capture',
    p_capture_id,
    'discarded',
    jsonb_build_object('captureId', p_capture_id)
  );

  return query select p_capture_id::uuid, v_cursor::bigint;
end;
$$;

create or replace function public.api_schedule_capture_processing(
  p_user_id uuid,
  p_capture_id uuid,
  p_function_url text,
  p_worker_key text,
  p_remote_media_ref text default null,
  p_idea_text text default null
)
returns table (
  capture_id uuid,
  status text,
  request_id bigint,
  sync_cursor bigint
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_cursor bigint;
  v_request_id bigint;
  v_trimmed_idea text;
begin
  if p_function_url is null or length(trim(p_function_url)) = 0 then
    raise exception 'Missing process capture function URL';
  end if;

  if p_worker_key is null or length(p_worker_key) = 0 then
    raise exception 'Missing process capture worker key';
  end if;

  v_trimmed_idea := nullif(trim(coalesce(p_idea_text, '')), '');

  if v_trimmed_idea is not null then
    select created.sync_cursor into v_cursor
    from public.api_create_idea_capture(
      p_user_id,
      p_capture_id,
      v_trimmed_idea,
      now()
    ) as created;
  else
    update public.captures
    set
      status = 'classifying',
      failure_reason = null,
      deleted_at = null
    where id = p_capture_id
      and user_id = p_user_id;

    if not found then
      raise exception 'Capture % does not exist for user %', p_capture_id, p_user_id;
    end if;

    v_cursor := public.emit_sync_event(
      p_user_id,
      'capture',
      p_capture_id,
      'classifying',
      jsonb_build_object('captureId', p_capture_id)
    );
  end if;

  select net.http_post(
    url := p_function_url,
    body := jsonb_build_object(
      'userId', p_user_id,
      'captureId', p_capture_id,
      'remoteMediaRef', p_remote_media_ref,
      'ideaText', v_trimmed_idea
    ),
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || p_worker_key,
      'x-mymenu-worker-key', p_worker_key
    ),
    timeout_milliseconds := 30000
  ) into v_request_id;

  return query select
    p_capture_id::uuid,
    'classifying'::text,
    v_request_id::bigint,
    v_cursor::bigint;
end;
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
    coalesce(max(returned.id), v_after_cursor)::bigint as cursor,
    ((select total_count from stats) > v_limit)::boolean as has_more,
    coalesce(
      jsonb_agg(
        jsonb_build_object(
          'cursor', returned.id,
          'type', returned.entity_type || '.' || returned.operation,
          'entityIds',
            coalesce(returned.payload, '{}'::jsonb) ||
            jsonb_build_object(
              case returned.entity_type
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
    ) as events,
    false::boolean as requires_bootstrap
  from returned;
end;
$$;

grant execute on function public.api_apply_capture_to_dish(
  uuid,
  uuid,
  uuid,
  text,
  text,
  text[]
) to authenticated, service_role;

grant execute on function public.api_pull_events(
  uuid,
  bigint,
  integer
) to authenticated, service_role;

grant usage on schema public to service_role;

grant select, insert, update, delete on
  public.profiles,
  public.dishes,
  public.dish_notes,
  public.dish_ingredients,
  public.dish_steps,
  public.captures,
  public.dish_images,
  public.review_items,
  public.planned_meals,
  public.sync_events
to service_role;

grant select on public.dish_cooking_stats to service_role;

grant usage, select on sequence public.sync_events_id_seq to service_role;

notify pgrst, 'reload schema';
