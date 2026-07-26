alter table public.ai_jobs
  add column provider text not null default 'fake'
    check (length(trim(provider)) > 0);

create or replace function public.internal_configure_capture_ai_job(
  p_job_id uuid,
  p_user_id uuid,
  p_provider text,
  p_prompt_version text,
  p_model_version text,
  p_schema_version text
)
returns setof public.ai_jobs
language plpgsql
security definer
set search_path = public
as $$
declare
  v_job public.ai_jobs%rowtype;
begin
  if auth.role() <> 'service_role' then
    raise exception 'Service role required';
  end if;
  if nullif(trim(p_provider), '') is null
    or nullif(trim(p_prompt_version), '') is null
    or nullif(trim(p_model_version), '') is null
    or nullif(trim(p_schema_version), '') is null then
    raise exception 'AI job provider and version fields are required';
  end if;

  update public.ai_jobs
  set
    provider = trim(p_provider),
    prompt_version = trim(p_prompt_version),
    model_version = trim(p_model_version),
    schema_version = trim(p_schema_version)
  where id = p_job_id
    and user_id = p_user_id
    and job_type = 'batch_grouping'
    and status in ('queued', 'running', 'retrying')
  returning * into v_job;

  if v_job.id is null then
    select *
    into v_job
    from public.ai_jobs
    where id = p_job_id
      and user_id = p_user_id
      and job_type = 'batch_grouping'
      and status = 'succeeded';
  end if;

  if v_job.id is null then
    raise exception 'Capture grouping AI job % is not configurable', p_job_id;
  end if;

  return next v_job;
end;
$$;

create or replace function public.internal_finalize_capture_batch_v2(
  p_user_id uuid,
  p_batch_id uuid,
  p_kind public.capture_kind,
  p_idea_text text,
  p_captured_at timestamptz,
  p_captured_local_date date,
  p_capture_date_source text,
  p_job_id uuid,
  p_idempotency_key text,
  p_input_hash text,
  p_input_version text,
  p_provider text,
  p_prompt_version text,
  p_model_version text,
  p_schema_version text,
  p_max_attempts integer default 3
)
returns setof public.ai_jobs
language plpgsql
security definer
set search_path = public
as $$
declare
  v_job public.ai_jobs%rowtype;
begin
  if auth.role() <> 'service_role' then
    raise exception 'Service role required';
  end if;

  select *
  into v_job
  from public.internal_finalize_capture_batch(
    p_user_id,
    p_batch_id,
    p_kind,
    p_idea_text,
    p_captured_at,
    p_captured_local_date,
    p_capture_date_source,
    p_job_id,
    p_idempotency_key,
    p_input_hash,
    p_input_version,
    p_max_attempts
  );

  select *
  into v_job
  from public.internal_configure_capture_ai_job(
    v_job.id,
    p_user_id,
    p_provider,
    p_prompt_version,
    p_model_version,
    p_schema_version
  );

  return next v_job;
end;
$$;

