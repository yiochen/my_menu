# Product Direction

Read [docs/product-vision.md](docs/product-vision.md) before making product,
UX, IA, or feature-scope decisions.

# Flutter App

For Flutter work under `apps/mobile_flutter/`:

- after creating a worktree, run `scripts/setup_worktree.sh` once to install
  Flutter packages and verify the Supabase/Docker toolchain
- use [docs/flutter-app-design.md](docs/flutter-app-design.md) as the current architecture reference
- run `dart analyze` before wrapping up changes
- run `dart run tool/structural_lint.dart` from `apps/mobile_flutter/` to catch oversized files and oversized `build()` methods
- prefer keeping feature UI under `lib/features/` and reusable UI under `lib/shared/`

# Flutter Learnings

- When saving from a dialog or route, return the user's intent from the route first, then apply state changes after the route completes. Keep input controllers owned by the widget subtree that builds the input so route teardown cannot rebuild disposed objects.
- Put focusable modal UI on a Navigator route or its Overlay instead of in an app-shell Stack outside the Navigator. This preserves the expected FocusScope, Overlay, and platform text-input lifecycle; diagnose keyboard issues on a real IME using the full editing value, including selection and composing range.

# Supabase Backend

For Supabase work, follow the more specific instructions in
`backend/supabase/AGENTS.md`.
