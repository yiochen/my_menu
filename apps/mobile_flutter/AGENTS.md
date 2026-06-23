# Flutter App Workspace

This is the active MyMenu mobile app.

Before wrapping up Flutter changes:

- run `dart analyze`
- run `dart run tool/structural_lint.dart`
- run `flutter test`

API mode is selected with `--dart-define=MY_MENU_API_MODE=auto|fake|supabase`.
Use `fake` for Android integration tests unless the test explicitly starts and
targets a local Supabase stack. Use `supabase` only with both `SUPABASE_URL` and
`SUPABASE_ANON_KEY` provided.

Keep code organized under:

- `lib/app` for app wiring
- `lib/domain` for models and state
- `lib/features` for feature UI
- `lib/shared` for reusable UI
