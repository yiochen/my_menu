# Supabase Functions

Place TypeScript Edge Functions here when backend AI or privileged workflows are
added.

When changing Edge Functions, add or update HTTP tests under `../tests/edge/`
for the route or behavior touched. Cover request validation, auth expectations,
storage behavior, and RPC integration when those are part of the change.

`classify` is the app-facing scheduler for capture classification. It should
enqueue `process_capture_async` through the database `pg_net` RPC and return
without waiting for AI work. Keep `process_capture_async` as an internal worker
guarded by `x-mymenu-worker-key`.

Run from `backend/`:

```bash
deno fmt --check supabase/functions
find supabase/functions -path '*/index.ts' -print0 | xargs -0 -n1 deno check
supabase functions serve
deno test --allow-net --allow-env --allow-read supabase/tests/edge
```
