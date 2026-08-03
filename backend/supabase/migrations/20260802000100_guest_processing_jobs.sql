insert into storage.buckets (
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types
)
values (
  'processing-media',
  'processing-media',
  false,
  20971520,
  array['image/jpeg', 'image/png', 'image/heic', 'image/heif']
)
on conflict (id) do update set
  name = excluded.name,
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

create table public.processing_jobs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  operation text not null check (operation in ('capture_grouping')),
  status text not null default 'created' check (
    status in (
      'created', 'queued', 'running', 'succeeded', 'failed',
      'acknowledged', 'canceled', 'expired'
    )
  ),
  idempotency_key text not null check (length(idempotency_key) between 16 and 200),
  input_schema_version text not null,
  result_schema_version text not null,
  privacy_notice_version text not null,
  input_payload jsonb,
  result_payload jsonb,
  error_code text,
  provider text,
  model text,
  input_tokens integer,
  output_tokens integer,
  lease_token uuid,
  lease_expires_at timestamptz,
  -- Leave one cleanup interval inside the 24-hour retention ceiling.
  expires_at timestamptz not null default (now() + interval '23 hours 45 minutes'),
  submitted_at timestamptz,
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, idempotency_key)
);

create index processing_jobs_claim_idx
  on public.processing_jobs(status, created_at)
  where status in ('queued', 'running');
create index processing_jobs_expiry_idx
  on public.processing_jobs(expires_at)
  where status not in ('acknowledged', 'canceled', 'expired');

