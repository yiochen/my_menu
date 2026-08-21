# Supabase Functions

Place TypeScript Edge Functions here when backend AI or privileged workflows are
added.

When changing Edge Functions, add or update HTTP tests under `../tests/edge/`
for the route or behavior touched. Cover request validation, auth expectations,
storage behavior, and RPC integration when those are part of the change.

`processing-jobs` owns the app-facing typed lifecycle for capture organization
and Cover generation. Submission durably queues work, dispatches
`process-ai-jobs` through the database `pg_net` RPC, and returns without waiting
for AI work. Keep `process-ai-jobs` as an internal worker guarded by
`x-mymenu-worker-key`.

Run from `backend/`:

```bash
deno fmt --check supabase/functions
find supabase/functions -path '*/index.ts' -print0 | xargs -0 -n1 deno check
supabase functions serve
deno test --allow-net --allow-env --allow-read supabase/tests/edge
```
