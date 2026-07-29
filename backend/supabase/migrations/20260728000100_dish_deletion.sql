create or replace function public.internal_prepare_dish_deletion(
  p_user_id uuid,
  p_dish_ids uuid[]
)
returns jsonb
language plpgsql
security definer
set search_path = public, storage
as $$
declare
  v_requested_ids uuid[] := coalesce(
    array(
      select distinct requested_id
      from unnest(coalesce(p_dish_ids, '{}'::uuid[])) requested_id
      order by requested_id
    ),
    '{}'::uuid[]
  );
  v_dish_ids uuid[];
  v_capture_ids uuid[];
  v_storage_objects jsonb;
begin
  if auth.role() <> 'service_role' then
    raise exception 'Service role required';
  end if;
  if p_user_id is null then
    raise exception 'A user is required';
  end if;

  select coalesce(array_agg(dishes.id order by dishes.id), '{}'::uuid[])
  into v_dish_ids
  from public.dishes dishes
  where dishes.user_id = p_user_id
    and dishes.id = any(v_requested_ids);

  select coalesce(array_agg(captures.id order by captures.id), '{}'::uuid[])
  into v_capture_ids
  from public.captures captures
  where captures.user_id = p_user_id
    and captures.applied_dish_id = any(v_dish_ids);

  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'bucket', images.storage_bucket,
        'path', images.storage_path
      )
      order by images.storage_bucket, images.storage_path
    ),
    '[]'::jsonb
  )
  into v_storage_objects
  from public.dish_images images
  where images.user_id = p_user_id
    and (
      images.dish_id = any(v_dish_ids)
      or images.capture_id = any(v_capture_ids)
    );

  return jsonb_build_object(
    'dishIds', to_jsonb(v_dish_ids),
    'captureIds', to_jsonb(v_capture_ids),
    'missingDishIds',
      to_jsonb(
        array(
          select requested_id
          from unnest(v_requested_ids) requested_id
          where not requested_id = any(v_dish_ids)
          order by requested_id
        )
      ),
    'storageObjects', v_storage_objects
  );
end;
$$;

