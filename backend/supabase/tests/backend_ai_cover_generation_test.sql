begin;
select plan(8);

insert into auth.users (
  id, instance_id, aud, role, email, encrypted_password,
  email_confirmed_at, created_at, updated_at
) values (
  '00000000-0000-4000-8000-000000000256',
  '00000000-0000-0000-0000-000000000000',
  'authenticated', 'authenticated', 'cover-guest@example.com', '',
  now(), now(), now()
);
select set_config('request.jwt.claim.role', 'service_role', true);

select throws_ok(
  $$ select * from public.internal_create_processing_job(
    '00000000-0000-4000-8000-000000000256','cover_generation',
    '00000000-0000-4000-8000-000000000257','cover-generation-input-v1',
    'cover-generation-result-v1','2026-08-04','[]'::jsonb
  ) $$,
  'P0001','Obsolete processing privacy notice',
  'cover generation rejects organization-only consent'
);

select is((select operation from public.internal_create_processing_job(
  '00000000-0000-4000-8000-000000000256','cover_generation',
  '00000000-0000-4000-8000-000000000257','cover-generation-input-v1',
  'cover-generation-result-v1','2026-08-04-cover-v1','[]'::jsonb
)), 'cover_generation', 'a zero-source idea cover can be created');

select is((select units from public.ai_usage_records where idempotency_key=
  '00000000-0000-4000-8000-000000000257'), 0,
  'cover allowance is not charged at creation');

select is((select status::text from public.internal_submit_processing_job(
  '00000000-0000-4000-8000-000000000256',
  (select id from public.processing_jobs where idempotency_key=
    '00000000-0000-4000-8000-000000000257'),
  jsonb_build_object(
    'dishTitle','Idea Curry','sources','[]'::jsonb,
    'notes',jsonb_build_array(jsonb_build_object(
      'body','Golden sauce','position',0,
      'createdAt','2026-08-04T00:00:00Z',
      'updatedAt','2026-08-04T00:00:00Z'
    )),
    'treatment',jsonb_build_object('look','natural_polish','view','auto','finish','menu_ready'),
    'origin','manual','contractVersion','cover-generation-v1'
  )
)), 'queued', 'the bounded cover input is accepted');

select is((with lease as (select * from public.internal_claim_processing_job())
  select status::text from public.internal_complete_processing_job(
    (select id from lease),(select lease_token from lease),
    jsonb_build_object(
      'operation','cover_generation','schemaVersion','cover-generation-result-v1',
      'proposalId',gen_random_uuid()::text,
      'output',jsonb_build_object('contentType','image/png','imageBase64','iVBORw0KGgo='),
      'validation',jsonb_build_object('valid',true,'confidence',1),
      'provenance',jsonb_build_object('provider','fake','model','fake')
    ),'fake','fake-cover-v1',null,null
  )), 'succeeded', 'a validated cover can be delivered');

select is((select units from public.ai_usage_records where idempotency_key=
  '00000000-0000-4000-8000-000000000257'), 0,
  'delivery still waits for durable client adoption');

select is((select status::text from public.internal_finish_processing_job(
  '00000000-0000-4000-8000-000000000256',
  (select id from public.processing_jobs where idempotency_key=
    '00000000-0000-4000-8000-000000000257'),'acknowledged'
)), 'acknowledged', 'the client can acknowledge durable delivery');

select is((select units from public.ai_usage_records where idempotency_key=
  '00000000-0000-4000-8000-000000000257'), 1,
  'acknowledgement charges the separate cover allowance');

select * from finish();
rollback;
