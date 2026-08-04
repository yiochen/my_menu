alter table public.processing_jobs drop constraint processing_jobs_operation_check;
alter table public.processing_jobs add constraint processing_jobs_operation_check
  check (operation in ('capture_grouping', 'cover_generation'));

alter table public.ai_usage_records drop constraint ai_usage_records_operation_check;
alter table public.ai_usage_records add constraint ai_usage_records_operation_check
  check (operation in ('capture_grouping', 'cover_generation'));
alter table public.ai_usage_records drop constraint ai_usage_records_units_check;
alter table public.ai_usage_records alter column units set default 0;
alter table public.ai_usage_records add constraint ai_usage_records_units_check
  check (units >= 0);

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
  v_is_capture_v2 boolean;
  v_is_cover boolean;
begin
  if auth.role() <> 'service_role' then raise exception 'Service role required'; end if;
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
  ) then raise exception 'Unsupported processing contract'; end if;
  if (v_is_cover or v_is_capture_v2)
    and p_privacy_notice_version <> '2026-08-04-cover-v1' then
    raise exception 'Obsolete processing privacy notice';
  end if;
  if p_idempotency_key !~* '^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$' then
    raise exception 'Invalid processing idempotency key';
  end if;
  if jsonb_typeof(p_assets) <> 'array'
    or jsonb_array_length(p_assets) > (case when v_is_cover then 3 else 10 end) then
    raise exception 'Invalid processing asset manifest';
  end if;

  perform pg_advisory_xact_lock(hashtextextended(p_user_id::text || p_operation, 0));
  select * into v_job from public.processing_jobs
  where user_id = p_user_id and idempotency_key = p_idempotency_key;
  if v_job.id is not null then
    if v_job.operation <> p_operation
      or v_job.input_schema_version <> p_input_schema_version
      or v_job.result_schema_version <> p_result_schema_version then
      raise exception 'Idempotency key reused with a different processing contract';
    end if;
    return next v_job; return;
  end if;
  if (select coalesce(sum(case when outcome = 'reserved' then 1 else units end), 0)
      from public.ai_usage_records
      where user_id = p_user_id and operation = p_operation
        and created_at >= now() - interval '30 days') >= 10 then
    raise exception 'free_allowance_exhausted';
  end if;

  insert into public.processing_jobs (
    user_id, operation, idempotency_key, input_schema_version,
    result_schema_version, privacy_notice_version
  ) values (
    p_user_id, p_operation, p_idempotency_key, p_input_schema_version,
    p_result_schema_version, p_privacy_notice_version
  ) returning * into v_job;

  for v_asset in select value from jsonb_array_elements(p_assets) loop
    v_asset_id := nullif(trim(v_asset->>'assetId'), '');
    v_content_type := v_asset->>'contentType';
    v_byte_size := (v_asset->>'byteSize')::integer;
    if v_asset_id is null
      or v_asset_id !~* '^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'
      or v_content_type not in ('image/jpeg', 'image/png', 'image/heic', 'image/heif')
      or ((v_is_cover or v_is_capture_v2) and v_content_type <> 'image/jpeg')
      or v_byte_size < 1 or v_byte_size > 20971520 then
      raise exception 'Invalid processing asset manifest';
    end if;
    v_extension := case v_content_type when 'image/png' then 'png'
      when 'image/heic' then 'heic' when 'image/heif' then 'heif' else 'jpg' end;
    insert into public.processing_assets (
      job_id, user_id, asset_id, storage_path, content_type, byte_size
    ) values (
      v_job.id, p_user_id, v_asset_id,
      v_job.id::text || '/' || encode(sha256(v_asset_id::bytea), 'hex') || '.' || v_extension,
      v_content_type, v_byte_size
    );
  end loop;
  insert into public.ai_usage_records (
    user_id, operation, units, idempotency_key
  ) values (
    p_user_id, p_operation, case when v_is_cover then 0 else 1 end,
    p_idempotency_key
  );
  return next v_job;
end;
$$;

alter function public.internal_submit_processing_job(uuid, uuid, jsonb)
  rename to internal_submit_capture_processing_job;