create table public.processing_assets (
  job_id uuid not null references public.processing_jobs(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  asset_id text not null,
  storage_bucket text not null default 'processing-media'
    check (storage_bucket = 'processing-media'),
  storage_path text not null unique,
  content_type text not null check (
    content_type in ('image/jpeg', 'image/png', 'image/heic', 'image/heif')
  ),
  byte_size integer not null check (byte_size between 1 and 20971520),
  created_at timestamptz not null default now(),
  primary key (job_id, asset_id)
);

create table public.ai_usage_records (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  operation text not null check (operation in ('capture_grouping')),
  units integer not null default 1 check (units > 0),
  outcome text not null default 'reserved' check (
    outcome in ('reserved', 'succeeded', 'failed', 'canceled', 'expired')
  ),
  idempotency_key text not null,
  created_at timestamptz not null default now(),
  expires_at timestamptz not null default (now() + interval '90 days'),
  unique (user_id, idempotency_key)
);

alter table public.processing_jobs enable row level security;
alter table public.processing_assets enable row level security;
alter table public.ai_usage_records enable row level security;

grant all on public.processing_jobs to service_role;
grant all on public.processing_assets to service_role;
grant all on public.ai_usage_records to service_role;
grant usage, select on sequence public.ai_usage_records_id_seq to service_role;

create policy processing_jobs_select_own
on public.processing_jobs for select
to authenticated
using (user_id = auth.uid());

grant select on public.processing_jobs to authenticated;

create or replace function public.internal_create_processing_job(
  p_user_id uuid,
  p_operation text,
  p_idempotency_key text,
  p_input_schema_version text,
  p_result_schema_version text,
  p_privacy_notice_version text,
  p_assets jsonb
)
returns setof public.processing_jobs
language plpgsql
security definer
set search_path = public, storage
as $$
declare
  v_job public.processing_jobs%rowtype;
  v_asset jsonb;
  v_asset_id text;
  v_content_type text;
  v_byte_size integer;
  v_extension text;
begin
  if auth.role() <> 'service_role' then
    raise exception 'Service role required';
  end if;
  if p_operation <> 'capture_grouping' then
    raise exception 'Unsupported processing operation';
  end if;
  if p_input_schema_version <> 'capture-grouping-input-v1'
    or p_result_schema_version <> 'capture-grouping-result-v1' then
    raise exception 'Unsupported processing contract';
  end if;
  if p_idempotency_key !~* '^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$' then
    raise exception 'Invalid processing idempotency key';
  end if;
  if jsonb_typeof(p_assets) <> 'array' or jsonb_array_length(p_assets) > 10 then
    raise exception 'Processing assets must be an array with at most 10 items';
  end if;

  perform pg_advisory_xact_lock(
    hashtextextended(p_user_id::text, 0)
  );
  select * into v_job
  from public.processing_jobs
  where user_id = p_user_id and idempotency_key = p_idempotency_key;
  if v_job.id is not null then
    if v_job.operation <> p_operation
      or v_job.input_schema_version <> p_input_schema_version
      or v_job.result_schema_version <> p_result_schema_version then
      raise exception 'Idempotency key reused with a different processing contract';
    end if;
    return next v_job;
    return;
  end if;

  if (
    select coalesce(sum(units), 0)
    from public.ai_usage_records
    where user_id = p_user_id
      and created_at >= now() - interval '30 days'
  ) >= 10 then
    raise exception 'free_allowance_exhausted';
  end if;

  insert into public.processing_jobs (
    user_id,
    operation,
    idempotency_key,
    input_schema_version,
    result_schema_version,
    privacy_notice_version
  ) values (
    p_user_id,
    p_operation,
    p_idempotency_key,
    p_input_schema_version,
    p_result_schema_version,
    p_privacy_notice_version
  ) returning * into v_job;

  for v_asset in select value from jsonb_array_elements(p_assets)
  loop
    v_asset_id := nullif(trim(v_asset->>'assetId'), '');
    v_content_type := v_asset->>'contentType';
    v_byte_size := (v_asset->>'byteSize')::integer;
    if v_asset_id is null or v_content_type not in (
      'image/jpeg', 'image/png', 'image/heic', 'image/heif'
    ) or v_byte_size < 1 or v_byte_size > 20971520 then
      raise exception 'Invalid processing asset manifest';
    end if;
    v_extension := case v_content_type
      when 'image/png' then 'png'
      when 'image/heic' then 'heic'
      when 'image/heif' then 'heif'
      else 'jpg'
    end;
    insert into public.processing_assets (
      job_id,
      user_id,
      asset_id,
      storage_path,
      content_type,
      byte_size
    ) values (
      v_job.id,
      p_user_id,
      v_asset_id,
      v_job.id::text || '/' || encode(sha256(v_asset_id::bytea), 'hex') ||
        '.' || v_extension,
      v_content_type,
      v_byte_size
    );
  end loop;

  insert into public.ai_usage_records (
    user_id,
    operation,
    idempotency_key
  ) values (p_user_id, p_operation, p_idempotency_key);

  return next v_job;
end;
$$;

create or replace function public.internal_submit_processing_job(
  p_user_id uuid,
  p_job_id uuid,
  p_input jsonb
)
returns setof public.processing_jobs
language plpgsql
security definer
set search_path = public, storage
as $$
declare
  v_job public.processing_jobs%rowtype;
  v_expected_assets integer;
  v_uploaded_assets integer;
begin
  if auth.role() <> 'service_role' then
    raise exception 'Service role required';
  end if;
  select * into v_job from public.processing_jobs
  where id = p_job_id and user_id = p_user_id for update;
  if v_job.id is null then
    raise exception 'Processing job not found';
  end if;
  if v_job.status in ('queued', 'running', 'succeeded') then
    return next v_job;
    return;
  end if;
  if v_job.status <> 'created' or v_job.expires_at <= now() then
    raise exception 'Processing job cannot be submitted';
  end if;
  if jsonb_typeof(p_input) <> 'object'
    or jsonb_typeof(p_input->'captures') <> 'array'
    or jsonb_array_length(p_input->'captures') = 0
    or jsonb_typeof(p_input->'dishes') <> 'array' then
    raise exception 'Invalid capture grouping input';
  end if;

  select count(*) into v_expected_assets
  from public.processing_assets where job_id = p_job_id;
  select count(*) into v_uploaded_assets
  from public.processing_assets assets
  join storage.objects objects
    on objects.bucket_id = assets.storage_bucket
   and objects.name = assets.storage_path
  where assets.job_id = p_job_id;
  if v_expected_assets <> v_uploaded_assets then
    raise exception 'Processing assets are not uploaded';
  end if;

  update public.processing_jobs
  set status = 'queued', input_payload = p_input, submitted_at = now(),
      updated_at = now(), error_code = null
  where id = p_job_id
  returning * into v_job;
  return next v_job;
end;
$$;

create or replace function public.internal_claim_processing_job()
returns setof public.processing_jobs
language plpgsql
security definer
set search_path = public
as $$
declare
  v_job public.processing_jobs%rowtype;
begin
  if auth.role() <> 'service_role' then
    raise exception 'Service role required';
  end if;
  select * into v_job
  from public.processing_jobs
  where status = 'queued' and expires_at > now()
  order by created_at
  for update skip locked
  limit 1;
  if v_job.id is null then
    return;
  end if;
  update public.processing_jobs
  set status = 'running', lease_token = gen_random_uuid(),
      lease_expires_at = now() + interval '3 minutes', updated_at = now()
  where id = v_job.id returning * into v_job;
  return next v_job;
end;
$$;

create or replace function public.internal_complete_processing_job(
  p_job_id uuid,
  p_lease_token uuid,
  p_result jsonb,
  p_provider text,
  p_model text,
  p_input_tokens integer default null,
  p_output_tokens integer default null
)
returns setof public.processing_jobs
language plpgsql
security definer
set search_path = public
as $$
declare
  v_job public.processing_jobs%rowtype;
  v_expected_ids text[];
  v_result_ids text[];
begin
  if auth.role() <> 'service_role' then
    raise exception 'Service role required';
  end if;
  select * into v_job from public.processing_jobs
  where id = p_job_id and status = 'running' and lease_token = p_lease_token
    and lease_expires_at > now() for update;
  if v_job.id is null then
    raise exception 'Processing job does not have the active lease';
  end if;
  if p_result->>'operation' <> v_job.operation
    or p_result->>'schemaVersion' <> v_job.result_schema_version
    or jsonb_typeof(p_result->'groups') <> 'array'
    or jsonb_typeof(p_result->'rejectedCaptures') <> 'array' then
    raise exception 'Invalid capture grouping proposal';
  end if;
  select array_agg(value->>'id' order by value->>'id') into v_expected_ids
  from jsonb_array_elements(v_job.input_payload->'captures') captures(value);
  select array_agg(capture_id order by capture_id) into v_result_ids
  from (
    select jsonb_array_elements_text(value->'captureIds') as capture_id
    from jsonb_array_elements(p_result->'groups') groups(value)
    union all
    select value->>'captureId'
    from jsonb_array_elements(p_result->'rejectedCaptures') rejected(value)
  ) decisions;
  if v_result_ids is distinct from v_expected_ids
    or cardinality(v_result_ids) <> cardinality(array(select distinct unnest(v_result_ids))) then
    raise exception 'Proposal must exactly partition submitted captures';
  end if;

  update public.processing_jobs
  set status = 'succeeded', result_payload = p_result, input_payload = null,
      provider = p_provider, model = p_model, input_tokens = p_input_tokens,
      output_tokens = p_output_tokens, completed_at = now(), updated_at = now(),
      lease_token = null, lease_expires_at = null
  where id = p_job_id returning * into v_job;
  update public.ai_usage_records set outcome = 'succeeded'
  where user_id = v_job.user_id and idempotency_key = v_job.idempotency_key;
  return next v_job;
end;
$$;

create or replace function public.internal_fail_processing_job(
  p_job_id uuid,
  p_lease_token uuid,
  p_error_code text
)
returns setof public.processing_jobs
language plpgsql
security definer
set search_path = public
as $$
declare
  v_job public.processing_jobs%rowtype;
begin
  if auth.role() <> 'service_role' then
    raise exception 'Service role required';
  end if;
  update public.processing_jobs
  set status = 'failed', error_code = left(p_error_code, 80),
      input_payload = null, result_payload = null, updated_at = now(),
      lease_token = null, lease_expires_at = null
  where id = p_job_id and status = 'running' and lease_token = p_lease_token
  returning * into v_job;
  if v_job.id is null then
    raise exception 'Processing job does not have the active lease';
  end if;
  update public.ai_usage_records set outcome = 'failed'
  where user_id = v_job.user_id and idempotency_key = v_job.idempotency_key;
  return next v_job;
end;
$$;

create or replace function public.internal_finish_processing_job(
  p_user_id uuid,
  p_job_id uuid,
  p_status text
)
returns setof public.processing_jobs
language plpgsql
security definer
set search_path = public
as $$
declare
  v_job public.processing_jobs%rowtype;
begin
  if auth.role() <> 'service_role' then
    raise exception 'Service role required';
  end if;
  if p_status not in ('acknowledged', 'canceled') then
    raise exception 'Invalid final processing status';
  end if;
  select * into v_job from public.processing_jobs
  where id = p_job_id and user_id = p_user_id for update;
  if v_job.id is null then
    raise exception 'Processing job not found';
  end if;
  if p_status = 'acknowledged' and v_job.status not in ('succeeded', 'acknowledged') then
    raise exception 'Only succeeded processing can be acknowledged';
  end if;
  if v_job.status = p_status then
    return next v_job;
    return;
  end if;
  update public.processing_jobs
  set status = p_status, input_payload = null, result_payload = null,
      lease_token = null, lease_expires_at = null, updated_at = now()
  where id = p_job_id returning * into v_job;
  delete from public.processing_assets where job_id = p_job_id;
  if p_status = 'canceled' then
    update public.ai_usage_records set outcome = 'canceled'
    where user_id = v_job.user_id and idempotency_key = v_job.idempotency_key;
  end if;
  return next v_job;
end;
$$;

create or replace function public.internal_expire_processing_job(p_job_id uuid)
returns setof public.processing_jobs
language plpgsql
security definer
set search_path = public
as $$
declare
  v_job public.processing_jobs%rowtype;
begin
  if auth.role() <> 'service_role' then
    raise exception 'Service role required';
  end if;
  update public.processing_jobs
  set status = 'expired', input_payload = null, result_payload = null,
      lease_token = null, lease_expires_at = null, updated_at = now()
  where id = p_job_id and expires_at <= now()
    and status not in ('acknowledged', 'canceled', 'expired')
  returning * into v_job;
  if v_job.id is null then
    return;
  end if;
  delete from public.processing_assets where job_id = p_job_id;
  update public.ai_usage_records set outcome = 'expired'
  where user_id = v_job.user_id and idempotency_key = v_job.idempotency_key;
  return next v_job;
end;
$$;

revoke all on function public.internal_create_processing_job(
  uuid, text, text, text, text, text, jsonb
) from public, anon, authenticated;
revoke all on function public.internal_submit_processing_job(uuid, uuid, jsonb)
  from public, anon, authenticated;
revoke all on function public.internal_claim_processing_job()
  from public, anon, authenticated;
revoke all on function public.internal_complete_processing_job(
  uuid, uuid, jsonb, text, text, integer, integer
) from public, anon, authenticated;
revoke all on function public.internal_fail_processing_job(uuid, uuid, text)
  from public, anon, authenticated;
revoke all on function public.internal_finish_processing_job(uuid, uuid, text)
  from public, anon, authenticated;
revoke all on function public.internal_expire_processing_job(uuid)
  from public, anon, authenticated;

grant execute on function public.internal_create_processing_job(
  uuid, text, text, text, text, text, jsonb
) to service_role;
grant execute on function public.internal_submit_processing_job(uuid, uuid, jsonb)
  to service_role;
grant execute on function public.internal_claim_processing_job()
  to service_role;
grant execute on function public.internal_complete_processing_job(
  uuid, uuid, jsonb, text, text, integer, integer
) to service_role;
grant execute on function public.internal_fail_processing_job(uuid, uuid, text)
  to service_role;
grant execute on function public.internal_finish_processing_job(uuid, uuid, text)
  to service_role;
grant execute on function public.internal_expire_processing_job(uuid)
  to service_role;

do $$
begin
  if exists (
    select 1 from cron.job where jobname = 'mymenu-cleanup-processing-jobs'
  ) then
    perform cron.unschedule('mymenu-cleanup-processing-jobs');
  end if;
  perform cron.schedule(
    'mymenu-cleanup-processing-jobs',
    '*/15 * * * *',
    $cron$
      select net.http_post(
        url := secrets.project_url || '/functions/v1/cleanup-processing-jobs',
        body := '{}'::jsonb,
        headers := jsonb_build_object(
          'Content-Type', 'application/json',
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
      where secrets.project_url is not null and secrets.worker_key is not null;
    $cron$
  );
end;
$$;