create or replace function public.internal_delete_dishes(
  p_user_id uuid,
  p_dish_ids uuid[]
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_requested_ids uuid[] := coalesce(
    array(
      select distinct requested_id
      from unnest(coalesce(p_dish_ids, '{}'::uuid[])) requested_id
      order by requested_id
    ),
    '{}'::uuid[]
  );
  v_dish_ids uuid[];
  v_capture_ids uuid[];
  v_batch_ids uuid[];
  v_empty_batch_ids uuid[];
  v_action_ids uuid[];
  v_ai_job_ids uuid[];
  v_capture_id uuid;
  v_dish_id uuid;
  v_batch_id uuid;
  v_ai_job_id uuid;
  v_note_count integer := 0;
  v_ingredient_count integer := 0;
  v_step_count integer := 0;
  v_plan_count integer := 0;
  v_occasion_count integer := 0;
  v_image_count integer := 0;
  v_review_count integer := 0;
  v_action_count integer := 0;
  v_ai_job_count integer := 0;
begin
  if auth.role() <> 'service_role' then
    raise exception 'Service role required';
  end if;
  if p_user_id is null then
    raise exception 'A user is required';
  end if;

  perform 1
  from public.dishes dishes
  where dishes.user_id = p_user_id
    and dishes.id = any(v_requested_ids)
  for update;

  select coalesce(array_agg(dishes.id order by dishes.id), '{}'::uuid[])
  into v_dish_ids
  from public.dishes dishes
  where dishes.user_id = p_user_id
    and dishes.id = any(v_requested_ids);

  if cardinality(v_dish_ids) = 0 then
    return jsonb_build_object(
      'deletedDishIds', '[]'::jsonb,
      'deletedCaptureIds', '[]'::jsonb,
      'deletedBatchIds', '[]'::jsonb,
      'missingDishIds', to_jsonb(v_requested_ids),
      'counts', jsonb_build_object(
        'dishes', 0,
        'captures', 0,
        'images', 0,
        'notes', 0,
        'ingredients', 0,
        'steps', 0,
        'plannedMeals', 0,
        'cookingOccasions', 0,
        'reviewItems', 0,
        'groupingActions', 0,
        'aiJobs', 0
      )
    );
  end if;

  select coalesce(array_agg(captures.id order by captures.id), '{}'::uuid[])
  into v_capture_ids
  from public.captures captures
  where captures.user_id = p_user_id
    and captures.applied_dish_id = any(v_dish_ids);

  select coalesce(
    array_agg(distinct captures.batch_id)
      filter (where captures.batch_id is not null),
    '{}'::uuid[]
  )
  into v_batch_ids
  from public.captures captures
  where captures.id = any(v_capture_ids);

  select coalesce(array_agg(actions.id order by actions.id), '{}'::uuid[])
  into v_action_ids
  from public.capture_grouping_actions actions
  where actions.user_id = p_user_id
    and (
      actions.target_dish_id = any(v_dish_ids)
      or actions.created_dish_id = any(v_dish_ids)
      or actions.capture_ids && v_capture_ids
      or exists (
        select 1
        from jsonb_array_elements(actions.previous_assignments) assignment
        where assignment->>'dishId' = any(
          array(
            select deleted_dish_id::text
            from unnest(v_dish_ids) deleted_dish_id
          )
        )
      )
    );

  select count(*) into v_note_count
  from public.dish_notes
  where user_id = p_user_id and dish_id = any(v_dish_ids);
  select count(*) into v_ingredient_count
  from public.dish_ingredients
  where user_id = p_user_id and dish_id = any(v_dish_ids);
  select count(*) into v_step_count
  from public.dish_steps
  where user_id = p_user_id and dish_id = any(v_dish_ids);
  select count(*) into v_plan_count
  from public.planned_meals
  where user_id = p_user_id and dish_id = any(v_dish_ids);
  select count(*) into v_occasion_count
  from public.cooking_occasions
  where user_id = p_user_id and dish_id = any(v_dish_ids);
  select count(*) into v_image_count
  from public.dish_images
  where user_id = p_user_id
    and (
      dish_id = any(v_dish_ids)
      or capture_id = any(v_capture_ids)
    );
  select count(*) into v_review_count
  from public.review_items
  where user_id = p_user_id and capture_id = any(v_capture_ids);
  v_action_count := cardinality(v_action_ids);

  update public.review_items review_items
  set suggested_dish_ids = array(
    select suggested_dish_id
    from unnest(review_items.suggested_dish_ids) suggested_dish_id
    where not suggested_dish_id = any(v_dish_ids)
  )
  where review_items.user_id = p_user_id
    and review_items.suggested_dish_ids && v_dish_ids;

  update public.dishes dishes
  set created_from_capture_id = null
  where dishes.user_id = p_user_id
    and dishes.created_from_capture_id = any(v_capture_ids)
    and not dishes.id = any(v_dish_ids);

  delete from public.capture_grouping_actions
  where id = any(v_action_ids)
    and user_id = p_user_id;

  delete from public.dish_images
  where user_id = p_user_id
    and (
      dish_id = any(v_dish_ids)
      or capture_id = any(v_capture_ids)
    );

  delete from public.captures
  where user_id = p_user_id
    and id = any(v_capture_ids);

  update public.capture_batches batches
  set item_count = (
    select count(*)::integer
    from public.captures captures
    where captures.batch_id = batches.id
  )
  where batches.user_id = p_user_id
    and batches.id = any(v_batch_ids);

  delete from public.dishes
  where user_id = p_user_id
    and id = any(v_dish_ids);

  select coalesce(array_agg(batches.id order by batches.id), '{}'::uuid[])
  into v_empty_batch_ids
  from public.capture_batches batches
  where batches.user_id = p_user_id
    and batches.id = any(v_batch_ids)
    and not exists (
      select 1
      from public.captures captures
      where captures.batch_id = batches.id
    );

  select coalesce(array_agg(jobs.id order by jobs.id), '{}'::uuid[])
  into v_ai_job_ids
  from public.ai_jobs jobs
  where jobs.user_id = p_user_id
    and (
      jobs.subject_id = any(v_dish_ids)
      or jobs.subject_id = any(v_empty_batch_ids)
    );
  v_ai_job_count := cardinality(v_ai_job_ids);

  delete from public.ai_jobs
  where user_id = p_user_id
    and id = any(v_ai_job_ids);

  delete from public.capture_batches
  where user_id = p_user_id
    and id = any(v_empty_batch_ids);

  delete from public.sync_events events
  where events.user_id = p_user_id
    and (
      (events.entity_type = 'dish' and events.entity_id = any(v_dish_ids))
      or (
        events.entity_type = 'capture'
        and events.entity_id = any(v_capture_ids)
      )
      or (
        events.entity_type = 'capture_batch'
        and events.entity_id = any(v_empty_batch_ids)
      )
      or (
        events.entity_type = 'capture_grouping_action'
        and events.entity_id = any(v_action_ids)
      )
      or (
        events.entity_type = 'ai_job'
        and events.entity_id = any(v_ai_job_ids)
      )
    );

  foreach v_capture_id in array v_capture_ids loop
    perform public.emit_sync_event(
      p_user_id,
      'capture',
      v_capture_id,
      'deleted',
      jsonb_build_object('captureId', v_capture_id)
    );
  end loop;

  foreach v_ai_job_id in array v_ai_job_ids loop
    perform public.emit_sync_event(
      p_user_id,
      'ai_job',
      v_ai_job_id,
      'deleted',
      jsonb_build_object('aiJobId', v_ai_job_id)
    );
  end loop;

  foreach v_batch_id in array v_empty_batch_ids loop
    perform public.emit_sync_event(
      p_user_id,
      'capture_batch',
      v_batch_id,
      'deleted',
      jsonb_build_object('batchId', v_batch_id)
    );
  end loop;

  foreach v_dish_id in array v_dish_ids loop
    perform public.emit_sync_event(
      p_user_id,
      'dish',
      v_dish_id,
      'deleted',
      jsonb_build_object('dishId', v_dish_id)
    );
  end loop;

  return jsonb_build_object(
    'deletedDishIds', to_jsonb(v_dish_ids),
    'deletedCaptureIds', to_jsonb(v_capture_ids),
    'deletedBatchIds', to_jsonb(v_empty_batch_ids),
    'missingDishIds',
      to_jsonb(
        array(
          select requested_id
          from unnest(v_requested_ids) requested_id
          where not requested_id = any(v_dish_ids)
          order by requested_id
        )
      ),
    'counts', jsonb_build_object(
      'dishes', cardinality(v_dish_ids),
      'captures', cardinality(v_capture_ids),
      'images', v_image_count,
      'notes', v_note_count,
      'ingredients', v_ingredient_count,
      'steps', v_step_count,
      'plannedMeals', v_plan_count,
      'cookingOccasions', v_occasion_count,
      'reviewItems', v_review_count,
      'groupingActions', v_action_count,
      'aiJobs', v_ai_job_count
    )
  );
end;
$$;

revoke all on function public.internal_prepare_dish_deletion(uuid, uuid[])
  from public, anon, authenticated;
grant execute on function public.internal_prepare_dish_deletion(uuid, uuid[])
  to service_role;

revoke all on function public.internal_delete_dishes(uuid, uuid[])
  from public, anon, authenticated;
grant execute on function public.internal_delete_dishes(uuid, uuid[])
  to service_role;

notify pgrst, 'reload schema';
