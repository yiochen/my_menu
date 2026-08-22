create or replace function public.internal_complete_processing_job(
  p_job_id uuid, p_lease_token uuid, p_result jsonb, p_provider text,
  p_model text, p_input_tokens integer default null,
  p_output_tokens integer default null
)
returns setof public.processing_jobs
language plpgsql security definer set search_path = public
as $$
declare
  v_job public.processing_jobs%rowtype;
  v_output jsonb;
  v_byte_size integer;
begin
  if auth.role() <> 'service_role' then
    raise exception 'Service role required';
  end if;
  select * into v_job from public.processing_jobs where id = p_job_id;
  if v_job.operation = 'capture_grouping' then
    return query select * from public.internal_complete_capture_processing_job(
      p_job_id, p_lease_token, p_result, p_provider, p_model,
      p_input_tokens, p_output_tokens
    );
    return;
  end if;
  select * into v_job from public.processing_jobs
    where id = p_job_id and status = 'running' and lease_token = p_lease_token
      and lease_expires_at > now()
    for update;
  if v_job.id is null then
    raise exception 'Processing job does not have the active lease';
  end if;
  v_output := p_result->'output';
  if p_result->>'operation' <> 'cover_generation'
    or p_result->>'schemaVersion' <> 'cover-generation-result-v1'
    or jsonb_typeof(v_output) <> 'object'
    or v_output->>'storageBucket' <> 'processing-media'
    or jsonb_typeof(v_output->'storagePath') <> 'string'
    or v_output->>'contentType' not in ('image/png', 'image/jpeg')
    or jsonb_typeof(v_output->'byteSize') <> 'number'
    or jsonb_typeof(p_result->'validation') <> 'object'
    or p_result->'validation'->>'valid' <> 'true'
    or (p_result->'validation'->>'confidence')::numeric < 0
    or (p_result->'validation'->>'confidence')::numeric > 1 then
    raise exception 'Invalid cover generation result';
  end if;
  begin
    v_byte_size := (v_output->>'byteSize')::integer;
  exception when others then
    raise exception 'Invalid cover generation result';
  end;
  if v_byte_size < 1 or v_byte_size > 20971520
    or not exists (
      select 1 from public.processing_assets asset
      where asset.job_id = p_job_id
        and asset.asset_id = 'cover-output'
        and asset.storage_bucket = v_output->>'storageBucket'
        and asset.storage_path = v_output->>'storagePath'
        and asset.content_type = v_output->>'contentType'
        and asset.byte_size = v_byte_size
    ) then
    raise exception 'Invalid cover generation result';
  end if;
  update public.processing_jobs set
    status = 'succeeded', result_payload = p_result, input_payload = null,
    provider = p_provider, model = p_model, input_tokens = p_input_tokens,
    output_tokens = p_output_tokens, completed_at = now(), updated_at = now(),
    lease_token = null, lease_expires_at = null
    where id = p_job_id
    returning * into v_job;
  return next v_job;
end;
$$;

revoke all on function public.internal_complete_processing_job(
  uuid, uuid, jsonb, text, text, integer, integer
) from public, anon, authenticated;
grant execute on function public.internal_complete_processing_job(
  uuid, uuid, jsonb, text, text, integer, integer
) to service_role;