create or replace function public.internal_submit_processing_job(
  p_user_id uuid, p_job_id uuid, p_input jsonb
)
returns setof public.processing_jobs
language plpgsql
security definer
set search_path = public, storage
as $$
declare
  v_job public.processing_jobs%rowtype;
  v_source jsonb;
  v_note jsonb;
  v_expected_assets integer;
  v_uploaded_assets integer;
  v_asset_ids text[] := '{}'::text[];
begin
  if auth.role() <> 'service_role' then raise exception 'Service role required'; end if;
  select * into v_job from public.processing_jobs
    where id = p_job_id and user_id = p_user_id for update;
  if v_job.id is null then raise exception 'Processing job not found'; end if;
  if v_job.operation = 'capture_grouping' then
    return query select * from public.internal_submit_capture_processing_job(
      p_user_id, p_job_id, p_input
    ); return;
  end if;
  if v_job.status in ('queued', 'running', 'succeeded') then return next v_job; return; end if;
  if v_job.status <> 'created' or v_job.expires_at <= now() then
    raise exception 'Processing job cannot be submitted';
  end if;
  if jsonb_typeof(p_input) <> 'object'
    or p_input - array['dishTitle','sources','notes','treatment','origin','contractVersion','coverSnapshot'] <> '{}'::jsonb
    or nullif(trim(p_input->>'dishTitle'), '') is null
    or length(p_input->>'dishTitle') > 300
    or p_input->>'contractVersion' <> 'cover-generation-v1'
    or p_input->>'origin' not in ('automatic','manual')
    or jsonb_typeof(p_input->'sources') <> 'array'
    or jsonb_array_length(p_input->'sources') > 3
    or jsonb_typeof(p_input->'notes') <> 'array'
    or jsonb_array_length(p_input->'notes') > 500
    or jsonb_typeof(p_input->'treatment') <> 'object'
    or (p_input->'treatment') - array['look','view','finish'] <> '{}'::jsonb
    or p_input->'treatment'->>'look' not in ('natural_polish','bright_fresh','warm_cozy','dark_refined')
    or p_input->'treatment'->>'view' not in ('auto','overhead','angled','close_up')
    or p_input->'treatment'->>'finish' not in ('light_touch','menu_ready','editorial')
    or octet_length(p_input::text) > 1048576 then
    raise exception 'Invalid cover generation input';
  end if;
  for v_source in select value from jsonb_array_elements(p_input->'sources') loop
    if jsonb_typeof(v_source) <> 'object'
      or v_source - array['id','assetId'] <> '{}'::jsonb
      or nullif(trim(v_source->>'id'), '') is null
      or nullif(trim(v_source->>'assetId'), '') is null
      or (v_source->>'assetId') = any(v_asset_ids)
      or not exists (select 1 from public.processing_assets
        where job_id = p_job_id and asset_id = v_source->>'assetId') then
      raise exception 'Invalid cover generation input';
    end if;
    v_asset_ids := array_append(v_asset_ids, v_source->>'assetId');
  end loop;
  for v_note in select value from jsonb_array_elements(p_input->'notes') loop
    if jsonb_typeof(v_note) <> 'object'
      or v_note - array['body','position','createdAt','updatedAt'] <> '{}'::jsonb
      or jsonb_typeof(v_note->'body') <> 'string'
      or length(v_note->>'body') > 10000
      or jsonb_typeof(v_note->'position') <> 'number'
      or jsonb_typeof(v_note->'createdAt') <> 'string'
      or jsonb_typeof(v_note->'updatedAt') <> 'string' then
      raise exception 'Invalid cover generation input';
    end if;
  end loop;
  select count(*) into v_expected_assets from public.processing_assets
    where job_id = p_job_id;
  if v_expected_assets <> cardinality(v_asset_ids) then
    raise exception 'Invalid cover generation input';
  end if;
  select count(*) into v_uploaded_assets from public.processing_assets assets
    join storage.objects objects on objects.bucket_id = assets.storage_bucket
      and objects.name = assets.storage_path where assets.job_id = p_job_id;
  if v_expected_assets <> v_uploaded_assets then
    raise exception 'Processing assets are not uploaded';
  end if;
  update public.processing_jobs set status = 'queued', input_payload = p_input,
    submitted_at = now(), updated_at = now(), error_code = null
    where id = p_job_id returning * into v_job;
  return next v_job;
