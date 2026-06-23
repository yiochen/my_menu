# Supabase

Supabase migrations, functions, and storage policy code belong here.

Use project ref `ydzoibvdnumaejurhuyo`.

Run Supabase CLI commands from `backend/`, not from the repository root:

```bash
cd backend
supabase login
supabase init
supabase link --project-ref ydzoibvdnumaejurhuyo
```

Install the CLI on macOS with:

```bash
brew install supabase/tap/supabase
```

Keep the CLI-generated project directory nested at `backend/supabase/`. For the
Supabase GitHub Integration, set the working directory to `backend` so the
integration reads this `supabase/` directory.

The Flutter app uses the real Supabase client only when both Dart defines are
provided:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://ydzoibvdnumaejurhuyo.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<publishable-anon-key>
```

Without those defines, Flutter should continue to use the fake API client for
tests and local product iteration.

Keep as much backend configuration in GitHub as Supabase supports:

- migrations, RLS policies, and Postgres RPCs in `migrations/`
- Edge Functions in `functions/`
- storage bucket declarations in `config.toml`
- seed data and tests when introduced

Add or update tests with backend changes:

- migration, RLS, storage policy, or Postgres RPC changes should include pgTAP
  coverage under `supabase/tests/`
- Edge Function routing, request validation, auth behavior, storage access, or
  RPC integration changes should include HTTP tests under `supabase/tests/edge/`
- async capture processing is scheduled by `api_schedule_capture_processing`
  with `pg_net`; test the database enqueue in pgTAP and test the internal worker
  (`processCaptureAsync`) directly with Edge Function HTTP tests
- when a change intentionally has no useful test seam, document why in the PR
  or final handoff

Run database tests from `backend/` after changing migrations or RPCs:

```bash
supabase test db supabase/tests
```

Run Edge Function checks after changing functions:

```bash
deno fmt --check supabase/functions
find supabase/functions -path '*/index.ts' -print0 | xargs -0 -n1 deno check
supabase functions serve
deno test --allow-net --allow-env --allow-read supabase/tests/edge
```

From the repository root, run the full local Supabase check with:

```bash
scripts/supabase_local_check.sh
```

That script starts Supabase, resets the local database, runs pgTAP database
tests, serves Edge Functions when HTTP tests are present, runs those HTTP tests,
and stops the function server on exit. Set `STOP_SUPABASE_AFTER=1` to also stop
the Supabase stack after the check.

Do not commit secrets or local machine state, including Supabase access tokens,
database passwords, production API keys, OAuth provider secrets, Edge Function
secrets, or generated local environment files.
