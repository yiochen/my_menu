alter table public.captures
  add column organization_source text not null default 'ai'
    check (organization_source in ('ai', 'user')),
  add column organization_action_id uuid;

create table public.capture_grouping_actions (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  batch_id uuid not null references public.capture_batches(id) on delete cascade,
  action_type text not null check (action_type in ('move', 'split')),
  capture_ids uuid[] not null check (cardinality(capture_ids) > 0),
  target_dish_id uuid not null references public.dishes(id),
  created_dish_id uuid references public.dishes(id),
  previous_assignments jsonb not null,
  source_ai_job_id uuid references public.ai_jobs(id) on delete set null,
  status text not null default 'applied'
    check (status in ('applied', 'undone')),
  created_at timestamptz not null default now(),
  undone_at timestamptz
);

create index capture_grouping_actions_user_batch_idx
  on public.capture_grouping_actions(user_id, batch_id, created_at desc);

alter table public.captures
  add constraint captures_organization_action_id_fkey
  foreign key (organization_action_id)
  references public.capture_grouping_actions(id)
  on delete set null;

alter table public.capture_grouping_actions enable row level security;

create policy "users own capture grouping actions"
on public.capture_grouping_actions for select
using (auth.uid() = user_id);

grant select on public.capture_grouping_actions to authenticated;
grant select, insert, update, delete on public.capture_grouping_actions
  to service_role;

create or replace function public.protect_user_capture_organization()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if old.organization_source = 'user'
    and coalesce(
      current_setting('mymenu.allow_user_capture_correction', true),
      'off'
    ) <> 'on'
    and (
      new.applied_dish_id is distinct from old.applied_dish_id
      or new.status is distinct from old.status
      or new.organization_source is distinct from old.organization_source
      or new.organization_action_id is distinct from old.organization_action_id
    ) then
    raise exception
      'User-authored organization for capture % cannot be overwritten',
      old.id;
  end if;
  return new;
end;
$$;

create trigger captures_protect_user_organization
  before update on public.captures
  for each row execute function public.protect_user_capture_organization();

