create extension if not exists pg_cron;
create extension if not exists supabase_vault;

alter table public.captures
  add column captured_local_date date,
  add column capture_date_source text;

create table public.cooking_occasions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  batch_id uuid not null references public.capture_batches(id) on delete cascade,
  dish_id uuid references public.dishes(id) on delete cascade,
  grouping_key text not null,
  local_date date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (batch_id, grouping_key)
);

create trigger cooking_occasions_touch_updated_at
  before update on public.cooking_occasions
  for each row execute function public.touch_updated_at();

alter table public.cooking_occasions enable row level security;

create policy "users own cooking occasions"
on public.cooking_occasions for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

alter table public.dish_images
  add column cooking_occasion_id uuid
    references public.cooking_occasions(id) on delete set null;

create index dish_images_cooking_occasion_idx
  on public.dish_images(cooking_occasion_id)
  where deleted_at is null;

create or replace view public.dish_cooking_stats
with (security_invoker = true) as
select
  d.id as dish_id,
  count(distinct coalesce(i.cooking_occasion_id::text, i.id::text)) filter (
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

alter table public.ai_jobs
  add column lease_token uuid,
  add column lease_expires_at timestamptz;

drop function if exists public.api_mark_capture_batch_ready(uuid);
drop function if exists public.api_schedule_capture_processing(
  uuid, uuid, text, text, text, text
);
drop function if exists public.api_create_photo_capture(
  uuid, uuid, text, text, bigint, integer, integer, text, timestamptz
);
drop function if exists public.api_create_photo_capture(
  uuid, uuid, uuid, integer, text, text, bigint, integer, integer, text,
  timestamptz
);

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
  p_captured_at timestamptz default now(),
  p_captured_local_date date default null,
  p_capture_date_source text default null
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
    raise exception 'Capture batch % does not exist or ordinal is invalid',
      p_batch_id;
  end if;

  insert into public.captures (
    id,
    user_id,
    batch_id,
    ordinal,
    kind,
    status,
    captured_at,
    captured_local_date,
    capture_date_source
  )
  values (
    p_capture_id,
    p_user_id,
    p_batch_id,
    p_ordinal,
    'photo',
    'uploaded',
    coalesce(p_captured_at, now()),
    p_captured_local_date,
    nullif(trim(coalesce(p_capture_date_source, '')), '')
  )
  on conflict (id) do update set
    status = 'uploaded',
    captured_at = excluded.captured_at,
    captured_local_date = excluded.captured_local_date,
    capture_date_source = excluded.capture_date_source,
    deleted_at = null
  where public.captures.user_id = p_user_id
    and public.captures.batch_id = p_batch_id
    and public.captures.ordinal = p_ordinal;

  get diagnostics v_affected = row_count;
  if v_affected = 0 then
    raise exception 'Capture % conflicts with a different user, batch, or ordinal',
      p_capture_id;
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
    captured_at = excluded.captured_at,
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

  return query
  select p_capture_id, v_image_id, greatest(v_cursor, v_batch_cursor);
end;
$$;

create or replace function public.internal_finalize_capture_batch(
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
  p_max_attempts integer default 3
)
returns setof public.ai_jobs
language plpgsql
security definer
set search_path = public
as $$
declare
  v_expected integer;
  v_uploaded integer;
  v_job public.ai_jobs%rowtype;
begin
  if auth.role() <> 'service_role' then
    raise exception 'Service role required';
  end if;
  if p_max_attempts < 1 or p_max_attempts > 10 then
    raise exception 'Max attempts must be between 1 and 10';
  end if;

  if p_kind = 'idea' then
    insert into public.capture_batches (
      id, user_id, status, item_count, created_at
    )
    values (
      p_batch_id, p_user_id, 'ready_for_ai', 1, coalesce(p_captured_at, now())
    )
    on conflict (id) do update set
      status = case
        when capture_batches.status in ('applied', 'discarded')
          then capture_batches.status
        else 'ready_for_ai'::public.capture_batch_status
      end,
      failure_reason = null,
      deleted_at = null
    where capture_batches.user_id = p_user_id;

    insert into public.captures (
      id,
      user_id,
      batch_id,
      ordinal,
      kind,
      status,
      idea_text,
      captured_at,
      captured_local_date,
      capture_date_source
    )
    values (
      p_batch_id,
      p_user_id,
      p_batch_id,
      0,
      'idea',
      'uploaded',
      nullif(trim(coalesce(p_idea_text, '')), ''),
      coalesce(p_captured_at, now()),
      p_captured_local_date,
      nullif(trim(coalesce(p_capture_date_source, '')), '')
    )
    on conflict (id) do update set
      status = case
        when captures.status in ('applied', 'discarded') then captures.status
        else 'uploaded'::public.capture_status
      end,
      idea_text = excluded.idea_text,
      captured_at = excluded.captured_at,
      captured_local_date = excluded.captured_local_date,
      capture_date_source = excluded.capture_date_source,
      deleted_at = null
    where captures.user_id = p_user_id;
  end if;

  select item_count
  into v_expected
  from public.capture_batches
  where id = p_batch_id
    and user_id = p_user_id
    and deleted_at is null
  for update;

  if v_expected is null then
    raise exception 'Capture batch % does not exist', p_batch_id;
  end if;

  select count(*)::integer
  into v_uploaded
  from public.captures
  where batch_id = p_batch_id
    and user_id = p_user_id
    and status in ('uploaded', 'classifying', 'applied')
    and deleted_at is null;

  if v_uploaded <> v_expected then
    raise exception 'Capture batch % is not ready: % of % items uploaded',
      p_batch_id, v_uploaded, v_expected;
  end if;

  select *
  into v_job
  from public.ai_jobs
  where user_id = p_user_id
    and idempotency_key = p_idempotency_key
    and status in ('queued', 'running', 'retrying', 'succeeded')
  order by created_at
  limit 1;

  if v_job.id is null then
    insert into public.ai_jobs (
      id,
      user_id,
      job_type,
      subject_id,
      idempotency_key,
      input_hash,
      input_version,
      prompt_version,
      model_version,
      schema_version,
      max_attempts
    )
    values (
      p_job_id,
      p_user_id,
      'batch_grouping',
      p_batch_id,
      p_idempotency_key,
      p_input_hash,
      p_input_version,
      'date-v1',
      'fake-date-grouper',
      '1',
      p_max_attempts
    )
    returning * into v_job;

    perform public.emit_sync_event(
      p_user_id,
      'ai_job',
      v_job.id,
      'queued',
      jsonb_build_object(
        'aiJobId', v_job.id,
        'subjectId', p_batch_id,
        'jobType', 'batch_grouping'
      )
    );
  end if;

  if v_job.status <> 'succeeded' then
    update public.capture_batches
    set status = 'processing', failure_reason = null
    where id = p_batch_id
      and user_id = p_user_id
      and status not in ('applied', 'discarded');

    update public.captures
    set status = 'classifying', failure_reason = null
    where batch_id = p_batch_id
      and user_id = p_user_id
      and status = 'uploaded';

    perform public.emit_sync_event(
      p_user_id,
      'capture_batch',
      p_batch_id,
      'processing',
      jsonb_build_object('batchId', p_batch_id, 'aiJobId', v_job.id)
    );
  end if;

  return next v_job;
end;
$$;

create or replace function public.api_retry_ai_job(
  p_job_id uuid
)
returns setof public.ai_jobs
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_job public.ai_jobs%rowtype;
begin
  if v_user_id is null then
    raise exception 'Authentication required';
  end if;

  update public.ai_jobs
  set
    status = 'queued',
    max_attempts = greatest(max_attempts, attempt_count + 1),
    next_retry_at = null,
    normalized_error = null,
    queued_at = now(),
    started_at = null,
    completed_at = null,
    failed_at = null,
    canceled_at = null,
    lease_token = null,
    lease_expires_at = null
  where id = p_job_id
    and user_id = v_user_id
    and status = 'failed'
  returning * into v_job;

  if v_job.id is null then
    raise exception 'AI job % cannot be retried', p_job_id;
  end if;

  if v_job.job_type = 'batch_grouping' then
    update public.capture_batches
    set status = 'processing', failure_reason = null
    where id = v_job.subject_id
      and user_id = v_user_id
      and status = 'failed';

    perform public.emit_sync_event(
      v_user_id,
      'capture_batch',
      v_job.subject_id,
      'processing',
      jsonb_build_object('batchId', v_job.subject_id, 'aiJobId', v_job.id)
    );
  end if;

  perform public.emit_sync_event(
    v_user_id,
    'ai_job',
    v_job.id,
    'queued',
    jsonb_build_object('aiJobId', v_job.id, 'subjectId', v_job.subject_id)
  );
  return next v_job;
end;
$$;

drop function if exists public.internal_claim_ai_job(public.ai_job_type[]);

create or replace function public.internal_claim_ai_job(
  p_job_types public.ai_job_type[] default null
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

  for v_job in
    select *
    from public.ai_jobs
    where status = 'running'
      and lease_expires_at <= now()
    for update skip locked
  loop
    update public.ai_jobs
    set
      status = case
        when attempt_count < max_attempts
          then 'retrying'::public.ai_job_status
        else 'failed'::public.ai_job_status
      end,
      next_retry_at = case
        when attempt_count < max_attempts then now()
        else null
      end,
      normalized_error = jsonb_build_object(
        'code', 'worker_lease_expired',
        'message', 'The AI worker stopped before completing the job.'
      ),
      failed_at = case
        when attempt_count >= max_attempts then now()
        else null
      end,
      lease_token = null,
      lease_expires_at = null
    where id = v_job.id
    returning * into v_job;

    if v_job.status = 'failed' and v_job.job_type = 'batch_grouping' then
      update public.capture_batches
      set
        status = 'failed',
        failure_reason = 'The AI worker stopped before completing the job.'
      where id = v_job.subject_id
        and user_id = v_job.user_id;

      perform public.emit_sync_event(
        v_job.user_id,
        'capture_batch',
        v_job.subject_id,
        'failed',
        jsonb_build_object(
          'batchId', v_job.subject_id,
          'aiJobId', v_job.id
        )
      );
    end if;

    perform public.emit_sync_event(
      v_job.user_id,
      'ai_job',
      v_job.id,
      v_job.status::text,
      jsonb_build_object(
        'aiJobId', v_job.id,
        'subjectId', v_job.subject_id,
        'attemptCount', v_job.attempt_count,
        'nextRetryAt', v_job.next_retry_at
      )
    );
  end loop;

  select *
  into v_job
  from public.ai_jobs
  where status in ('queued', 'retrying')
    and (next_retry_at is null or next_retry_at <= now())
    and (p_job_types is null or job_type = any(p_job_types))
  order by coalesce(next_retry_at, queued_at), created_at
  for update skip locked
  limit 1;

  if v_job.id is null then
    return;
  end if;

  update public.ai_jobs
  set
    status = 'running',
    attempt_count = attempt_count + 1,
    started_at = now(),
    next_retry_at = null,
    normalized_error = null,
    lease_token = gen_random_uuid(),
    lease_expires_at = now() + interval '2 minutes'
  where id = v_job.id
  returning * into v_job;

  perform public.emit_sync_event(
    v_job.user_id,
    'ai_job',
    v_job.id,
    'running',
    jsonb_build_object(
      'aiJobId', v_job.id,
      'subjectId', v_job.subject_id,
      'attemptCount', v_job.attempt_count
    )
  );
  return next v_job;
end;
$$;

create or replace function public.internal_complete_capture_grouping_job(
  p_job_id uuid,
  p_lease_token uuid
)
returns setof public.ai_jobs
language plpgsql
security definer
set search_path = public
as $$
declare
  v_job public.ai_jobs%rowtype;
  v_group record;
  v_capture record;
  v_occasion_id uuid;
  v_dish_id uuid;
  v_first_capture_id uuid;
  v_title text;
  v_results jsonb := '[]'::jsonb;
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
  for update;

  if v_job.id is null then
    raise exception 'AI job % does not have the active lease', p_job_id;
  end if;

  for v_group in
    select
      case
        when captured_local_date is null then 'unknown:' || id::text
        else 'date:' || captured_local_date::text
      end as grouping_key,
      captured_local_date as local_date,
      array_agg(id order by ordinal, created_at) as capture_ids
    from public.captures
    where user_id = v_job.user_id
      and batch_id = v_job.subject_id
      and status <> 'discarded'
      and deleted_at is null
    group by grouping_key, captured_local_date
    order by captured_local_date nulls last, grouping_key
  loop
    v_first_capture_id := v_group.capture_ids[1];

    insert into public.cooking_occasions (
      user_id, batch_id, grouping_key, local_date
    )
    values (
      v_job.user_id, v_job.subject_id, v_group.grouping_key, v_group.local_date
    )
    on conflict (batch_id, grouping_key) do update set
      local_date = excluded.local_date
    returning id, dish_id into v_occasion_id, v_dish_id;

    if v_dish_id is null then
      v_dish_id := gen_random_uuid();
      if v_group.local_date is null then
        v_title := 'Captured Dish';
      else
        v_title := 'Captured Dish · ' ||
          to_char(v_group.local_date, 'Mon FMDD');
      end if;

      if exists (
        select 1
        from public.captures
        where id = v_first_capture_id
          and kind = 'idea'
          and nullif(trim(idea_text), '') is not null
      ) then
        select initcap(trim(idea_text))
        into v_title
        from public.captures
        where id = v_first_capture_id;
      end if;

      v_title := coalesce(nullif(v_title, ''), 'Captured Dish');

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
        'Fake AI draft from a date-grouped capture.',
        array['capture', 'fake-ai'],
        'ai_capture',
        v_first_capture_id
      );

      update public.cooking_occasions
      set dish_id = v_dish_id
      where id = v_occasion_id;
    else
      select title into v_title
      from public.dishes
      where id = v_dish_id;
    end if;

    update public.dish_images
    set
      dish_id = v_dish_id,
      cooking_occasion_id = v_occasion_id,
      kind = 'source_photo',
      confidence_label = 'Fake AI',
      deleted_at = null
    where user_id = v_job.user_id
      and capture_id = any(v_group.capture_ids)
      and kind in ('capture_photo', 'source_photo');

    update public.captures
    set
      status = 'applied',
      applied_dish_id = v_dish_id,
      failure_reason = null,
      deleted_at = null
    where user_id = v_job.user_id
      and id = any(v_group.capture_ids);

    foreach v_first_capture_id in array v_group.capture_ids
    loop
      perform public.emit_sync_event(
        v_job.user_id,
        'capture',
        v_first_capture_id,
        'applied_to_new_dish',
        jsonb_build_object(
          'captureId', v_first_capture_id,
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

    v_results := v_results || jsonb_build_array(
      jsonb_build_object(
        'groupingKey', v_group.grouping_key,
        'localDate', v_group.local_date,
        'occasionId', v_occasion_id,
        'dishId', v_dish_id,
        'captureIds', v_group.capture_ids,
        'title', v_title
      )
    );
  end loop;

  if jsonb_array_length(v_results) = 0 then
    raise exception 'Capture batch % has no active captures', v_job.subject_id;
  end if;

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
      'occasionCount', jsonb_array_length(v_results)
    )
  );

  update public.ai_jobs
  set
    status = 'succeeded',
    normalized_result = jsonb_build_object(
      'batchId', v_job.subject_id,
      'occasions', v_results
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

drop function if exists public.internal_complete_ai_job(uuid, jsonb);

create or replace function public.internal_complete_ai_job(
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
begin
  if auth.role() <> 'service_role' then
    raise exception 'Service role required';
  end if;

  update public.ai_jobs
  set
    status = 'succeeded',
    normalized_result = coalesce(p_normalized_result, '{}'::jsonb),
    normalized_error = null,
    completed_at = now(),
    failed_at = null,
    next_retry_at = null,
    lease_token = null,
    lease_expires_at = null
  where id = p_job_id
    and status = 'running'
    and lease_token = p_lease_token
  returning * into v_job;

  if v_job.id is null then
    raise exception 'AI job % does not have the active lease', p_job_id;
  end if;

  perform public.emit_sync_event(
    v_job.user_id,
    'ai_job',
    v_job.id,
    'succeeded',
    jsonb_build_object('aiJobId', v_job.id, 'subjectId', v_job.subject_id)
  );
  return next v_job;
end;
$$;

drop function if exists public.internal_fail_ai_job(uuid, boolean, jsonb);

create or replace function public.internal_fail_ai_job(
  p_job_id uuid,
  p_lease_token uuid,
  p_retryable boolean,
  p_normalized_error jsonb
)
returns setof public.ai_jobs
language plpgsql
security definer
set search_path = public
as $$
declare
  v_job public.ai_jobs%rowtype;
  v_next_status public.ai_job_status;
  v_next_retry_at timestamptz;
begin
  if auth.role() <> 'service_role' then
    raise exception 'Service role required';
  end if;

  select *
  into v_job
  from public.ai_jobs
  where id = p_job_id
    and status = 'running'
    and lease_token = p_lease_token
  for update;

  if v_job.id is null then
    raise exception 'AI job % does not have the active lease', p_job_id;
  end if;

  if coalesce(p_retryable, false)
    and v_job.attempt_count < v_job.max_attempts then
    v_next_status := 'retrying';
    v_next_retry_at := now() + make_interval(
      secs => least(
        300,
        5 * power(2, greatest(v_job.attempt_count - 1, 0))::integer
      )
    );
  else
    v_next_status := 'failed';
    v_next_retry_at := null;
  end if;

  update public.ai_jobs
  set
    status = v_next_status,
    normalized_error = coalesce(p_normalized_error, '{}'::jsonb),
    next_retry_at = v_next_retry_at,
    failed_at = case when v_next_status = 'failed' then now() else null end,
    lease_token = null,
    lease_expires_at = null
  where id = p_job_id
  returning * into v_job;

  if v_next_status = 'failed' and v_job.job_type = 'batch_grouping' then
    update public.capture_batches
    set
      status = 'failed',
      failure_reason = coalesce(
        p_normalized_error->>'message',
        'AI organization failed.'
      )
    where id = v_job.subject_id
      and user_id = v_job.user_id;

    perform public.emit_sync_event(
      v_job.user_id,
      'capture_batch',
      v_job.subject_id,
      'failed',
      jsonb_build_object(
        'batchId', v_job.subject_id,
        'aiJobId', v_job.id
      )
    );
  end if;

  perform public.emit_sync_event(
    v_job.user_id,
    'ai_job',
    v_job.id,
    v_job.status::text,
    jsonb_build_object(
      'aiJobId', v_job.id,
      'subjectId', v_job.subject_id,
      'attemptCount', v_job.attempt_count,
      'nextRetryAt', v_job.next_retry_at
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

  select net.http_post(
    url := p_function_url,
    body := '{}'::jsonb,
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || p_worker_key,
      'x-mymenu-worker-key', p_worker_key
    ),
    timeout_milliseconds := 30000
  )
  into v_request_id;
  return v_request_id;
end;
$$;

grant select on public.cooking_occasions to authenticated;
grant select, insert, update, delete on public.cooking_occasions to service_role;

revoke all on function public.api_create_photo_capture(
  uuid, uuid, uuid, integer, text, text, bigint, integer, integer, text,
  timestamptz, date, text
) from public, anon, authenticated;
grant execute on function public.api_create_photo_capture(
  uuid, uuid, uuid, integer, text, text, bigint, integer, integer, text,
  timestamptz, date, text
) to service_role;

revoke all on function public.internal_finalize_capture_batch(
  uuid, uuid, public.capture_kind, text, timestamptz, date, text, uuid, text,
  text, text, integer
) from public, anon, authenticated;
grant execute on function public.internal_finalize_capture_batch(
  uuid, uuid, public.capture_kind, text, timestamptz, date, text, uuid, text,
  text, text, integer
) to service_role;

revoke all on function public.internal_claim_ai_job(public.ai_job_type[])
  from public, anon, authenticated;
grant execute on function public.internal_claim_ai_job(public.ai_job_type[])
  to service_role;

revoke all on function public.internal_complete_capture_grouping_job(uuid, uuid)
  from public, anon, authenticated;
grant execute on function public.internal_complete_capture_grouping_job(
  uuid, uuid
) to service_role;

revoke all on function public.internal_complete_ai_job(uuid, uuid, jsonb)
  from public, anon, authenticated;
grant execute on function public.internal_complete_ai_job(uuid, uuid, jsonb)
  to service_role;

revoke all on function public.internal_fail_ai_job(
  uuid, uuid, boolean, jsonb
) from public, anon, authenticated;
grant execute on function public.internal_fail_ai_job(
  uuid, uuid, boolean, jsonb
) to service_role;

revoke all on function public.internal_enqueue_ai_worker(text, text)
  from public, anon, authenticated;
grant execute on function public.internal_enqueue_ai_worker(text, text)
  to service_role;

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
        url := secrets.project_url ||
          '/functions/v1/process-ai-jobs',
        body := '{}'::jsonb,
        headers := jsonb_build_object(
          'Content-Type', 'application/json',
          'Authorization', 'Bearer ' || secrets.worker_key,
          'x-mymenu-worker-key', secrets.worker_key
        ),
        timeout_milliseconds := 30000
      )
      from (
        select
          max(decrypted_secret)
            filter (where name = 'mymenu_project_url') as project_url,
          max(decrypted_secret)
            filter (where name = 'mymenu_worker_key') as worker_key
        from vault.decrypted_secrets
      ) as secrets
      where secrets.project_url is not null
        and secrets.worker_key is not null
    $cron$
  );
end;
$$;

notify pgrst, 'reload schema';
