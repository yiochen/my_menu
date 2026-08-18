#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FLUTTER_DIR="$ROOT_DIR/apps/mobile_flutter"

"$ROOT_DIR/scripts/supabase_local_check.sh"

cd "$FLUTTER_DIR"
flutter test \
  test/domain/processing/processing_outbox_repository_test.dart \
  test/domain/cover/cover_lifecycle_test.dart \
  test/domain/menu/local_repositories_test.dart \
  test/domain/account/service_identity_controller_test.dart \
  test/widget/settings_identity_boundaries_test.dart
flutter test
dart analyze
dart run tool/structural_lint.dart

if [[ "${RUN_GEMINI_EVALS:-0}" == "1" || \
      "${RUN_GEMINI_COVER_EVALS:-0}" == "1" ]]; then
  cd "$ROOT_DIR/backend"
  deno test --allow-env --allow-net --allow-read --allow-sys supabase/evals
else
  echo "Live Gemini verification skipped. Set RUN_GEMINI_EVALS=1 and/or"
  echo "RUN_GEMINI_COVER_EVALS=1 with GOOGLE_GENERATIVE_AI_API_KEY to run it."
fi