end;
$$;

create or replace function public.internal_claim_processing_job()
returns setof public.processing_jobs
language plpgsql security definer set search_path = public
as $$
declare v_job public.processing_jobs%rowtype;
begin
  if auth.role() <> 'service_role' then raise exception 'Service role required'; end if;
  with exhausted as (
    update public.processing_jobs set status='failed', error_code='worker_lease_exhausted',
      input_payload=null, lease_token=null, lease_expires_at=null,
      next_retry_at=null, updated_at=now()
    where status='running' and lease_expires_at <= now()
      and attempt_count >= max_attempts returning user_id,idempotency_key
  ) update public.ai_usage_records usage set
    outcome='failed',
    units=case when usage.operation='cover_generation' then 0 else usage.units end
    from exhausted where usage.user_id=exhausted.user_id
      and usage.idempotency_key=exhausted.idempotency_key;
  select * into v_job from public.processing_jobs
  where expires_at > now() and attempt_count < max_attempts and (
    (status='queued' and coalesce(next_retry_at,now()) <= now())
    or (status='running' and lease_expires_at <= now()))
  order by case when operation='cover_generation'
    and input_payload->>'origin'='manual' then 0 else 1 end, created_at
  for update skip locked limit 1;
  if v_job.id is null then return; end if;
  update public.processing_jobs set status='running', lease_token=gen_random_uuid(),
    lease_expires_at=now()+interval '3 minutes', attempt_count=attempt_count+1,
    next_retry_at=null, updated_at=now() where id=v_job.id returning * into v_job;
  return next v_job;
end;
$$;

alter function public.internal_complete_processing_job(
  uuid, uuid, jsonb, text, text, integer, integer
) rename to internal_complete_capture_processing_job;

create or replace function public.internal_complete_processing_job(
  p_job_id uuid, p_lease_token uuid, p_result jsonb, p_provider text,
  p_model text, p_input_tokens integer default null,
  p_output_tokens integer default null
)
returns setof public.processing_jobs
language plpgsql security definer set search_path = public
as $$
declare v_job public.processing_jobs%rowtype;
begin
  if auth.role() <> 'service_role' then raise exception 'Service role required'; end if;
  select * into v_job from public.processing_jobs where id=p_job_id;
  if v_job.operation='capture_grouping' then
    return query select * from public.internal_complete_capture_processing_job(
      p_job_id,p_lease_token,p_result,p_provider,p_model,p_input_tokens,p_output_tokens
    ); return;
  end if;
  select * into v_job from public.processing_jobs where id=p_job_id
    and status='running' and lease_token=p_lease_token
    and lease_expires_at > now() for update;
  if v_job.id is null then raise exception 'Processing job does not have the active lease'; end if;
  if p_result->>'operation'<>'cover_generation'
    or p_result->>'schemaVersion'<>'cover-generation-result-v1'
    or jsonb_typeof(p_result->'output')<>'object'
    or jsonb_typeof(p_result->'output'->'imageBase64')<>'string'
    or p_result->'output'->>'contentType' not in ('image/png','image/jpeg')
    or jsonb_typeof(p_result->'validation')<>'object'
    or p_result->'validation'->>'valid'<>'true'
    or (p_result->'validation'->>'confidence')::numeric < 0
    or (p_result->'validation'->>'confidence')::numeric > 1 then
    raise exception 'Invalid cover generation result';
  end if;
  update public.processing_jobs set status='succeeded', result_payload=p_result,
    input_payload=null, provider=p_provider, model=p_model,
    input_tokens=p_input_tokens, output_tokens=p_output_tokens,
    completed_at=now(), updated_at=now(), lease_token=null,lease_expires_at=null
    where id=p_job_id returning * into v_job;
  return next v_job;
end;
$$;