create or replace function public.internal_get_capture_grouping_input(
  p_job_id uuid,
  p_lease_token uuid
)
returns table (
  capture_id uuid,
  ordinal integer,
  kind public.capture_kind,
  idea_text text,
  captured_local_date date,
  storage_bucket text,
  storage_path text,
  content_type text
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_job public.ai_jobs%rowtype;
begin
  if auth.role() <> 'service_role' then
    raise exception 'Service role required';
  end if;

  update public.ai_jobs
  set lease_expires_at = now() + interval '3 minutes'
  where id = p_job_id
    and job_type = 'batch_grouping'
    and status = 'running'
    and lease_token = p_lease_token
    and lease_expires_at > now()
  returning * into v_job;

  if v_job.id is null then
    raise exception 'AI job % does not have the active lease', p_job_id;
  end if;

  return query
  select
    captures.id,
    captures.ordinal,
    captures.kind,
    captures.idea_text,
    captures.captured_local_date,
    media.storage_bucket,
    media.storage_path,
    media.content_type
  from public.captures captures
  left join lateral (
    select
      images.storage_bucket,
      images.storage_path,
      images.content_type
    from public.dish_images images
    where images.user_id = v_job.user_id
      and images.capture_id = captures.id
      and images.kind in ('capture_photo', 'source_photo')
      and images.deleted_at is null
    order by
      case when images.kind = 'capture_photo' then 0 else 1 end,
      images.created_at desc
    limit 1
  ) media on true
  where captures.user_id = v_job.user_id
    and captures.batch_id = v_job.subject_id
    and captures.status = 'classifying'
    and captures.deleted_at is null
  order by captures.ordinal, captures.created_at;
end;
$$;

create or replace function public.internal_apply_capture_grouping_job(
  p_job_id uuid,
  p_lease_token uuid,
  p_normalized_result jsonb
)
returns setof public.ai_jobs
language plpgsql
security definer
set search_path = public
as $$
declare
  v_job public.ai_jobs%rowtype;
  v_group record;
  v_rejected record;
  v_capture_id uuid;
  v_capture_ids uuid[];
  v_expected_ids uuid[];
  v_result_ids uuid[];
  v_result_count integer;
  v_result_distinct_count integer;
  v_first_capture_id uuid;
  v_occasion_id uuid;
  v_dish_id uuid;
  v_local_date date;
  v_grouping_key text;
  v_title text;
  v_description text;
  v_labels text[];
  v_applied_groups jsonb := '[]'::jsonb;
  v_rejected_results jsonb := '[]'::jsonb;
  v_rejected_reason text;
  v_provenance jsonb;
begin
  if auth.role() <> 'service_role' then
    raise exception 'Service role required';
  end if;

  select *
  into v_job
  from public.ai_jobs
  where id = p_job_id
    and job_type = 'batch_grouping'
    and status = 'running'
    and lease_token = p_lease_token
    and lease_expires_at > now()
  for update;

  if v_job.id is null then
    raise exception 'AI job % does not have the active lease', p_job_id;
  end if;
  if jsonb_typeof(p_normalized_result) <> 'object'
    or jsonb_typeof(p_normalized_result->'groups') <> 'array'
    or jsonb_typeof(p_normalized_result->'rejectedCaptures') <> 'array'
    or (
      jsonb_array_length(p_normalized_result->'groups')
      + jsonb_array_length(p_normalized_result->'rejectedCaptures')
    ) = 0 then
    raise exception 'Grouping result must contain at least one decision';
  end if;

  select array_agg(captures.id order by captures.id)
  into v_expected_ids
  from public.captures captures
  where captures.user_id = v_job.user_id
    and captures.batch_id = v_job.subject_id
    and captures.status = 'classifying'
    and captures.deleted_at is null;

  if coalesce(array_length(v_expected_ids, 1), 0) = 0 then
    raise exception 'Capture batch % has no active captures', v_job.subject_id;
  end if;

  begin
    select
      array_agg(ids.capture_id order by ids.capture_id),
      count(*)::integer,
      count(distinct ids.capture_id)::integer
    into v_result_ids, v_result_count, v_result_distinct_count
    from (
      select capture_id_text
      from jsonb_array_elements(p_normalized_result->'groups')
        groups(value)
      cross join lateral jsonb_array_elements_text(groups.value->'captureIds')
        capture_ids(capture_id_text)
      union all
      select rejected.value->>'captureId' as capture_id_text
      from jsonb_array_elements(p_normalized_result->'rejectedCaptures')
        rejected(value)
    ) raw_ids
    cross join lateral (
      select raw_ids.capture_id_text::uuid as capture_id
    ) ids;
  exception
    when others then
      raise exception 'Grouping result contains an invalid capture ID';
  end;

  if v_result_count <> v_result_distinct_count then
    raise exception 'Grouping result contains duplicate captures';
  end if;
  if v_result_ids is distinct from v_expected_ids then
    raise exception 'Grouping result is not an exact partition of the batch';
  end if;

  v_provenance := coalesce(
    p_normalized_result->'provenance',
    '{}'::jsonb
  ) || jsonb_build_object(
    'provider', v_job.provider,
    'model', v_job.model_version,
    'promptVersion', v_job.prompt_version,
    'schemaVersion', v_job.schema_version
  );

  for v_group in
    select groups.value, groups.ordinality
    from jsonb_array_elements(p_normalized_result->'groups')
      with ordinality groups(value, ordinality)
    order by groups.ordinality
  loop
    if jsonb_typeof(v_group.value->'captureIds') <> 'array'
      or jsonb_array_length(v_group.value->'captureIds') = 0
      or jsonb_typeof(v_group.value->'draft') <> 'object' then
      raise exception 'Every grouping result group needs captures and a draft';
    end if;

    select array_agg(capture_id_text::uuid order by captures.ordinal)
    into v_capture_ids
    from jsonb_array_elements_text(
      v_group.value->'captureIds'
    ) capture_ids(capture_id_text)
    join public.captures captures
      on captures.id = capture_id_text::uuid
     and captures.user_id = v_job.user_id
     and captures.batch_id = v_job.subject_id;

    v_first_capture_id := v_capture_ids[1];
    v_grouping_key := 'ai:' || v_first_capture_id::text;

    select case
      when count(*) = count(captured_local_date)
        and count(distinct captured_local_date) = 1
      then min(captured_local_date)
      else null
    end
    into v_local_date
    from public.captures
    where id = any(v_capture_ids);

    v_title := left(
      coalesce(
        nullif(trim(v_group.value->'draft'->>'title'), ''),
        'Captured Dish'
      ),
      80
    );
    v_description := left(
      coalesce(trim(v_group.value->'draft'->>'description'), ''),
      240
    );
    select coalesce(array_agg(left(trim(label), 40)), '{}'::text[])
    into v_labels
    from jsonb_array_elements_text(
      coalesce(v_group.value->'draft'->'labels', '[]'::jsonb)
    ) labels(label)
    where nullif(trim(label), '') is not null;

    insert into public.cooking_occasions (
      user_id, batch_id, grouping_key, local_date
    )
    values (
      v_job.user_id, v_job.subject_id, v_grouping_key, v_local_date
    )
    on conflict (batch_id, grouping_key) do update set
      local_date = excluded.local_date
    returning id, dish_id into v_occasion_id, v_dish_id;

    if v_dish_id is null then
      v_dish_id := gen_random_uuid();
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
        v_dish_id,
        v_job.user_id,
        v_title,
        v_description,
        v_labels,
        'ai_capture',
        v_first_capture_id
      );

      update public.cooking_occasions
      set dish_id = v_dish_id
      where id = v_occasion_id;
    end if;

    update public.dish_images
    set
      dish_id = v_dish_id,
      cooking_occasion_id = v_occasion_id,
      kind = 'source_photo',
      confidence_label = 'AI grouped',
      deleted_at = null
    where user_id = v_job.user_id
      and capture_id = any(v_capture_ids)
      and kind in ('capture_photo', 'source_photo');

    update public.captures
    set
      status = 'applied',
      applied_dish_id = v_dish_id,
      failure_reason = null,
      deleted_at = null
    where user_id = v_job.user_id
      and id = any(v_capture_ids);

    foreach v_capture_id in array v_capture_ids
    loop
      perform public.emit_sync_event(
        v_job.user_id,
        'capture',
        v_capture_id,
        'applied_to_new_dish',
        jsonb_build_object(
          'captureId', v_capture_id,
          'batchId', v_job.subject_id,
          'dishId', v_dish_id,
          'occasionId', v_occasion_id
        )
      );
    end loop;

    perform public.emit_sync_event(
      v_job.user_id,
      'dish',
      v_dish_id,
      'created',
      jsonb_build_object(
        'dishId', v_dish_id,
        'batchId', v_job.subject_id,
        'occasionId', v_occasion_id
      )
    );

    v_applied_groups := v_applied_groups || jsonb_build_array(
      v_group.value || jsonb_build_object(
        'groupingKey', v_grouping_key,
        'localDate', v_local_date,
        'occasionId', v_occasion_id,
        'dishId', v_dish_id,
        'title', v_title
      )
    );
  end loop;

  for v_rejected in
    select rejected.value, rejected.ordinality
    from jsonb_array_elements(p_normalized_result->'rejectedCaptures')
      with ordinality rejected(value, ordinality)
    order by rejected.ordinality
  loop
    if jsonb_typeof(v_rejected.value) <> 'object'
      or v_rejected.value->>'classification' <> 'not_a_dish'
      or nullif(trim(v_rejected.value->>'reason'), '') is null then
      raise exception
        'Every rejected capture needs not_a_dish classification and a reason';
    end if;

    v_capture_id := (v_rejected.value->>'captureId')::uuid;
    v_rejected_reason := left(trim(v_rejected.value->>'reason'), 180);

    update public.captures
    set
      status = 'discarded',
      applied_dish_id = null,
      failure_reason = v_rejected_reason,
      deleted_at = null
    where user_id = v_job.user_id
      and batch_id = v_job.subject_id
      and id = v_capture_id
      and kind = 'photo'
      and status = 'classifying';

    if not found then
      raise exception 'Rejected capture % is not an active photo', v_capture_id;
    end if;

    perform public.emit_sync_event(
      v_job.user_id,
      'capture',
      v_capture_id,
      'discarded',
      jsonb_build_object(
        'captureId', v_capture_id,
        'batchId', v_job.subject_id,
        'classification', 'not_a_dish',
        'reason', v_rejected_reason
      )
    );

    v_rejected_results := v_rejected_results || jsonb_build_array(
      v_rejected.value || jsonb_build_object('reason', v_rejected_reason)
    );
  end loop;

  update public.capture_batches
  set status = 'applied', failure_reason = null
  where id = v_job.subject_id
    and user_id = v_job.user_id;

  perform public.emit_sync_event(
    v_job.user_id,
    'capture_batch',
    v_job.subject_id,
    'applied',
    jsonb_build_object(
      'batchId', v_job.subject_id,
      'aiJobId', v_job.id,
      'occasionCount', jsonb_array_length(v_applied_groups),
      'rejectedCount', jsonb_array_length(v_rejected_results)
    )
  );

  update public.ai_jobs
  set
    status = 'succeeded',
    normalized_result = jsonb_build_object(
      'batchId', v_job.subject_id,
      'groups', v_applied_groups,
      'occasions', v_applied_groups,
      'rejectedCaptures', v_rejected_results,
      'provenance', v_provenance
    ),
    normalized_error = null,
    completed_at = now(),
    failed_at = null,
    next_retry_at = null,
    lease_token = null,
    lease_expires_at = null
  where id = v_job.id
  returning * into v_job;

  perform public.emit_sync_event(
    v_job.user_id,
    'ai_job',
    v_job.id,
    'succeeded',
    jsonb_build_object(
      'aiJobId', v_job.id,
      'subjectId', v_job.subject_id
    )
  );

  return next v_job;
