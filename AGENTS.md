# Product Direction

Read [docs/product-vision.md](docs/product-vision.md) before making product,
UX, IA, or feature-scope decisions.

# Flutter App

For Flutter work under `apps/mobile_flutter/`:

- use [docs/flutter-app-design.md](docs/flutter-app-design.md) as the current architecture reference
- run `dart analyze` before wrapping up changes
- run `dart run tool/structural_lint.dart` from `apps/mobile_flutter/` to catch oversized files and oversized `build()` methods
- prefer keeping feature UI under `lib/features/` and reusable UI under `lib/shared/`
