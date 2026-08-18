begin;
select plan(5);

insert into auth.users (
  id, instance_id, aud, role, email, encrypted_password,
  email_confirmed_at, created_at, updated_at
) values (
  '00000000-0000-4000-8000-000000000156',
  '00000000-0000-0000-0000-000000000000',
  'authenticated', 'authenticated', 'routing-guest@example.com', '',
  now(), now(), now()
);

select set_config('request.jwt.claim.role', 'service_role', true);

select throws_ok(
  $$
    select * from public.internal_create_processing_job(
      '00000000-0000-4000-8000-000000000156',
      'capture_grouping',
      '00000000-0000-4000-8000-000000000157',
      'capture-grouping-input-v2',
      'capture-grouping-result-v2',
      '2026-08-03',
      '[]'::jsonb,
      10,
      false
    )
  $$,
  'P0001',
  'Obsolete processing privacy notice',
  'contextual routing requires the current disclosure'
);

select is(
  (
    select input_schema_version from public.internal_create_processing_job(
      '00000000-0000-4000-8000-000000000156',
      'capture_grouping',
      '00000000-0000-4000-8000-000000000157',
      'capture-grouping-input-v2',
      'capture-grouping-result-v2',
      '2026-08-04-cover-v1',
      '[]'::jsonb,
      10,
      false
    )
  ),
  'capture-grouping-input-v2',
  'the versioned contextual contract can be created'
);

select is(
  (
    select status::text from public.internal_submit_processing_job(
      '00000000-0000-4000-8000-000000000156',
      (select id from public.processing_jobs where user_id =
        '00000000-0000-4000-8000-000000000156'),
      jsonb_build_object(
        'captures', jsonb_build_array(jsonb_build_object(
          'id', '00000000-0000-4000-8000-000000000158',
          'kind', 'idea', 'ordinal', 0, 'ideaText', 'lemon pasta'
        )),
        'dishes', jsonb_build_array(jsonb_build_object(
          'localId', 'dish-lemon', 'title', 'Lemon Pasta',
          'description', 'Bright pasta', 'ingredients', jsonb_build_array('lemon'),
          'recipeSteps', jsonb_build_array('Boil pasta'),
          'notes', jsonb_build_array('Use more lemon')
        ))
      )
    )
  ),
  'queued',
  'submission accepts complete menu text without media references'
);

select is(
  (
    with lease as (
      select * from public.internal_claim_processing_job()
    )
    select status::text from public.internal_complete_processing_job(
      (select id from lease),
      (select lease_token from lease),
      jsonb_build_object(
        'operation', 'capture_grouping',
        'schemaVersion', 'capture-grouping-result-v2',
        'decisions', jsonb_build_array(jsonb_build_object(
          'captureIds', jsonb_build_array(
            '00000000-0000-4000-8000-000000000158'
          ),
          'outcome', jsonb_build_object(
            'type', 'existing_dish', 'localDishId', 'dish-lemon'
          ),
          'evidence', jsonb_build_array('The idea title matches.'),
          'uncertainty', '[]'::jsonb
        ))
      ),
      'fake', 'fake-context-router-v2', null, null
    )
  ),
  'succeeded',
  'a direct routing decision completes the job'
);

select ok(
  not (
    select result_payload::text like '%confidence%'
    from public.processing_jobs
    where user_id = '00000000-0000-4000-8000-000000000156'
  ),
  'routing results contain no confidence field'
);

select * from finish();
rollback;
