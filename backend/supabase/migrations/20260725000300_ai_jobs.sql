create type public.ai_job_type as enum (
  'batch_grouping',
  'existing_dish_match',
  'recipe_enrichment',
  'cover_generation'
);

create type public.ai_job_status as enum (
  'queued',
  'running',
  'retrying',
  'succeeded',
  'failed',
  'canceled'
);

create table public.ai_jobs (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  job_type public.ai_job_type not null,
  subject_id uuid not null,
  status public.ai_job_status not null default 'queued',
  idempotency_key text not null check (length(trim(idempotency_key)) > 0),
  input_hash text not null check (length(trim(input_hash)) > 0),
  input_version text not null check (length(trim(input_version)) > 0),
  attempt_count integer not null default 0 check (attempt_count >= 0),
  max_attempts integer not null default 3 check (max_attempts between 1 and 10),
  next_retry_at timestamptz,
  prompt_version text not null default '1',
  model_version text not null default 'default',
  schema_version text not null default '1',
  normalized_result jsonb,
  normalized_error jsonb,
  queued_at timestamptz not null default now(),
  started_at timestamptz,
  completed_at timestamptz,
  failed_at timestamptz,
  canceled_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create unique index ai_jobs_one_active_idempotency_key_idx
  on public.ai_jobs(user_id, idempotency_key)
  where status in ('queued', 'running', 'retrying');

create index ai_jobs_user_updated_idx
  on public.ai_jobs(user_id, updated_at desc);

create index ai_jobs_claim_idx
  on public.ai_jobs(next_retry_at, created_at)
  where status in ('queued', 'retrying');

create trigger ai_jobs_touch_updated_at
  before update on public.ai_jobs
  for each row execute function public.touch_updated_at();

alter table public.ai_jobs enable row level security;

create policy "users own ai jobs"
on public.ai_jobs for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create or replace function public.api_schedule_ai_job(
  p_job_id uuid,
  p_job_type public.ai_job_type,
  p_subject_id uuid,
  p_idempotency_key text,
  p_input_hash text,
  p_input_version text,
  p_prompt_version text default '1',
  p_model_version text default 'default',
  p_schema_version text default '1',
  p_max_attempts integer default 3
)
returns setof public.ai_jobs
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_job public.ai_jobs%rowtype;
  v_key text := trim(coalesce(p_idempotency_key, ''));
begin
  if v_user_id is null then
    raise exception 'Authentication required';
  end if;
  if v_key = '' then
    raise exception 'Idempotency key is required';
  end if;
  if trim(coalesce(p_input_hash, '')) = '' then
    raise exception 'Input hash is required';
  end if;
  if trim(coalesce(p_input_version, '')) = '' then
    raise exception 'Input version is required';
  end if;
  if p_max_attempts < 1 or p_max_attempts > 10 then
    raise exception 'Max attempts must be between 1 and 10';
  end if;

  select *
  into v_job
  from public.ai_jobs
  where user_id = v_user_id
    and idempotency_key = v_key
    and status in ('queued', 'running', 'retrying')
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
      v_user_id,
      p_job_type,
      p_subject_id,
      v_key,
      trim(p_input_hash),
      trim(p_input_version),
      coalesce(nullif(trim(p_prompt_version), ''), '1'),
      coalesce(nullif(trim(p_model_version), ''), 'default'),
      coalesce(nullif(trim(p_schema_version), ''), '1'),
      p_max_attempts
    )
    on conflict (user_id, idempotency_key)
      where status in ('queued', 'running', 'retrying')
    do nothing
    returning * into v_job;

    if v_job.id is null then
      select *
      into v_job
      from public.ai_jobs
      where user_id = v_user_id
        and idempotency_key = v_key
        and status in ('queued', 'running', 'retrying')
      order by created_at
      limit 1;
    else
      perform public.emit_sync_event(
        v_user_id,
        'ai_job',
        v_job.id,
        'queued',
        jsonb_build_object(
          'aiJobId', v_job.id,
          'subjectId', v_job.subject_id,
          'jobType', v_job.job_type
        )
      );
    end if;
  end if;

  return next v_job;
end;
$$;

