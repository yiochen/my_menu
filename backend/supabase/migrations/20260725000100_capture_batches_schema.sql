alter type public.capture_status add value if not exists 'uploaded';

create type public.capture_batch_status as enum (
  'pending_upload',
  'uploading',
  'ready_for_ai',
  'processing',
  'applied',
  'failed',
  'discarded'
);

create table public.capture_batches (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  status public.capture_batch_status not null default 'pending_upload',
  item_count integer not null check (item_count between 1 and 9),
  failure_reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create index capture_batches_user_updated_idx
  on public.capture_batches(user_id, updated_at);

create trigger capture_batches_touch_updated_at
  before update on public.capture_batches
  for each row execute function public.touch_updated_at();

alter table public.captures
  add column batch_id uuid references public.capture_batches(id) on delete cascade,
  add column ordinal integer check (ordinal between 0 and 8);

insert into public.capture_batches (
  id,
  user_id,
  status,
  item_count,
  failure_reason,
  created_at,
  updated_at,
  deleted_at
)
select
  captures.id,
  captures.user_id,
  case captures.status
    when 'applied' then 'applied'::public.capture_batch_status
    when 'failed' then 'failed'::public.capture_batch_status
    when 'discarded' then 'discarded'::public.capture_batch_status
    else 'processing'::public.capture_batch_status
  end,
  1,
  captures.failure_reason,
  captures.created_at,
  captures.updated_at,
  captures.deleted_at
from public.captures;

update public.captures
set
  batch_id = captures.id,
  ordinal = 0
where batch_id is null;

create unique index captures_batch_ordinal_idx
  on public.captures(batch_id, ordinal)
  where deleted_at is null;

alter table public.capture_batches enable row level security;

create policy "users own capture batches"
on public.capture_batches for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

grant select, insert, update, delete on public.capture_batches to authenticated;
grant select, insert, update, delete on public.capture_batches to service_role;

notify pgrst, 'reload schema';
