create or replace function public.internal_process_capture_ai_jobs(
  p_limit integer default 10
)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_job public.ai_jobs%rowtype;
  v_index integer;
  v_processed integer := 0;
begin
  if p_limit < 1 or p_limit > 100 then
    raise exception 'AI worker limit must be between 1 and 100';
  end if;

  perform set_config('request.jwt.claim.role', 'service_role', true);

  for v_index in 1..p_limit
  loop
    select *
    into v_job
    from public.internal_claim_ai_job(
      array['batch_grouping'::public.ai_job_type]
    );

    exit when v_job.id is null;

    begin
      perform *
      from public.internal_complete_capture_grouping_job(
        v_job.id,
        v_job.lease_token
      );
      v_processed := v_processed + 1;
    exception
      when others then
        perform *
        from public.internal_fail_ai_job(
          v_job.id,
          v_job.lease_token,
          true,
          jsonb_build_object(
            'code', 'capture_grouping_cron_failure',
            'message', sqlerrm
          )
        );
    end;
  end loop;

  return v_processed;
end;
$$;

revoke all on function public.internal_process_capture_ai_jobs(integer)
  from public, anon, authenticated;
grant execute on function public.internal_process_capture_ai_jobs(integer)
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
    'select public.internal_process_capture_ai_jobs(10);'
  );
end;
$$;