create or replace function public.api_get_ai_jobs(
  p_ids uuid[] default null
)
returns setof public.ai_jobs
language sql
stable
security definer
set search_path = public
as $$
  select jobs.*
  from public.ai_jobs jobs
  where jobs.user_id = auth.uid()
    and (p_ids is null or jobs.id = any(p_ids))
  order by jobs.updated_at desc;
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
    canceled_at = null
  where id = p_job_id
    and user_id = v_user_id
    and status = 'failed'
  returning * into v_job;

  if v_job.id is null then
    raise exception 'AI job % cannot be retried', p_job_id;
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

create or replace function public.api_cancel_ai_job(
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
    status = 'canceled',
    canceled_at = now(),
    next_retry_at = null
  where id = p_job_id
    and user_id = v_user_id
    and status in ('queued', 'retrying')
  returning * into v_job;

  if v_job.id is null then
    raise exception 'AI job % cannot be canceled', p_job_id;
  end if;

  perform public.emit_sync_event(
    v_user_id,
    'ai_job',
    v_job.id,
    'canceled',
    jsonb_build_object('aiJobId', v_job.id, 'subjectId', v_job.subject_id)
  );
  return next v_job;
end;
$$;

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
    normalized_error = null
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

create or replace function public.internal_complete_ai_job(
  p_job_id uuid,
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
  update public.ai_jobs
  set
    status = 'succeeded',
    normalized_result = coalesce(p_normalized_result, '{}'::jsonb),
    normalized_error = null,
    completed_at = now(),
    failed_at = null,
    next_retry_at = null
  where id = p_job_id
    and status = 'running'
  returning * into v_job;

  if v_job.id is null then
    raise exception 'AI job % is not running', p_job_id;
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

create or replace function public.internal_fail_ai_job(
  p_job_id uuid,
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
  select *
  into v_job
  from public.ai_jobs
  where id = p_job_id
    and status = 'running'
  for update;

  if v_job.id is null then
    raise exception 'AI job % is not running', p_job_id;
  end if;

  if coalesce(p_retryable, false) and v_job.attempt_count < v_job.max_attempts then
    v_next_status := 'retrying';
    v_next_retry_at := now() + make_interval(
      secs => least(300, 5 * power(2, greatest(v_job.attempt_count - 1, 0))::integer)
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
    failed_at = case when v_next_status = 'failed' then now() else null end
  where id = p_job_id
  returning * into v_job;

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

revoke all on table public.ai_jobs from public, anon, authenticated;
grant select on table public.ai_jobs to authenticated;
grant select, insert, update, delete on table public.ai_jobs to service_role;

revoke all on function public.api_schedule_ai_job(
  uuid,
  public.ai_job_type,
  uuid,
  text,
  text,
  text,
  text,
  text,
  text,
  integer
) from public, anon, authenticated;
grant execute on function public.api_schedule_ai_job(
  uuid,
  public.ai_job_type,
  uuid,
  text,
  text,
  text,
  text,
  text,
  text,
  integer
) to authenticated;

revoke all on function public.api_get_ai_jobs(uuid[])
from public, anon, authenticated;
grant execute on function public.api_get_ai_jobs(uuid[]) to authenticated;

revoke all on function public.api_retry_ai_job(uuid)
from public, anon, authenticated;
grant execute on function public.api_retry_ai_job(uuid) to authenticated;

revoke all on function public.api_cancel_ai_job(uuid)
from public, anon, authenticated;
grant execute on function public.api_cancel_ai_job(uuid) to authenticated;

revoke all on function public.internal_claim_ai_job(public.ai_job_type[])
from public, anon, authenticated;
grant execute on function public.internal_claim_ai_job(public.ai_job_type[])
to service_role;

revoke all on function public.internal_complete_ai_job(uuid, jsonb)
from public, anon, authenticated;
grant execute on function public.internal_complete_ai_job(uuid, jsonb)
to service_role;

revoke all on function public.internal_fail_ai_job(uuid, boolean, jsonb)
from public, anon, authenticated;
grant execute on function public.internal_fail_ai_job(uuid, boolean, jsonb)
to service_role;

notify pgrst, 'reload schema';
