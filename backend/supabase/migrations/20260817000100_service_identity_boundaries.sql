create table public.service_entitlements (
  user_id uuid primary key references auth.users(id) on delete cascade,
  plan_key text not null default 'free' check (plan_key <> ''),
  status text not null default 'active' check (
    status in ('active', 'inactive', 'deleting')
  ),
  external_provider text,
  external_entitlement_ref text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.service_entitlements enable row level security;

revoke all on public.service_entitlements from public, anon, authenticated;
grant all on public.service_entitlements to service_role;

create or replace function public.internal_expire_inactive_guest_identities(
  p_inactive_before timestamptz,
  p_limit integer default 100
)
returns table (expired_user_id uuid)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid;
begin
  if auth.role() <> 'service_role' then
    raise exception 'Service role required';
  end if;
  if p_inactive_before is null or p_inactive_before > now() then
    raise exception 'Invalid inactive guest cutoff';
  end if;
  if p_limit < 1 or p_limit > 1000 then
    raise exception 'Inactive guest limit must be between 1 and 1000';
  end if;

  for v_user_id in
    select users.id
    from auth.users users
    where users.is_anonymous is true
      and users.created_at < p_inactive_before
      and not exists (
        select 1
        from public.ai_usage_records usage
        where usage.user_id = users.id
          and usage.created_at >= p_inactive_before
      )
      and not exists (
        select 1
        from public.processing_jobs jobs
        where jobs.user_id = users.id
      )
    order by users.created_at, users.id
    limit p_limit
  loop
    perform pg_advisory_xact_lock(
      hashtextextended(v_user_id::text || 'capture_grouping', 0)
    );
    perform pg_advisory_xact_lock(
      hashtextextended(v_user_id::text || 'cover_generation', 0)
    );

    if exists (
      select 1
      from public.ai_usage_records usage
      where usage.user_id = v_user_id
        and usage.created_at >= p_inactive_before
    ) or exists (
      select 1
      from public.processing_jobs jobs
      where jobs.user_id = v_user_id
    ) then
      continue;
    end if;

    delete from auth.users users
    where users.id = v_user_id
      and users.is_anonymous is true
    returning users.id into expired_user_id;

    if expired_user_id is not null then
      return next;
    end if;
  end loop;
end;
$$;

create or replace function public.reject_processing_for_deleting_identity()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if exists (
    select 1
    from public.service_entitlements entitlement
    where entitlement.user_id = new.user_id
      and entitlement.status = 'deleting'
  ) then
    raise exception 'Service identity deletion is in progress';
  end if;
  return new;
end;
$$;

create trigger processing_jobs_reject_deleting_identity
before insert on public.processing_jobs
for each row execute function public.reject_processing_for_deleting_identity();

create or replace function public.internal_begin_service_identity_deletion(
  p_user_id uuid
)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_is_anonymous boolean;
begin
  if auth.role() <> 'service_role' then
    raise exception 'Service role required';
  end if;

  perform pg_advisory_xact_lock(
    hashtextextended(p_user_id::text || 'capture_grouping', 0)
  );
  perform pg_advisory_xact_lock(
    hashtextextended(p_user_id::text || 'cover_generation', 0)
  );

  select users.is_anonymous
  into v_is_anonymous
  from auth.users users
  where users.id = p_user_id
  for update;

  if not found then
    raise exception 'Service identity not found';
  end if;
  if v_is_anonymous is distinct from false then
    raise exception 'Signed account required';
  end if;

  insert into public.service_entitlements (user_id, status)
  values (p_user_id, 'deleting')
  on conflict (user_id) do update
  set status = 'deleting', updated_at = now();
  return true;
end;
$$;

create or replace function public.internal_complete_service_identity_deletion(
  p_user_id uuid
)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_deleted uuid;
begin
  if auth.role() <> 'service_role' then
    raise exception 'Service role required';
  end if;

  perform pg_advisory_xact_lock(
    hashtextextended(p_user_id::text || 'capture_grouping', 0)
  );
  perform pg_advisory_xact_lock(
    hashtextextended(p_user_id::text || 'cover_generation', 0)
  );

  if not exists (
    select 1
    from public.service_entitlements entitlement
    where entitlement.user_id = p_user_id
      and entitlement.status = 'deleting'
  ) then
    raise exception 'Service identity deletion was not started';
  end if;

  delete from auth.users users
  where users.id = p_user_id
    and users.is_anonymous is false
  returning users.id into v_deleted;

  if v_deleted is null then
    raise exception 'Signed account required';
  end if;
  return true;
end;
$$;

create or replace function public.internal_list_orphan_processing_assets(
  p_limit integer default 500
)
returns table (storage_bucket text, storage_path text)
language plpgsql
security definer
set search_path = ''
as $$
begin
  if auth.role() <> 'service_role' then
    raise exception 'Service role required';
  end if;
  if p_limit < 1 or p_limit > 1000 then
    raise exception 'Orphan asset limit must be between 1 and 1000';
  end if;

  return query
  select objects.bucket_id::text, objects.name::text
  from storage.objects objects
  where objects.bucket_id = 'processing-media'
    and not exists (
      select 1
      from public.processing_assets assets
      where assets.storage_bucket = objects.bucket_id
        and assets.storage_path = objects.name
    )
  order by objects.created_at, objects.name
  limit p_limit;
end;
$$;

revoke all on function public.internal_expire_inactive_guest_identities(
  timestamptz, integer
) from public, anon, authenticated;
revoke all on function public.reject_processing_for_deleting_identity()
  from public, anon, authenticated;
revoke all on function public.internal_begin_service_identity_deletion(uuid)
  from public, anon, authenticated;
revoke all on function public.internal_complete_service_identity_deletion(uuid)
  from public, anon, authenticated;
revoke all on function public.internal_list_orphan_processing_assets(
  integer
) from public, anon, authenticated;

grant execute on function public.internal_expire_inactive_guest_identities(
  timestamptz, integer
) to service_role;
grant execute on function public.internal_begin_service_identity_deletion(uuid)
  to service_role;
grant execute on function public.internal_complete_service_identity_deletion(uuid)
  to service_role;
grant execute on function public.internal_list_orphan_processing_assets(
  integer
) to service_role;