end;
$$;

create or replace function public.internal_enqueue_ai_worker(
  p_function_url text,
  p_worker_key text
)
returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare
  v_request_id bigint;
  v_project_url text;
  v_project_secret_id uuid;
  v_worker_secret_id uuid;
begin
  if auth.role() <> 'service_role' then
    raise exception 'Service role required';
  end if;
  if nullif(trim(p_function_url), '') is null then
    raise exception 'Missing AI worker URL';
  end if;
  if nullif(p_worker_key, '') is null then
    raise exception 'Missing AI worker key';
  end if;

  v_project_url := regexp_replace(
    trim(p_function_url),
    '/functions/v1/process-ai-jobs/?$',
    ''
  );

  select id into v_project_secret_id
  from vault.secrets
  where name = 'mymenu_project_url';
  if v_project_secret_id is null then
    perform vault.create_secret(
      v_project_url,
      'mymenu_project_url',
      'MyMenu Edge Function base URL'
    );
  else
    perform vault.update_secret(v_project_secret_id, v_project_url);
  end if;

  select id into v_worker_secret_id
  from vault.secrets
  where name = 'mymenu_ai_worker_key';
  if v_worker_secret_id is null then
    perform vault.create_secret(
      p_worker_key,
      'mymenu_ai_worker_key',
      'Dedicated MyMenu AI worker dispatch key'
    );
  else
    perform vault.update_secret(v_worker_secret_id, p_worker_key);
  end if;

  select net.http_post(
    url := p_function_url,
    body := '{}'::jsonb,
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || p_worker_key,
      'x-mymenu-worker-key', p_worker_key
    ),
    timeout_milliseconds := 10000
  )
  into v_request_id;
  return v_request_id;
