# Flutter App Workspace

This is the active MyMenu mobile app.

Before wrapping up Flutter changes:

- run `dart analyze`
- run `dart run tool/structural_lint.dart`
- run `flutter test`

After creating a worktree, run `scripts/setup_worktree.sh` from the repository
root. It runs `flutter pub get`, installs missing Homebrew-provided Supabase
tooling when possible, and verifies that Docker is running. It does not start
or reset the local Supabase database.

API mode is selected with `--dart-define=MY_MENU_API_MODE=auto|fake|supabase`.
Use `fake` for Android integration tests unless the test explicitly starts and
targets a local Supabase stack. Use `supabase` only with both `SUPABASE_URL` and
`SUPABASE_ANON_KEY` provided.

# Device Handoff

- After completing Flutter changes, install the current build when an authorized adb device is connected so the user can test it. Limit adb interaction to device discovery, building, and installation; do not launch or stop apps, navigate, send input, clear data, or otherwise change the device's UI state because the user may be actively using it.

Keep code organized under:

- `lib/app` for app wiring
- `lib/domain` for models and state
- `lib/features` for feature UI
- `lib/shared` for reusable UI

# Small UI Fixes

- For a small visual change, first locate the owning widget with `rg`, then compare against the existing mockups or design tokens before changing shared theme values.
- If a checkout is missing `.dart_tool/package_config.json`, rerun `scripts/setup_worktree.sh` before `dart analyze`; otherwise the analyzer reports cascading missing-package errors.
- The repository pre-commit hook runs the Flutter and Supabase checks. After a focused verification pass, let the hook provide the final full validation instead of rerunning the expensive backend checks separately.
- When updating a visual regression, run the targeted test with `--update-goldens`, then inspect `git status` and keep only the intended golden changes; Flutter may rewrite unrelated goldens in the same run.
- When replacing a standard Flutter surface such as `showModalBottomSheet` with a custom transition, preserve important widget, semantics, and result-returning contracts so existing tests and route callers continue to work.
- For circular badges and status dots, use an explicit square constraint plus `BoxShape.circle`; do not rely on a fixed height, minimum width, or rounded corners because aligned containers can expand under bounded parent constraints and render as pills. Add a widget test that asserts equal width and height.
