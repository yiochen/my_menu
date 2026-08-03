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
  v_is_v2 boolean;
begin
  if auth.role() <> 'service_role' then
    raise exception 'Service role required';
  end if;
  if p_operation <> 'capture_grouping' then
    raise exception 'Unsupported processing operation';
  end if;
  v_is_v2 := p_input_schema_version = 'capture-grouping-input-v2'
    and p_result_schema_version = 'capture-grouping-result-v2';
  if not v_is_v2 and not (
    p_input_schema_version = 'capture-grouping-input-v1'
    and p_result_schema_version = 'capture-grouping-result-v1'
  ) then
    raise exception 'Unsupported processing contract';
  end if;
  if v_is_v2 and p_privacy_notice_version <> '2026-08-03' then
    raise exception 'Obsolete processing privacy notice';
  end if;
  if p_idempotency_key !~* '^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$' then
    raise exception 'Invalid processing idempotency key';
  end if;
  if jsonb_typeof(p_assets) <> 'array' or jsonb_array_length(p_assets) > 10 then
    raise exception 'Processing assets must be an array with at most 10 items';
  end if;

  perform pg_advisory_xact_lock(hashtextextended(p_user_id::text, 0));
  select * into v_job from public.processing_jobs
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
    select coalesce(sum(units), 0) from public.ai_usage_records
    where user_id = p_user_id and created_at >= now() - interval '30 days'
  ) >= 10 then
    raise exception 'free_allowance_exhausted';
  end if;

  insert into public.processing_jobs (
    user_id, operation, idempotency_key, input_schema_version,
    result_schema_version, privacy_notice_version
  ) values (
    p_user_id, p_operation, p_idempotency_key, p_input_schema_version,
    p_result_schema_version, p_privacy_notice_version
  ) returning * into v_job;

  for v_asset in select value from jsonb_array_elements(p_assets)
  loop
    v_asset_id := nullif(trim(v_asset->>'assetId'), '');
    v_content_type := v_asset->>'contentType';
    v_byte_size := (v_asset->>'byteSize')::integer;
    if v_asset_id is null
      or v_asset_id !~* '^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'
      or v_content_type not in ('image/jpeg', 'image/png', 'image/heic', 'image/heif')
      or (v_is_v2 and v_content_type <> 'image/jpeg')
      or v_byte_size < 1 or v_byte_size > 20971520 then
      raise exception 'Invalid processing asset manifest';
    end if;
    v_extension := case v_content_type
      when 'image/png' then 'png'
      when 'image/heic' then 'heic'
      when 'image/heif' then 'heif'
      else 'jpg'
    end;
    insert into public.processing_assets (
      job_id, user_id, asset_id, storage_path, content_type, byte_size
    ) values (
      v_job.id, p_user_id, v_asset_id,
      v_job.id::text || '/' || encode(sha256(v_asset_id::bytea), 'hex') || '.' || v_extension,
      v_content_type, v_byte_size
    );
  end loop;

  insert into public.ai_usage_records (user_id, operation, idempotency_key)
  values (p_user_id, p_operation, p_idempotency_key);
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
    or p_result->>'schemaVersion' <> v_job.result_schema_version then
    raise exception 'Invalid capture grouping proposal';
  end if;

  select array_agg(value->>'id' order by value->>'id') into v_expected_ids
  from jsonb_array_elements(v_job.input_payload->'captures') captures(value);
  if v_job.result_schema_version = 'capture-grouping-result-v2' then
    if jsonb_typeof(p_result->'decisions') <> 'array' then
      raise exception 'Invalid capture routing proposal';
    end if;
    select array_agg(capture_id order by capture_id) into v_result_ids
    from (
      select jsonb_array_elements_text(value->'captureIds') as capture_id
      from jsonb_array_elements(p_result->'decisions') decisions(value)
    ) routed;
  else
    if jsonb_typeof(p_result->'groups') <> 'array'
      or jsonb_typeof(p_result->'rejectedCaptures') <> 'array' then
      raise exception 'Invalid capture grouping proposal';
    end if;
    select array_agg(capture_id order by capture_id) into v_result_ids
    from (
      select jsonb_array_elements_text(value->'captureIds') as capture_id
      from jsonb_array_elements(p_result->'groups') groups(value)
      union all
      select value->>'captureId'
      from jsonb_array_elements(p_result->'rejectedCaptures') rejected(value)
    ) decisions;
  end if;
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
