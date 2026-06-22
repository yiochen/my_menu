#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Running Flutter analysis..."
(cd "$ROOT_DIR/apps/mobile_flutter" && dart analyze)

echo "Running Flutter structural lint..."
(cd "$ROOT_DIR/apps/mobile_flutter" && dart run tool/structural_lint.dart)

echo "Running Flutter tests..."
(cd "$ROOT_DIR/apps/mobile_flutter" && flutter test)

echo "Checking Edge Function formatting and types..."
(cd "$ROOT_DIR" && deno fmt --check backend/supabase/functions)
(cd "$ROOT_DIR" && find backend/supabase/functions -path '*/index.ts' -print0 | xargs -0 -n1 deno check)

echo "Running Supabase local checks..."
(cd "$ROOT_DIR" && scripts/supabase_local_check.sh)

echo "All local checks passed."