create or replace function public.api_correct_capture_grouping(
  p_client_mutation_id uuid,
  p_batch_id uuid,
  p_action_type text,
  p_capture_ids uuid[],
  p_target_dish_id uuid,
  p_new_dish_title text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_existing public.capture_grouping_actions%rowtype;
  v_capture_count integer;
  v_distinct_count integer;
  v_target_occasion_id uuid;
  v_local_date date;
  v_previous_assignments jsonb;
  v_source_dish_ids uuid[];
  v_source_dish_id uuid;
  v_capture_id uuid;
  v_source_ai_job_id uuid;
  v_created_dish_id uuid;
  v_target_title text;
begin
  if v_user_id is null then
    raise exception 'Authentication required';
  end if;
  if p_action_type not in ('move', 'split') then
    raise exception 'Correction action must be move or split';
  end if;
  if p_capture_ids is null or cardinality(p_capture_ids) = 0 then
    raise exception 'At least one capture is required';
  end if;

  select count(*), count(distinct capture_id)
  into v_capture_count, v_distinct_count
  from unnest(p_capture_ids) capture_id;
  if v_capture_count <> v_distinct_count then
    raise exception 'Correction contains duplicate captures';
  end if;

  select *
  into v_existing
  from public.capture_grouping_actions
  where id = p_client_mutation_id;

  if found then
    if v_existing.user_id <> v_user_id
      or v_existing.batch_id <> p_batch_id
      or v_existing.action_type <> p_action_type
      or v_existing.capture_ids <> p_capture_ids
      or v_existing.target_dish_id <> p_target_dish_id then
      raise exception 'Client mutation ID conflicts with another correction';
    end if;
    return jsonb_build_object(
      'actionId', v_existing.id,
      'status', v_existing.status,
      'targetDishId', v_existing.target_dish_id,
      'createdDishId', v_existing.created_dish_id
    );
  end if;

  perform 1
  from public.capture_batches
  where id = p_batch_id
    and user_id = v_user_id
    and deleted_at is null
  for update;
  if not found then
    raise exception 'Capture group is unavailable';
  end if;

  perform 1
  from public.captures
  where id = any(p_capture_ids)
  for update;

  select count(*)
  into v_capture_count
  from public.captures
  where id = any(p_capture_ids)
    and user_id = v_user_id
    and batch_id = p_batch_id
    and status = 'applied'
    and applied_dish_id is not null
    and deleted_at is null;
  if v_capture_count <> cardinality(p_capture_ids) then
    raise exception 'Every capture must be an active organized photo';
  end if;

  if p_action_type = 'split' then
    if nullif(trim(p_new_dish_title), '') is null then
      raise exception 'A new dish needs a name';
    end if;
    if exists (
      select 1 from public.dishes where id = p_target_dish_id
    ) then
      raise exception 'The new dish ID is already in use';
    end if;
    v_target_title := left(trim(p_new_dish_title), 80);
    insert into public.dishes (
      id,
      user_id,
      title,
      description,
      creation_source,
      created_from_capture_id
    )
    values (
      p_target_dish_id,
      v_user_id,
      v_target_title,
      '',
      'manual',
      p_capture_ids[1]
    );
    v_created_dish_id := p_target_dish_id;
  else
    perform 1
    from public.dishes
    where id = p_target_dish_id
      and user_id = v_user_id
      and deleted_at is null
    for update;
    if not found then
      raise exception 'Destination dish is unavailable';
    end if;
  end if;

  select jsonb_agg(
    jsonb_build_object(
      'captureId', captures.id,
      'dishId', captures.applied_dish_id,
      'occasionId', (
        select images.cooking_occasion_id
        from public.dish_images images
        where images.user_id = v_user_id
          and images.capture_id = captures.id
          and images.kind = 'source_photo'
          and images.deleted_at is null
        order by images.created_at
        limit 1
      ),
      'organizationSource', captures.organization_source,
      'organizationActionId', captures.organization_action_id
    )
    order by captures.ordinal
  )
  into v_previous_assignments
  from public.captures captures
  where captures.id = any(p_capture_ids);

  select array_agg(distinct (assignment->>'dishId')::uuid)
  into v_source_dish_ids
  from jsonb_array_elements(v_previous_assignments) assignment;

  select case
    when count(*) = count(captured_local_date)
      and count(distinct captured_local_date) = 1
    then min(captured_local_date)
    else null
  end
  into v_local_date
  from public.captures
  where id = any(p_capture_ids);

  if p_action_type = 'move' then
    select occasions.id
    into v_target_occasion_id
    from public.cooking_occasions occasions
    join public.dish_images images
      on images.cooking_occasion_id = occasions.id
     and images.kind = 'source_photo'
     and images.deleted_at is null
    where occasions.user_id = v_user_id
      and occasions.batch_id = p_batch_id
      and occasions.dish_id = p_target_dish_id
    order by occasions.created_at
    limit 1;
  end if;

  if v_target_occasion_id is null then
    insert into public.cooking_occasions (
      user_id,
      batch_id,
      dish_id,
      grouping_key,
      local_date
    )
    values (
      v_user_id,
      p_batch_id,
      p_target_dish_id,
      'user:' || p_client_mutation_id::text,
      v_local_date
    )
    returning id into v_target_occasion_id;
  end if;

  select id
  into v_source_ai_job_id
  from public.ai_jobs
  where user_id = v_user_id
    and subject_id = p_batch_id
    and job_type = 'batch_grouping'
  order by created_at desc
  limit 1;

  insert into public.capture_grouping_actions (
    id,
    user_id,
    batch_id,
    action_type,
    capture_ids,
    target_dish_id,
    created_dish_id,
    previous_assignments,
    source_ai_job_id
  )
  values (
    p_client_mutation_id,
    v_user_id,
    p_batch_id,
    p_action_type,
    p_capture_ids,
    p_target_dish_id,
    v_created_dish_id,
    v_previous_assignments,
    v_source_ai_job_id
  );

  perform set_config('mymenu.allow_user_capture_correction', 'on', true);

  update public.dish_images
  set
    dish_id = p_target_dish_id,
    cooking_occasion_id = v_target_occasion_id,
    kind = 'source_photo',
    confidence_label = 'User corrected',
    deleted_at = null
  where user_id = v_user_id
    and capture_id = any(p_capture_ids)
    and kind in ('capture_photo', 'source_photo');

  update public.captures
  set
    status = 'applied',
    applied_dish_id = p_target_dish_id,
    failure_reason = null,
    organization_source = 'user',
    organization_action_id = p_client_mutation_id,
    deleted_at = null
  where user_id = v_user_id
    and id = any(p_capture_ids);

  foreach v_source_dish_id in array coalesce(v_source_dish_ids, '{}'::uuid[])
  loop
    if v_source_dish_id <> p_target_dish_id
      and not exists (
        select 1
        from public.dish_images
        where user_id = v_user_id
          and dish_id = v_source_dish_id
          and kind = 'source_photo'
          and deleted_at is null
      ) then
      update public.dishes
      set deleted_at = now()
      where id = v_source_dish_id
        and user_id = v_user_id
        and creation_source = 'ai_capture';
    end if;
  end loop;

  foreach v_capture_id in array p_capture_ids
  loop
    perform public.emit_sync_event(
      v_user_id,
      'capture',
      v_capture_id,
      'applied_to_existing_dish',
      jsonb_build_object(
        'captureId', v_capture_id,
        'batchId', p_batch_id,
        'dishId', p_target_dish_id,
        'correctionActionId', p_client_mutation_id
      )
    );
  end loop;

  foreach v_source_dish_id in array coalesce(v_source_dish_ids, '{}'::uuid[])
  loop
    perform public.emit_sync_event(
      v_user_id,
      'dish',
      v_source_dish_id,
      case
        when exists (
          select 1 from public.dishes
          where id = v_source_dish_id and deleted_at is not null
        ) then 'deleted'
        else 'updated'
      end,
      jsonb_build_object('dishId', v_source_dish_id)
    );
  end loop;

  perform public.emit_sync_event(
    v_user_id,
    'dish',
    p_target_dish_id,
    case when p_action_type = 'split' then 'created' else 'updated' end,
    jsonb_build_object('dishId', p_target_dish_id)
  );
  perform public.emit_sync_event(
    v_user_id,
    'capture_batch',
    p_batch_id,
    'applied',
    jsonb_build_object('batchId', p_batch_id)
  );
  perform public.emit_sync_event(
    v_user_id,
    'capture_grouping_action',
    p_client_mutation_id,
    'applied',
    jsonb_build_object(
      'actionId', p_client_mutation_id,
      'batchId', p_batch_id,
      'actionType', p_action_type,
      'captureIds', p_capture_ids,
      'targetDishId', p_target_dish_id
    )
  );

  return jsonb_build_object(
    'actionId', p_client_mutation_id,
    'status', 'applied',
    'targetDishId', p_target_dish_id,
    'createdDishId', v_created_dish_id
  );
end;
$$;

create or replace function public.api_undo_capture_grouping(
  p_client_mutation_id uuid,
  p_action_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_action public.capture_grouping_actions%rowtype;
  v_assignment jsonb;
  v_capture_id uuid;
  v_source_dish_id uuid;
  v_source_dish_ids uuid[];
begin
  if v_user_id is null then
    raise exception 'Authentication required';
  end if;

  select *
  into v_action
  from public.capture_grouping_actions
  where id = p_action_id
    and user_id = v_user_id
  for update;
  if not found then
    raise exception 'Correction action is unavailable';
  end if;
  if v_action.status = 'undone' then
    return jsonb_build_object(
      'actionId', v_action.id,
      'undoMutationId', p_client_mutation_id,
      'status', 'undone'
    );
  end if;
  if exists (
    select 1
    from public.capture_grouping_actions later
    where later.user_id = v_user_id
      and later.batch_id = v_action.batch_id
      and later.status = 'applied'
      and (
        later.created_at > v_action.created_at
        or (
          later.created_at = v_action.created_at
          and later.id > v_action.id
        )
      )
  ) then
    raise exception 'Only the latest correction can be undone';
  end if;
  if exists (
    select 1
    from public.captures
    where id = any(v_action.capture_ids)
      and organization_action_id is distinct from v_action.id
  ) then
    raise exception 'Correction is stale and cannot be undone';
  end if;

  perform set_config('mymenu.allow_user_capture_correction', 'on', true);

  for v_assignment in
    select value
    from jsonb_array_elements(v_action.previous_assignments)
  loop
    v_capture_id := (v_assignment->>'captureId')::uuid;
    v_source_dish_id := (v_assignment->>'dishId')::uuid;
    v_source_dish_ids := array_append(v_source_dish_ids, v_source_dish_id);

    update public.dishes
    set deleted_at = null
    where id = v_source_dish_id
      and user_id = v_user_id;

    update public.dish_images
    set
      dish_id = v_source_dish_id,
      cooking_occasion_id =
        nullif(v_assignment->>'occasionId', '')::uuid,
      kind = 'source_photo',
      confidence_label = case
        when v_assignment->>'organizationSource' = 'user'
        then 'User corrected'
        else 'AI grouped'
      end,
      deleted_at = null
    where user_id = v_user_id
      and capture_id = v_capture_id
      and kind in ('capture_photo', 'source_photo');

    update public.captures
    set
      status = 'applied',
      applied_dish_id = v_source_dish_id,
      failure_reason = null,
      organization_source =
        coalesce(v_assignment->>'organizationSource', 'ai'),
      organization_action_id =
        nullif(v_assignment->>'organizationActionId', '')::uuid,
      deleted_at = null
    where id = v_capture_id
      and user_id = v_user_id;

    perform public.emit_sync_event(
      v_user_id,
      'capture',
      v_capture_id,
      'applied_to_existing_dish',
      jsonb_build_object(
        'captureId', v_capture_id,
        'batchId', v_action.batch_id,
        'dishId', v_source_dish_id,
        'undoneActionId', v_action.id
      )
    );
  end loop;

  if v_action.created_dish_id is not null
    and not exists (
      select 1
      from public.dish_images
      where dish_id = v_action.created_dish_id
        and kind = 'source_photo'
        and deleted_at is null
    ) then
    update public.dishes
    set deleted_at = now()
    where id = v_action.created_dish_id
      and user_id = v_user_id;
    perform public.emit_sync_event(
      v_user_id,
      'dish',
      v_action.created_dish_id,
      'deleted',
      jsonb_build_object('dishId', v_action.created_dish_id)
    );
  elsif v_action.created_dish_id is null then
    perform public.emit_sync_event(
      v_user_id,
      'dish',
      v_action.target_dish_id,
      'updated',
      jsonb_build_object('dishId', v_action.target_dish_id)
    );
  end if;

  foreach v_source_dish_id in array coalesce(v_source_dish_ids, '{}'::uuid[])
  loop
    perform public.emit_sync_event(
      v_user_id,
      'dish',
      v_source_dish_id,
      'updated',
      jsonb_build_object('dishId', v_source_dish_id)
    );
  end loop;

  update public.capture_grouping_actions
  set status = 'undone', undone_at = now()
  where id = v_action.id;

  perform public.emit_sync_event(
    v_user_id,
    'capture_batch',
    v_action.batch_id,
    'applied',
    jsonb_build_object('batchId', v_action.batch_id)
  );
  perform public.emit_sync_event(
    v_user_id,
    'capture_grouping_action',
    v_action.id,
    'undone',
    jsonb_build_object(
      'actionId', v_action.id,
      'undoMutationId', p_client_mutation_id,
      'batchId', v_action.batch_id
    )
  );

  return jsonb_build_object(
    'actionId', v_action.id,
    'undoMutationId', p_client_mutation_id,
    'status', 'undone'
  );
end;
$$;

revoke all on function public.api_correct_capture_grouping(
  uuid, uuid, text, uuid[], uuid, text
) from public, anon;
grant execute on function public.api_correct_capture_grouping(
  uuid, uuid, text, uuid[], uuid, text
) to authenticated, service_role;

revoke all on function public.api_undo_capture_grouping(uuid, uuid)
  from public, anon;
grant execute on function public.api_undo_capture_grouping(uuid, uuid)
  to authenticated, service_role;

notify pgrst, 'reload schema';
