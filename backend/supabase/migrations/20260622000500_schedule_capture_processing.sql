create extension if not exists pg_net;

create or replace function public.api_schedule_capture_processing(
  p_user_id uuid,
  p_capture_id uuid,
  p_function_url text,
  p_worker_key text,
  p_remote_media_ref text default null,
  p_idea_text text default null
)
returns table (
  capture_id uuid,
  status text,
  request_id bigint,
  sync_cursor bigint
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_cursor bigint;
  v_request_id bigint;
  v_trimmed_idea text;
begin
  if p_function_url is null or length(trim(p_function_url)) = 0 then
    raise exception 'Missing process capture function URL';
  end if;

  if p_worker_key is null or length(p_worker_key) = 0 then
    raise exception 'Missing process capture worker key';
  end if;

  v_trimmed_idea := nullif(trim(coalesce(p_idea_text, '')), '');

  if v_trimmed_idea is not null then
    select created.sync_cursor into v_cursor
    from public.api_create_idea_capture(
      p_user_id,
      p_capture_id,
      v_trimmed_idea,
      now()
    ) as created;
  else
    update public.captures
    set
      status = 'classifying',
      failure_reason = null,
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
      'upsert'
    );
  end if;

  select net.http_post(
    url := p_function_url,
    body := jsonb_build_object(
      'userId', p_user_id,
      'captureId', p_capture_id,
      'remoteMediaRef', p_remote_media_ref,
      'ideaText', v_trimmed_idea
    ),
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || p_worker_key,
      'x-mymenu-worker-key', p_worker_key
    ),
    timeout_milliseconds := 30000
  ) into v_request_id;

  return query select
    p_capture_id::uuid,
    'classifying'::text,
    v_request_id::bigint,
    v_cursor::bigint;
end;
$$;
