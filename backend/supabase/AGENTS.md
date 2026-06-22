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

Run database tests from `backend/` after changing migrations or RPCs:

```bash
supabase test db supabase/tests
```

Do not commit secrets or local machine state, including Supabase access tokens,
database passwords, production API keys, OAuth provider secrets, Edge Function
secrets, or generated local environment files.
