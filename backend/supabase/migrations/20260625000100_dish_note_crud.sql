create trigger dish_notes_touch_updated_at
  before update on public.dish_notes
  for each row execute function public.touch_updated_at();

create trigger dish_ingredients_touch_updated_at
  before update on public.dish_ingredients
  for each row execute function public.touch_updated_at();

create trigger dish_steps_touch_updated_at
  before update on public.dish_steps
  for each row execute function public.touch_updated_at();

create or replace function public.api_create_dish_note(
  p_user_id uuid,
  p_note_id uuid,
  p_dish_id uuid,
  p_body text,
  p_position integer default 0
)
returns table (
  note_id uuid,
  dish_id uuid,
  sync_cursor bigint
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_cursor bigint;
begin
  if not exists (
    select 1
    from public.dishes d
    where d.id = p_dish_id
      and d.user_id = p_user_id
      and d.deleted_at is null
  ) then
    raise exception 'Dish note parent not found'
      using errcode = 'P0002';
  end if;

  insert into public.dish_notes (
    id,
    user_id,
    dish_id,
    body,
    position,
    deleted_at
  )
  values (
    p_note_id,
    p_user_id,
    p_dish_id,
    p_body,
    coalesce(p_position, 0),
    null
  )
  on conflict (id) do update set
    body = excluded.body,
    position = excluded.position,
    deleted_at = null
  where public.dish_notes.user_id = p_user_id
    and public.dish_notes.dish_id = p_dish_id;

  if not found then
    raise exception 'Dish note parent not found'
      using errcode = 'P0002';
  end if;

  v_cursor := public.emit_sync_event(
    p_user_id,
    'dish_note',
    p_note_id,
    'upsert',
    jsonb_build_object('dishId', p_dish_id)
  );

  return query select p_note_id::uuid, p_dish_id::uuid, v_cursor::bigint;
end;
$$;

create or replace function public.api_update_dish_note(
  p_user_id uuid,
  p_note_id uuid,
  p_body text,
  p_position integer default null
)
returns table (
  note_id uuid,
  dish_id uuid,
  sync_cursor bigint
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_dish_id uuid;
  v_cursor bigint;
begin
  update public.dish_notes n
  set
    body = coalesce(p_body, n.body),
    position = coalesce(p_position, n.position),
    deleted_at = null
  from public.dishes d
  where n.id = p_note_id
    and n.user_id = p_user_id
    and n.dish_id = d.id
    and d.user_id = p_user_id
    and d.deleted_at is null
  returning n.dish_id into v_dish_id;

  if v_dish_id is null then
    raise exception 'Dish note not found'
      using errcode = 'P0002';
  end if;

  v_cursor := public.emit_sync_event(
    p_user_id,
    'dish_note',
    p_note_id,
    'upsert',
    jsonb_build_object('dishId', v_dish_id)
  );

  return query select p_note_id::uuid, v_dish_id::uuid, v_cursor::bigint;
end;
$$;

create or replace function public.api_delete_dish_note(
  p_user_id uuid,
  p_note_id uuid
)
returns table (
  note_id uuid,
  dish_id uuid,
  sync_cursor bigint
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_dish_id uuid;
  v_cursor bigint;
begin
  update public.dish_notes n
  set deleted_at = now()
  from public.dishes d
  where n.id = p_note_id
    and n.user_id = p_user_id
    and n.dish_id = d.id
    and d.user_id = p_user_id
    and d.deleted_at is null
    and n.deleted_at is null
  returning n.dish_id into v_dish_id;

  if v_dish_id is null then
    raise exception 'Dish note not found'
      using errcode = 'P0002';
  end if;

  v_cursor := public.emit_sync_event(
    p_user_id,
    'dish_note',
    p_note_id,
    'delete',
    jsonb_build_object('dishId', v_dish_id)
  );

  return query select p_note_id::uuid, v_dish_id::uuid, v_cursor::bigint;
end;
$$;

create or replace function public.api_update_dish(
  p_user_id uuid,
  p_client_mutation_id text,
  p_dish_id uuid,
  p_patch jsonb
)
returns table (
  dish_id uuid,
  sync_cursor bigint
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_cursor bigint;
  v_ingredients jsonb;
  v_steps jsonb;
begin
  if p_patch is null or jsonb_typeof(p_patch) <> 'object' then
    raise exception 'Missing dish patch';
  end if;

  update public.dishes
  set
    title = case
      when p_patch ? 'title' then p_patch->>'title'
      else title
    end,
    description = case
      when p_patch ? 'description' then coalesce(p_patch->>'description', '')
      else description
    end,
    is_favorite = case
      when p_patch ? 'isFavorite' then (p_patch->>'isFavorite')::boolean
      else is_favorite
    end,
    labels = case
      when p_patch ? 'labels' then coalesce(
        array(select jsonb_array_elements_text(p_patch->'labels')),
        '{}'
      )
      else labels
    end,
    prep_minutes = case
      when p_patch ? 'prepMinutes' then (p_patch->>'prepMinutes')::integer
      else prep_minutes
    end,
    difficulty = case
      when p_patch ? 'difficulty' then p_patch->>'difficulty'
      else difficulty
    end
  where id = p_dish_id
    and user_id = p_user_id
    and deleted_at is null;

  if not found then
    raise exception 'Dish not found'
      using errcode = 'P0002';
  end if;

  if p_patch ? 'ingredients' then
    v_ingredients := p_patch->'ingredients';
    if jsonb_typeof(v_ingredients) <> 'array' then
      raise exception 'ingredients must be an array';
    end if;

    update public.dish_ingredients
    set deleted_at = now()
    where dish_id = p_dish_id
      and user_id = p_user_id
      and deleted_at is null;

    insert into public.dish_ingredients (id, user_id, dish_id, body, position)
    select
      gen_random_uuid(),
      p_user_id,
      p_dish_id,
      value,
      ordinality::integer - 1
    from jsonb_array_elements_text(v_ingredients) with ordinality;
  end if;

  if p_patch ? 'steps' then
    v_steps := p_patch->'steps';
    if jsonb_typeof(v_steps) <> 'array' then
      raise exception 'steps must be an array';
    end if;

    update public.dish_steps
    set deleted_at = now()
    where dish_id = p_dish_id
      and user_id = p_user_id
      and deleted_at is null;

    insert into public.dish_steps (id, user_id, dish_id, body, position)
    select
      gen_random_uuid(),
      p_user_id,
      p_dish_id,
      value,
      ordinality::integer - 1
    from jsonb_array_elements_text(v_steps) with ordinality;
  end if;

  v_cursor := public.emit_sync_event(
    p_user_id,
    'dish',
    p_dish_id,
    'upsert',
    jsonb_build_object(
      'clientMutationId',
      p_client_mutation_id,
      'patchKeys',
      (
        select jsonb_agg(key order by key)
        from jsonb_object_keys(p_patch) as key
      )
    )
  );

  return query select p_dish_id::uuid, v_cursor::bigint;
end;
$$;

grant execute on function public.api_create_dish_note(
  uuid,
  uuid,
  uuid,
  text,
  integer
) to authenticated, service_role;

grant execute on function public.api_update_dish_note(
  uuid,
  uuid,
  text,
  integer
) to authenticated, service_role;

grant execute on function public.api_delete_dish_note(
  uuid,
  uuid
) to authenticated, service_role;

grant execute on function public.api_update_dish(
  uuid,
  text,
  uuid,
  jsonb
) to authenticated, service_role;

notify pgrst, 'reload schema';