end;
$$;

drop function if exists public.internal_process_capture_ai_jobs(integer);

revoke all on function public.internal_configure_capture_ai_job(
  uuid, uuid, text, text, text, text
) from public, anon, authenticated;
grant execute on function public.internal_configure_capture_ai_job(
  uuid, uuid, text, text, text, text
) to service_role;

revoke all on function public.internal_finalize_capture_batch_v2(
  uuid, uuid, public.capture_kind, text, timestamptz, date, text, uuid, text,
  text, text, text, text, text, text, integer
) from public, anon, authenticated;
grant execute on function public.internal_finalize_capture_batch_v2(
  uuid, uuid, public.capture_kind, text, timestamptz, date, text, uuid, text,
  text, text, text, text, text, text, integer
) to service_role;

revoke all on function public.internal_get_capture_grouping_input(uuid, uuid)
  from public, anon, authenticated;
grant execute on function public.internal_get_capture_grouping_input(uuid, uuid)
  to service_role;

revoke all on function public.internal_apply_capture_grouping_job(
  uuid, uuid, jsonb
) from public, anon, authenticated;
grant execute on function public.internal_apply_capture_grouping_job(
  uuid, uuid, jsonb
) to service_role;

do $$
begin
  if exists (
    select 1 from cron.job where jobname = 'mymenu-dispatch-ai-jobs'
  ) then
    perform cron.unschedule('mymenu-dispatch-ai-jobs');
  end if;

  perform cron.schedule(
    'mymenu-dispatch-ai-jobs',
    '* * * * *',
    $cron$
      select net.http_post(
        url := secrets.project_url || '/functions/v1/process-ai-jobs',
        body := '{}'::jsonb,
        headers := jsonb_build_object(
          'Content-Type', 'application/json',
          'Authorization', 'Bearer ' || secrets.worker_key,
          'x-mymenu-worker-key', secrets.worker_key
        ),
        timeout_milliseconds := 10000
      )
      from (
        select
          max(decrypted_secret)
            filter (where name = 'mymenu_project_url') as project_url,
          max(decrypted_secret)
            filter (where name = 'mymenu_ai_worker_key') as worker_key
        from vault.decrypted_secrets
      ) as secrets
      where secrets.project_url is not null
        and secrets.worker_key is not null;
    $cron$
  );
end;
$$;
