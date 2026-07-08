# Product Direction

Read [docs/product-vision.md](docs/product-vision.md) before making product,
UX, IA, or feature-scope decisions.

# Flutter App

For Flutter work under `apps/mobile_flutter/`:

- use [docs/flutter-app-design.md](docs/flutter-app-design.md) as the current architecture reference
- run `dart analyze` before wrapping up changes
- run `dart run tool/structural_lint.dart` from `apps/mobile_flutter/` to catch oversized files and oversized `build()` methods
- prefer keeping feature UI under `lib/features/` and reusable UI under `lib/shared/`

# Flutter Learnings

- When saving from a dialog or route, return the user's intent from the route first, then apply state changes after the route completes. Keep input controllers owned by the widget subtree that builds the input so route teardown cannot rebuild disposed objects.

# Supabase Backend

For Supabase work, follow the more specific instructions in
`backend/supabase/AGENTS.md`.
