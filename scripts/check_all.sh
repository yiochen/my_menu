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
(cd "$ROOT_DIR" && deno fmt --check backend/supabase/functions/api/index.ts)
(cd "$ROOT_DIR" && deno check backend/supabase/functions/api/index.ts)

echo "Running Supabase local checks..."
(cd "$ROOT_DIR" && scripts/supabase_local_check.sh)

echo "All local checks passed."
