begin;

select plan(13);

insert into auth.users (
  instance_id, id, aud, role, email, encrypted_password,
  email_confirmed_at, is_anonymous, created_at, updated_at
) values (
  '00000000-0000-0000-0000-000000000000',
  '00000000-0000-0000-0000-000000000201',
  'authenticated', 'authenticated', 'delete-me@example.com', 'fixture',
  now(), false, now() - interval '30 days', now()
), (
  '00000000-0000-0000-0000-000000000000',
  '00000000-0000-0000-0000-000000000202',
  'authenticated', 'authenticated', null, '', null, true,
  now() - interval '30 days', now()
);

insert into public.service_entitlements (user_id, plan_key)
values ('00000000-0000-0000-0000-000000000201', 'pro');

insert into public.ai_usage_records (
  user_id, operation, units, outcome, idempotency_key, expires_at
) values (
  '00000000-0000-0000-0000-000000000201',
  'capture_grouping', 1, 'succeeded', 'delete-usage',
  now() + interval '30 days'
);

insert into public.processing_jobs (
  id, user_id, operation, status, idempotency_key,
  input_schema_version, result_schema_version, privacy_notice_version,
  expires_at
) values (
  '00000000-0000-0000-0000-000000000211',
  '00000000-0000-0000-0000-000000000201',
  'capture_grouping', 'created',
  '00000000-0000-0000-0000-000000000221',
  'capture-grouping-input-v2', 'capture-grouping-result-v2',
  '2026-08-04-cover-v1', now() + interval '1 day'
);

insert into public.processing_assets (
  job_id, user_id, asset_id, storage_path, content_type, byte_size
) values (
  '00000000-0000-0000-0000-000000000211',
  '00000000-0000-0000-0000-000000000201',
  'delete-asset',
  '00000000-0000-0000-0000-000000000201/delete.jpg',
  'image/jpeg', 4
);

set local request.jwt.claim.role = 'service_role';

select ok(
  public.internal_begin_service_identity_deletion(
    '00000000-0000-0000-0000-000000000201'
  ),
  'a signed service identity can enter deletion'
);

select is(
  (select status from public.service_entitlements
   where user_id = '00000000-0000-0000-0000-000000000201'),
  'deleting',
  'the entitlement row records deletion before asset cleanup'
);

select throws_ok(
  $$
    insert into public.processing_jobs (
      user_id, operation, status, idempotency_key,
      input_schema_version, result_schema_version, privacy_notice_version,
      expires_at
    ) values (
      '00000000-0000-0000-0000-000000000201',
      'capture_grouping', 'created',
      '00000000-0000-0000-0000-000000000222',
      'capture-grouping-input-v2', 'capture-grouping-result-v2',
      '2026-08-04-cover-v1', now() + interval '1 day'
    )
  $$,
  'Service identity deletion is in progress',
  'new processing cannot race account deletion'
);

select ok(
  public.internal_complete_service_identity_deletion(
    '00000000-0000-0000-0000-000000000201'
  ),
  'service identity deletion completes'
);

select is((select count(*) from auth.users where id =
  '00000000-0000-0000-0000-000000000201'), 0::bigint,
  'the auth identity is deleted');
select is((select count(*) from public.service_entitlements where user_id =
  '00000000-0000-0000-0000-000000000201'), 0::bigint,
  'entitlements cascade');
select is((select count(*) from public.ai_usage_records where user_id =
  '00000000-0000-0000-0000-000000000201'), 0::bigint,
  'deletable usage cascades');
select is((select count(*) from public.processing_jobs where user_id =
  '00000000-0000-0000-0000-000000000201'), 0::bigint,
  'processing jobs cascade');
select is((select count(*) from public.processing_assets where user_id =
  '00000000-0000-0000-0000-000000000201'), 0::bigint,
  'processing asset metadata cascades');

select throws_ok(
  $$select public.internal_begin_service_identity_deletion(
    '00000000-0000-0000-0000-000000000202')$$,
  'Signed account required',
  'anonymous service identities cannot use account deletion'
);

set local role authenticated;
set local request.jwt.claim.role = 'authenticated';

select throws_ok(
  $$select public.internal_begin_service_identity_deletion(
    '00000000-0000-0000-0000-000000000202')$$,
  'permission denied for function internal_begin_service_identity_deletion',
  'clients cannot begin deletion through the internal RPC'
);

select throws_ok(
  $$select * from public.internal_list_orphan_processing_assets(10)$$,
  'permission denied for function internal_list_orphan_processing_assets',
  'clients cannot enumerate temporary Storage objects'
);

select throws_ok(
  $$select count(*) from public.service_entitlements$$,
  'permission denied for table service_entitlements',
  'clients cannot inspect service deletion state directly'
);

select * from finish();
rollback;
