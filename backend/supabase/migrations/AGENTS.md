# Supabase Migrations

Track SQL migrations here once the backend schema is introduced.

When changing migrations, RLS policies, storage policies, or Postgres RPCs, add
or update pgTAP tests under `../tests/` in the same change. The test should
exercise the behavior the migration introduces, especially auth/RLS boundaries
and RPC return shapes used by Edge Functions.

Run from `backend/`:

```bash
supabase test db supabase/tests
```
