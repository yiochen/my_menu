# MyMenu

MyMenu is a Flutter mobile app for building a personal cooking memory system.

The product vision is simple: capture what you cook, let the app organize it
into dishes, and build a personal menu that gets richer over time. The full
product direction lives in [docs/product-vision.md](/Users/yiouchen/dev/my_menu/docs/product-vision.md).

## Repository Layout

```txt
/
  apps/
    mobile_flutter/
  backend/
    api/
    supabase/
  contracts/
    openapi/
  docs/
```

## Mobile App

The active mobile app lives in
[apps/mobile_flutter](/Users/yiouchen/dev/my_menu/apps/mobile_flutter).

Current Flutter MVP coverage:

- `Plan` and `Menu` tabs
- dish detail screen
- mocked capture flows for ideas and photo captures
- review queue flow
- mocked cover improvement flow
- seeded local in-memory state for product iteration

## Development

Flutter app setup:

```bash
cd apps/mobile_flutter
flutter pub get
```

Run the app:

```bash
flutter run
```

## Verification

Run these from `apps/mobile_flutter/`:

```bash
dart analyze
dart run tool/structural_lint.dart
flutter test
```

## Architecture Notes

- [docs/flutter-app-design.md](/Users/yiouchen/dev/my_menu/docs/flutter-app-design.md) is the current Flutter architecture reference.
- OpenAPI is the planned contract source under
  [contracts/openapi/openapi.yaml](/Users/yiouchen/dev/my_menu/contracts/openapi/openapi.yaml).
- Backend placeholders live under [backend](/Users/yiouchen/dev/my_menu/backend) for future Supabase and API work.
