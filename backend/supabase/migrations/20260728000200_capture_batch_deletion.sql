create or replace function public.internal_prepare_capture_batch_deletion(
  p_user_id uuid,
  p_batch_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_batch public.capture_batches%rowtype;
  v_capture_ids uuid[];
  v_result_dish_ids uuid[];
  v_storage_objects jsonb;
begin
  if auth.role() <> 'service_role' then
    raise exception 'Service role required';
  end if;
  if p_user_id is null then
    raise exception 'A user is required';
  end if;

  select *
  into v_batch
  from public.capture_batches
  where id = p_batch_id
    and user_id = p_user_id
  for update;

  if not found then
    return jsonb_build_object(
      'found', false,
      'batchId', p_batch_id,
      'captureIds', '[]'::jsonb,
      'storageObjects', '[]'::jsonb
    );
  end if;

  select coalesce(array_agg(captures.id order by captures.id), '{}'::uuid[])
  into v_capture_ids
  from public.captures captures
  where captures.batch_id = p_batch_id
    and captures.user_id = p_user_id;

  select coalesce(array_agg(dishes.id order by dishes.id), '{}'::uuid[])
  into v_result_dish_ids
  from public.dishes dishes
  where dishes.user_id = p_user_id
    and dishes.created_from_capture_id = any(v_capture_ids);

  select coalesce(
    jsonb_agg(
      jsonb_build_object('bucket', objects.bucket, 'path', objects.path)
      order by objects.bucket, objects.path
    ),
    '[]'::jsonb
  )
  into v_storage_objects
  from (
    select distinct images.storage_bucket as bucket, images.storage_path as path
    from public.dish_images images
    where images.user_id = p_user_id
      and (
        images.capture_id = any(v_capture_ids)
        or images.dish_id = any(v_result_dish_ids)
      )
  ) objects;

  update public.capture_batches
  set
    status = 'discarded',
    deleted_at = coalesce(deleted_at, now())
  where id = p_batch_id
    and user_id = p_user_id;

  update public.captures
  set
    status = 'discarded',
    deleted_at = coalesce(deleted_at, now())
  where id = any(v_capture_ids)
    and user_id = p_user_id;

  update public.ai_jobs
  set
    status = 'canceled',
    canceled_at = coalesce(canceled_at, now()),
    completed_at = coalesce(completed_at, now())
  where user_id = p_user_id
    and subject_id = p_batch_id
    and status in ('queued', 'running', 'retrying');

  return jsonb_build_object(
    'found', true,
    'batchId', p_batch_id,
    'captureIds', to_jsonb(v_capture_ids),
    'storageObjects', v_storage_objects
  );
end;
$$;

create or replace function public.internal_delete_capture_batch(
  p_user_id uuid,
  p_batch_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_batch public.capture_batches%rowtype;
  v_capture_ids uuid[];
  v_ai_job_ids uuid[];
  v_action_ids uuid[];
  v_result_dish_ids uuid[];
  v_capture_id uuid;
  v_ai_job_id uuid;
  v_result_dish_id uuid;
begin
  if auth.role() <> 'service_role' then
    raise exception 'Service role required';
  end if;
  if p_user_id is null then
    raise exception 'A user is required';
  end if;

  select *
  into v_batch
  from public.capture_batches
  where id = p_batch_id
    and user_id = p_user_id
  for update;

  if not found then
    return jsonb_build_object(
      'deletedBatchId', null,
      'deletedCaptureIds', '[]'::jsonb,
      'deletedAiJobIds', '[]'::jsonb
    );
  end if;

  select coalesce(array_agg(captures.id order by captures.id), '{}'::uuid[])
  into v_capture_ids
  from public.captures captures
  where captures.batch_id = p_batch_id
    and captures.user_id = p_user_id;

  select coalesce(array_agg(jobs.id order by jobs.id), '{}'::uuid[])
  into v_ai_job_ids
  from public.ai_jobs jobs
  where jobs.user_id = p_user_id
    and jobs.subject_id = p_batch_id;

  select coalesce(array_agg(actions.id order by actions.id), '{}'::uuid[])
  into v_action_ids
  from public.capture_grouping_actions actions
  where actions.user_id = p_user_id
    and actions.batch_id = p_batch_id;

  select coalesce(array_agg(dishes.id order by dishes.id), '{}'::uuid[])
  into v_result_dish_ids
  from public.dishes dishes
  where dishes.user_id = p_user_id
    and dishes.created_from_capture_id = any(v_capture_ids);

  delete from public.review_items
  where user_id = p_user_id
    and capture_id = any(v_capture_ids);

  delete from public.capture_grouping_actions
  where user_id = p_user_id
    and id = any(v_action_ids);

  delete from public.dish_images
  where user_id = p_user_id
    and (
      capture_id = any(v_capture_ids)
      or dish_id = any(v_result_dish_ids)
    );

  update public.dishes
  set created_from_capture_id = null
  where user_id = p_user_id
    and id = any(v_result_dish_ids);

  delete from public.captures
  where user_id = p_user_id
    and id = any(v_capture_ids);

  delete from public.dishes
  where user_id = p_user_id
    and id = any(v_result_dish_ids);

  delete from public.ai_jobs
  where user_id = p_user_id
    and id = any(v_ai_job_ids);

  delete from public.capture_batches
  where user_id = p_user_id
    and id = p_batch_id;

  delete from public.sync_events events
  where events.user_id = p_user_id
    and (
      (events.entity_type = 'capture' and events.entity_id = any(v_capture_ids))
      or (
        events.entity_type = 'capture_batch'
        and events.entity_id = p_batch_id
      )
      or (events.entity_type = 'ai_job' and events.entity_id = any(v_ai_job_ids))
      or (
        events.entity_type = 'capture_grouping_action'
        and events.entity_id = any(v_action_ids)
      )
    );

  foreach v_capture_id in array v_capture_ids loop
    perform public.emit_sync_event(
      p_user_id,
      'capture',
      v_capture_id,
      'deleted',
      jsonb_build_object('captureId', v_capture_id, 'batchId', p_batch_id)
    );
  end loop;

  foreach v_ai_job_id in array v_ai_job_ids loop
    perform public.emit_sync_event(
      p_user_id,
      'ai_job',
      v_ai_job_id,
      'deleted',
      jsonb_build_object('aiJobId', v_ai_job_id, 'batchId', p_batch_id)
    );
  end loop;

  foreach v_result_dish_id in array v_result_dish_ids loop
    perform public.emit_sync_event(
      p_user_id,
      'dish',
      v_result_dish_id,
      'deleted',
      jsonb_build_object('dishId', v_result_dish_id, 'batchId', p_batch_id)
    );
  end loop;

  perform public.emit_sync_event(
    p_user_id,
    'capture_batch',
    p_batch_id,
    'deleted',
    jsonb_build_object('batchId', p_batch_id)
  );

  return jsonb_build_object(
    'deletedBatchId', p_batch_id,
    'deletedCaptureIds', to_jsonb(v_capture_ids),
    'deletedAiJobIds', to_jsonb(v_ai_job_ids)
  );
end;
$$;

revoke all on function public.internal_prepare_capture_batch_deletion(uuid, uuid)
  from public, anon, authenticated;
grant execute on function public.internal_prepare_capture_batch_deletion(uuid, uuid)
  to service_role;

revoke all on function public.internal_delete_capture_batch(uuid, uuid)
  from public, anon, authenticated;
grant execute on function public.internal_delete_capture_batch(uuid, uuid)
  to service_role;

notify pgrst, 'reload schema';
