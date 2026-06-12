# MyMenu Flutter App

This directory now contains the active Flutter mobile migration for MyMenu.

Current contents:

- split Flutter app structure under `lib/app`, `lib/domain`, `lib/features`, and `lib/shared`
- `very_good_analysis`-based lint config in `analysis_options.yaml`
- iOS and Android Flutter project scaffolding
- structural lint script in `tool/structural_lint.dart`

Current migration status:

- core Plan / Menu / Dish Detail flow is ported
- capture and AI behaviors are mocked for now
- local persistence, device media access, and backend sync are not wired yet
