begin;

select plan(4);

select set_eq(
  $$
    select table_name::text
    from information_schema.tables
    where table_schema = 'public'
      and table_type = 'BASE TABLE'
  $$,
  $$ values
    ('ai_usage_records'),
    ('processing_assets'),
    ('processing_jobs'),
    ('service_entitlements')
  $$,
  'the reduced backend exposes only service and processing tables'
);

select is(
  (
    select count(*)
    from information_schema.routines
    where routine_schema = 'public'
      and routine_name ~ '(dish|capture_batch|review|sync|menu)'
  ),
  0::bigint,
  'the reduced backend exposes no legacy menu or sync routines'
);

select set_eq(
  $$
    select p.proname || '(' || pg_get_function_identity_arguments(p.oid)
      || ') -> ' || pg_get_function_result(p.oid)
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
  $$,
  $$ values
    ('internal_begin_service_identity_deletion(p_user_id uuid) -> boolean'),
    ('internal_claim_processing_job() -> SETOF processing_jobs'),
    ('internal_complete_capture_processing_job(p_job_id uuid, p_lease_token uuid, p_result jsonb, p_provider text, p_model text, p_input_tokens integer, p_output_tokens integer) -> SETOF processing_jobs'),
    ('internal_complete_processing_job(p_job_id uuid, p_lease_token uuid, p_result jsonb, p_provider text, p_model text, p_input_tokens integer, p_output_tokens integer) -> SETOF processing_jobs'),
    ('internal_complete_service_identity_deletion(p_user_id uuid) -> boolean'),
    ('internal_create_processing_job(p_user_id uuid, p_operation text, p_idempotency_key text, p_input_schema_version text, p_result_schema_version text, p_privacy_notice_version text, p_assets jsonb, p_limit_units integer, p_allowance_bypass boolean) -> SETOF processing_jobs'),
    ('internal_enqueue_ai_worker(p_function_url text, p_worker_key text) -> bigint'),
    ('internal_expire_inactive_guest_identities(p_inactive_before timestamp with time zone, p_limit integer) -> TABLE(expired_user_id uuid)'),
    ('internal_expire_processing_job(p_job_id uuid) -> SETOF processing_jobs'),
    ('internal_fail_processing_job(p_job_id uuid, p_lease_token uuid, p_error_code text, p_retryable boolean) -> SETOF processing_jobs'),
    ('internal_finish_processing_job(p_user_id uuid, p_job_id uuid, p_status text) -> SETOF processing_jobs'),
    ('internal_get_processing_allowances(p_user_id uuid, p_capture_grouping_limit_units integer, p_capture_grouping_bypass boolean, p_cover_generation_limit_units integer, p_cover_generation_bypass boolean) -> TABLE(operation text, status text, enforcement_enabled boolean, used_units integer, remaining_units integer, limit_units integer)'),
    ('internal_list_orphan_processing_assets(p_limit integer) -> TABLE(storage_bucket text, storage_path text)'),
    ('internal_submit_capture_processing_job(p_user_id uuid, p_job_id uuid, p_input jsonb) -> SETOF processing_jobs'),
    ('internal_submit_processing_job(p_user_id uuid, p_job_id uuid, p_input jsonb) -> SETOF processing_jobs'),
    ('reject_processing_for_deleting_identity() -> trigger')
  $$,
  'the reduced backend exposes exactly the allowlisted RPC surface and shapes'
);

select is(
  (
    select count(*)
    from storage.buckets
    where id = 'menu-media'
  ),
  0::bigint,
  'the durable menu-media bucket is absent'
);

select * from finish();
rollback;
