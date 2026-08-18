drop function public.internal_create_processing_job(
  uuid, text, text, text, text, text, jsonb
);

create function public.internal_create_processing_job(
  p_user_id uuid,
  p_operation text,
  p_idempotency_key text,
  p_input_schema_version text,
  p_result_schema_version text,
  p_privacy_notice_version text,
  p_assets jsonb,
  p_limit_units integer,
  p_allowance_bypass boolean
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
  v_is_capture_v2 boolean;
  v_is_cover boolean;
begin
  if auth.role() <> 'service_role' then
    raise exception 'Service role required';
  end if;
  if p_limit_units is null or p_limit_units < 0
    or p_allowance_bypass is null then
    raise exception 'Invalid processing allowance policy';
  end if;

  v_is_capture_v2 := p_operation = 'capture_grouping'
    and p_input_schema_version = 'capture-grouping-input-v2'
    and p_result_schema_version = 'capture-grouping-result-v2';
  v_is_cover := p_operation = 'cover_generation'
    and p_input_schema_version = 'cover-generation-input-v1'
    and p_result_schema_version = 'cover-generation-result-v1';
  if not v_is_cover and not v_is_capture_v2 and not (
    p_operation = 'capture_grouping'
    and p_input_schema_version = 'capture-grouping-input-v1'
    and p_result_schema_version = 'capture-grouping-result-v1'
  ) then
    raise exception 'Unsupported processing contract';
  end if;
  if (v_is_cover or v_is_capture_v2)
    and p_privacy_notice_version <> '2026-08-04-cover-v1' then
    raise exception 'Obsolete processing privacy notice';
  end if;
  if p_idempotency_key
    !~* '^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$' then
    raise exception 'Invalid processing idempotency key';
  end if;
  if jsonb_typeof(p_assets) <> 'array'
    or jsonb_array_length(p_assets) > (case when v_is_cover then 3 else 10 end)
  then
    raise exception 'Invalid processing asset manifest';
  end if;

  perform pg_advisory_xact_lock(
    hashtextextended(p_user_id::text || p_operation, 0)
  );
  select * into v_job
  from public.processing_jobs
  where user_id = p_user_id
    and idempotency_key = p_idempotency_key;
  if v_job.id is not null then
    if v_job.operation <> p_operation
      or v_job.input_schema_version <> p_input_schema_version
      or v_job.result_schema_version <> p_result_schema_version then
      raise exception
        'Idempotency key reused with a different processing contract';
    end if;
    return next v_job;
    return;
  end if;

  if not p_allowance_bypass and (
    select coalesce(sum(
      case when outcome = 'reserved' then 1 else units end
    ), 0)
    from public.ai_usage_records
    where user_id = p_user_id
      and operation = p_operation
      and created_at >= now() - interval '30 days'
  ) >= p_limit_units then
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

  for v_asset in select value from jsonb_array_elements(p_assets) loop
    v_asset_id := nullif(trim(v_asset->>'assetId'), '');
    v_content_type := v_asset->>'contentType';
    v_byte_size := (v_asset->>'byteSize')::integer;
    if v_asset_id is null
      or v_asset_id
        !~* '^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'
      or v_content_type not in (
        'image/jpeg', 'image/png', 'image/heic', 'image/heif'
      )
      or ((v_is_cover or v_is_capture_v2) and v_content_type <> 'image/jpeg')
      or v_byte_size < 1
      or v_byte_size > 20971520 then
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
      v_job.id::text || '/'
        || encode(sha256(v_asset_id::bytea), 'hex') || '.' || v_extension,
      v_content_type,
      v_byte_size
    );
  end loop;

  insert into public.ai_usage_records (
    user_id,
    operation,
    units,
    idempotency_key
  ) values (
    p_user_id,
    p_operation,
    case when v_is_cover then 0 else 1 end,
    p_idempotency_key
  );
  return next v_job;
end;
$$;

create function public.internal_get_processing_allowances(
  p_user_id uuid,
  p_capture_grouping_limit_units integer,
  p_capture_grouping_bypass boolean,
  p_cover_generation_limit_units integer,
  p_cover_generation_bypass boolean
)
returns table (
  operation text,
  status text,
  enforcement_enabled boolean,
  used_units integer,
  remaining_units integer,
  limit_units integer
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_operation text;
  v_bypass boolean;
  v_used integer;
begin
  if auth.role() <> 'service_role' then
    raise exception 'Service role required';
  end if;
  if p_capture_grouping_limit_units is null
    or p_capture_grouping_limit_units < 0
    or p_capture_grouping_bypass is null
    or p_cover_generation_limit_units is null
    or p_cover_generation_limit_units < 0
    or p_cover_generation_bypass is null then
    raise exception 'Invalid processing allowance policy';
  end if;

  foreach v_operation in array array[
    'capture_grouping', 'cover_generation'
  ] loop
    if v_operation = 'capture_grouping' then
      limit_units := p_capture_grouping_limit_units;
      v_bypass := p_capture_grouping_bypass;
    else
      limit_units := p_cover_generation_limit_units;
      v_bypass := p_cover_generation_bypass;
    end if;

    select coalesce(sum(
      case when usage.outcome = 'reserved' then 1 else usage.units end
    ), 0)::integer
    into v_used
    from public.ai_usage_records usage
    where usage.user_id = p_user_id
      and usage.operation = v_operation
      and usage.created_at >= now() - interval '30 days';

    operation := v_operation;
    enforcement_enabled := not v_bypass;
    used_units := v_used;
    if v_bypass then
      status := 'enforcement_disabled';
      remaining_units := null;
    elsif v_used >= limit_units then
      status := 'exhausted';
      remaining_units := 0;
    else
      status := 'enforced';
      remaining_units := limit_units - v_used;
    end if;
    return next;
  end loop;
end;
$$;

revoke all on function public.internal_create_processing_job(
  uuid, text, text, text, text, text, jsonb, integer, boolean
) from public, anon, authenticated;
revoke all on function public.internal_get_processing_allowances(
  uuid, integer, boolean, integer, boolean
) from public, anon, authenticated;
grant execute on function public.internal_create_processing_job(
  uuid, text, text, text, text, text, jsonb, integer, boolean
) to service_role;
grant execute on function public.internal_get_processing_allowances(
  uuid, integer, boolean, integer, boolean
) to service_role;
