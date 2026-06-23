create extension if not exists pgcrypto;

create type public.dish_creation_source as enum (
  'manual',
  'ai_capture',
  'imported'
);

create type public.capture_kind as enum ('photo', 'idea');

create type public.capture_status as enum (
  'classifying',
  'needs_review',
  'applied',
  'discarded',
  'failed'
);

create type public.dish_image_kind as enum (
  'capture_photo',
  'source_photo',
  'ai_generated'
);

create type public.review_status as enum ('open', 'resolved', 'dismissed');

create table public.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.dishes (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  description text not null default '',
  cover_image_id uuid,
  labels text[] not null default '{}',
  prep_minutes integer,
  difficulty text,
  is_favorite boolean not null default false,
  creation_source public.dish_creation_source not null default 'manual',
  created_from_capture_id uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create index dishes_user_updated_idx on public.dishes(user_id, updated_at);
create index dishes_labels_idx on public.dishes using gin(labels);

create table public.dish_notes (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  dish_id uuid not null references public.dishes(id) on delete cascade,
  body text not null,
  position integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table public.dish_ingredients (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  dish_id uuid not null references public.dishes(id) on delete cascade,
  body text not null,
  position integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table public.dish_steps (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  dish_id uuid not null references public.dishes(id) on delete cascade,
  body text not null,
  position integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table public.captures (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  kind public.capture_kind not null,
  status public.capture_status not null default 'classifying',
  idea_text text,
  applied_dish_id uuid references public.dishes(id),
  failure_reason text,
  captured_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create index captures_user_updated_idx on public.captures(user_id, updated_at);

create table public.dish_images (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  dish_id uuid references public.dishes(id) on delete set null,
  capture_id uuid references public.captures(id) on delete set null,
  kind public.dish_image_kind not null,
  storage_bucket text not null default 'menu-media',
  storage_path text not null,
  content_type text not null,
  byte_size bigint,
  width integer,
  height integer,
  sha256 text,
  note text,
  labels text[] not null default '{}',
  confidence_label text,
  captured_at timestamptz,
  generated_at timestamptz,
  generation_prompt text,
  generation_model text,
  source_image_ids uuid[] not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  unique(user_id, storage_bucket, storage_path)
);

create index dish_images_dish_time_idx
  on public.dish_images(dish_id, captured_at desc)
  where deleted_at is null;

create index dish_images_capture_idx
  on public.dish_images(capture_id)
  where deleted_at is null;

create index dish_images_labels_idx on public.dish_images using gin(labels);

alter table public.dishes
  add constraint dishes_cover_image_id_fkey
  foreign key (cover_image_id)
  references public.dish_images(id)
  on delete set null;

create table public.review_items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  capture_id uuid not null references public.captures(id) on delete cascade,
  status public.review_status not null default 'open',
  summary text not null,
  suggested_dish_ids uuid[] not null default '{}',
  suggested_new_dish jsonb,
  confidence_label text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  resolved_at timestamptz
);

create table public.planned_meals (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  dish_id uuid not null references public.dishes(id) on delete cascade,
  day_key date not null,
  labels text[] not null default '{}',
  position integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create index planned_meals_user_day_idx
  on public.planned_meals(user_id, day_key, position);

create index planned_meals_labels_idx
  on public.planned_meals using gin(labels);

create table public.sync_events (
  id bigserial primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  entity_type text not null,
  entity_id uuid not null,
  operation text not null,
  payload jsonb,
  created_at timestamptz not null default now()
);

create index sync_events_user_id_idx on public.sync_events(user_id, id);

create view public.dish_cooking_stats
with (security_invoker = true) as
select
  d.id as dish_id,
  count(i.id) filter (
    where i.kind = 'source_photo' and i.deleted_at is null
  ) as made_count,
  max(i.captured_at) filter (
    where i.kind = 'source_photo' and i.deleted_at is null
  ) as last_made_at,
  (
    select latest.id
    from public.dish_images latest
    where latest.dish_id = d.id
      and latest.kind = 'source_photo'
      and latest.deleted_at is null
    order by latest.captured_at desc nulls last, latest.created_at desc
    limit 1
  ) as latest_source_image_id
from public.dishes d
left join public.dish_images i on i.dish_id = d.id
group by d.id;

create or replace function public.touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger profiles_touch_updated_at
  before update on public.profiles
  for each row execute function public.touch_updated_at();

create trigger dishes_touch_updated_at
  before update on public.dishes
  for each row execute function public.touch_updated_at();

create trigger captures_touch_updated_at
  before update on public.captures
  for each row execute function public.touch_updated_at();

create trigger dish_images_touch_updated_at
  before update on public.dish_images
  for each row execute function public.touch_updated_at();

create trigger planned_meals_touch_updated_at
  before update on public.planned_meals
  for each row execute function public.touch_updated_at();

create or replace function public.emit_sync_event(
  p_user_id uuid,
  p_entity_type text,
  p_entity_id uuid,
  p_operation text,
  p_payload jsonb default '{}'::jsonb
)
returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare
  v_id bigint;
begin
  insert into public.sync_events (
    user_id,
    entity_type,
    entity_id,
    operation,
    payload
  )
  values (
    p_user_id,
    p_entity_type,
    p_entity_id,
    p_operation,
    coalesce(p_payload, '{}'::jsonb)
  )
  returning id into v_id;

  return v_id;
end;
$$;

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

alter table public.profiles enable row level security;
alter table public.dishes enable row level security;
alter table public.dish_notes enable row level security;
alter table public.dish_ingredients enable row level security;
alter table public.dish_steps enable row level security;
alter table public.captures enable row level security;
alter table public.dish_images enable row level security;
alter table public.review_items enable row level security;
alter table public.planned_meals enable row level security;
alter table public.sync_events enable row level security;

create policy "users own profiles"
on public.profiles for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "users own dishes"
on public.dishes for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "users own dish notes"
on public.dish_notes for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "users own dish ingredients"
on public.dish_ingredients for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "users own dish steps"
on public.dish_steps for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "users own captures"
on public.captures for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "users own dish images"
on public.dish_images for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "users own review items"
on public.review_items for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "users own planned meals"
on public.planned_meals for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "users own sync events"
on public.sync_events for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);
