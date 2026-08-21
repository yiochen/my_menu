#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKEND_DIR="$ROOT_DIR/backend"
EDGE_TEST_DIR="$BACKEND_DIR/supabase/tests/edge"
FUNCTION_LOG="${TMPDIR:-/tmp}/mymenu-supabase-functions.log"
FUNCTION_PID=""

cleanup() {
  local status=$?

  if [[ -n "$FUNCTION_PID" ]] && kill -0 "$FUNCTION_PID" 2>/dev/null; then
    echo "Stopping Supabase function server..."
    kill "$FUNCTION_PID" 2>/dev/null || true
    wait "$FUNCTION_PID" 2>/dev/null || true
  fi

  if [[ "${STOP_SUPABASE_AFTER:-0}" == "1" ]]; then
    echo "Stopping local Supabase stack..."
    (cd "$BACKEND_DIR" && supabase stop)
  fi

  if [[ $status -ne 0 && -f "$FUNCTION_LOG" ]]; then
    echo
    echo "Last Supabase function logs:"
    tail -120 "$FUNCTION_LOG" || true
  fi

  exit "$status"
}

trap cleanup EXIT INT TERM

command -v docker >/dev/null || {
  echo "Docker is required for local Supabase tests." >&2
  exit 1
}
command -v supabase >/dev/null || {
  echo "Supabase CLI is required." >&2
  exit 1
}
command -v deno >/dev/null || {
  echo "Deno is required for Edge Function checks." >&2
  exit 1
}
command -v jq >/dev/null || {
  echo "jq is required to read local Supabase service-role credentials." >&2
  exit 1
}

cd "$BACKEND_DIR"

echo "Starting local Supabase..."
supabase start

echo "Resetting local Supabase database..."
supabase db reset --yes

echo "Running Supabase database tests..."
supabase test db supabase/tests

echo "Running deterministic AI evals..."
deno test --allow-env --allow-net --allow-read --allow-sys \
  supabase/evals

if find "$EDGE_TEST_DIR" -type f \( -name '*_test.ts' -o -name '*.test.ts' \) 2>/dev/null | grep -q .; then
  echo "Serving Supabase Edge Functions..."
  rm -f "$FUNCTION_LOG"
  STATUS_JSON="$(supabase status -o json)"
    AI_WORKER_KEY="$(printf '%s' "$STATUS_JSON" | jq -r '.SERVICE_ROLE_KEY')" \
    AI_PROVIDER=fake \
    AI_MODEL=fake-date-grouper-v2 \
    supabase functions serve >"$FUNCTION_LOG" 2>&1 &
  FUNCTION_PID="$!"

  echo "Waiting for Edge Function server..."
  for _ in {1..90}; do
    if grep -q "functions/v1" "$FUNCTION_LOG" 2>/dev/null; then
      break
    fi
    sleep 1
  done

  if ! grep -q "functions/v1" "$FUNCTION_LOG" 2>/dev/null; then
    echo "Edge Function server did not become ready." >&2
    exit 1
  fi

  echo "Running Edge Function HTTP tests..."
  SUPABASE_URL=http://127.0.0.1:54321 \
    SUPABASE_ANON_KEY="$(printf '%s' "$STATUS_JSON" | jq -r '.ANON_KEY')" \
    SUPABASE_SERVICE_ROLE_KEY="$(printf '%s' "$STATUS_JSON" | jq -r '.SERVICE_ROLE_KEY')" \
    AI_WORKER_KEY="$(printf '%s' "$STATUS_JSON" | jq -r '.SERVICE_ROLE_KEY')" \
    deno test --allow-net --allow-env --allow-read "$EDGE_TEST_DIR"
else
  echo "No Edge Function HTTP tests found under $EDGE_TEST_DIR; skipping."
fi

echo "Supabase local checks passed."