create or replace function public.internal_finish_processing_job(
  p_user_id uuid, p_job_id uuid, p_status text
)
returns setof public.processing_jobs
language plpgsql security definer set search_path = public
as $$
declare v_job public.processing_jobs%rowtype;
begin
  if auth.role()<>'service_role' then raise exception 'Service role required'; end if;
  if p_status not in ('acknowledged','canceled') then raise exception 'Invalid final processing status'; end if;
  select * into v_job from public.processing_jobs where id=p_job_id
    and user_id=p_user_id for update;
  if v_job.id is null then raise exception 'Processing job not found'; end if;
  if p_status='acknowledged' and v_job.status<>'succeeded' then
    raise exception 'Only succeeded processing can be acknowledged';
  end if;
  update public.ai_usage_records set
    outcome=case when p_status='acknowledged' then 'succeeded' else 'canceled' end,
    units=case
      when operation='cover_generation' then
        case when p_status='acknowledged' then 1 else 0 end
      else units
    end
    where user_id=v_job.user_id and idempotency_key=v_job.idempotency_key;
  delete from public.processing_jobs where id=p_job_id;
  v_job.status:=p_status; v_job.input_payload:=null; v_job.result_payload:=null;
  v_job.lease_token:=null; v_job.lease_expires_at:=null;
  return next v_job;
end;
$$;

create or replace function public.api_apply_capture_to_dish(
  p_user_id uuid,
  p_capture_id uuid,
  p_dish_id uuid,
  p_confidence_label text default null,
  p_note text default null,
  p_labels text[] default '{}'
)
returns table (
  capture_id uuid,
  dish_id uuid,
  source_image_id uuid,
  sync_cursor bigint
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_source_image_id uuid;
  v_note_id uuid;
  v_cursor bigint;
begin
  update public.dishes
  set
    labels = (
      select coalesce(array_agg(distinct label order by label), '{}')
      from unnest(public.dishes.labels || coalesce(p_labels, '{}')) as label
    ),
    deleted_at = null
  where id = p_dish_id
    and user_id = p_user_id;

  if not found then
    raise exception 'Dish % does not exist for user %', p_dish_id, p_user_id;
  end if;

  update public.dish_images
  set
    dish_id = p_dish_id,
    kind = 'source_photo',
    labels = coalesce(p_labels, '{}'),
    confidence_label = p_confidence_label,
    deleted_at = null
  where public.dish_images.capture_id = p_capture_id
    and public.dish_images.user_id = p_user_id
    and public.dish_images.kind in ('capture_photo', 'source_photo')
  returning id into v_source_image_id;

  if nullif(trim(p_note), '') is not null then
    v_note_id := gen_random_uuid();
    insert into public.dish_notes (id, user_id, dish_id, body, position)
    values (
      v_note_id,
      p_user_id,
      p_dish_id,
      trim(p_note),
      coalesce((
        select max(notes.position) + 1
        from public.dish_notes notes
        where notes.dish_id = p_dish_id
          and notes.user_id = p_user_id
          and notes.deleted_at is null
      ), 0)
    );
    perform public.emit_sync_event(
      p_user_id,
      'dish_note',
      v_note_id,
      'upsert',
      jsonb_build_object('dishId', p_dish_id)
    );
  end if;

  update public.captures
  set
    status = 'applied',
    applied_dish_id = p_dish_id,
    deleted_at = null
  where id = p_capture_id
    and user_id = p_user_id;

  if not found then
    raise exception 'Capture % does not exist for user %', p_capture_id, p_user_id;
  end if;

  v_cursor := public.emit_sync_event(
    p_user_id,
    'capture',
    p_capture_id,
    'applied_to_existing_dish',
    jsonb_build_object(
      'captureId', p_capture_id,
      'dishId', p_dish_id,
      'sourceImageId', v_source_image_id
    )
  );

  return query select
    p_capture_id::uuid,
    p_dish_id::uuid,
    v_source_image_id::uuid,
    v_cursor::bigint;
end;
$$;

alter table public.dish_images drop column if exists note;

revoke all on function public.internal_submit_capture_processing_job(uuid,uuid,jsonb)
  from public,anon,authenticated;
revoke all on function public.internal_complete_capture_processing_job(
  uuid,uuid,jsonb,text,text,integer,integer
) from public,anon,authenticated;
grant execute on function public.internal_submit_capture_processing_job(uuid,uuid,jsonb)
  to service_role;
grant execute on function public.internal_complete_capture_processing_job(
  uuid,uuid,jsonb,text,text,integer,integer
) to service_role;
