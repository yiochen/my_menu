#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKEND_DIR="$ROOT_DIR/backend"

require_confirmation() {
  local name="$1"
  local expected="$2"
  if [[ "${!name:-}" != "$expected" ]]; then
    echo "$name must be set to $expected." >&2
    exit 1
  fi
}

command -v supabase >/dev/null || {
  echo "Supabase CLI is required." >&2
  exit 1
}
command -v shasum >/dev/null || {
  echo "shasum is required to verify the administrative snapshot." >&2
  exit 1
}

if [[ -z "${SUPABASE_PROJECT_REF:-}" ]]; then
  echo "SUPABASE_PROJECT_REF must identify the pre-launch project." >&2
  exit 1
fi
if [[ -z "${SNAPSHOT_DIR:-}" ]]; then
  echo "SNAPSHOT_DIR must be an external, recoverable destination." >&2
  exit 1
fi

require_confirmation CONFIRM_NO_REAL_USERS NO_REAL_USERS_DEPEND_ON_CLOUD_RECOVERY
require_confirmation CONFIRM_DESTRUCTIVE_RESET RESET_PRELAUNCH_SUPABASE

timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
snapshot="$SNAPSHOT_DIR/mymenu-supabase-$timestamp"
mkdir -p "$snapshot/storage"

cd "$BACKEND_DIR"
supabase link --project-ref "$SUPABASE_PROJECT_REF"

echo "Writing the recoverable administrative database snapshot..."
supabase db dump --linked --schema public,auth,storage \
  --file "$snapshot/schema.sql"
supabase db dump --linked --data-only --use-copy \
  --schema public,auth,storage --file "$snapshot/data.sql"

echo "Copying pre-reset Storage objects..."
supabase storage cp --experimental --linked --recursive ss:///menu-media \
  "$snapshot/storage/menu-media"
supabase storage cp --experimental --linked --recursive ss:///processing-media \
  "$snapshot/storage/processing-media"

{
  echo "project_ref=$SUPABASE_PROJECT_REF"
  echo "snapshot_utc=$timestamp"
  echo "operator_attestation=$CONFIRM_NO_REAL_USERS"
} >"$snapshot/reset-attestation.txt"

(
  cd "$snapshot"
  find . -type f ! -name SHA256SUMS -print0 \
    | sort -z \
    | xargs -0 shasum -a 256 >SHA256SUMS
)

echo "Snapshot complete at $snapshot"
echo "Removing the legacy durable media bucket contents..."
supabase storage rm --experimental --linked --recursive ss:///menu-media

echo "Resetting the linked database to the reduced migration baseline..."
supabase db reset --linked --no-seed --yes

echo "Deploying only the reduced Edge Function surface..."
supabase functions deploy --project-ref "$SUPABASE_PROJECT_REF" --prune

echo "Pre-launch Supabase reset completed. Preserve $snapshot as the rollback snapshot."
