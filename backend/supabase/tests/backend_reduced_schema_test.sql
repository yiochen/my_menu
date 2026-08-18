begin;

select plan(3);

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
