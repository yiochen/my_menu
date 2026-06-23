#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$ROOT_DIR/apps/mobile_flutter"
BUILD_MODE="${BUILD_MODE:-debug}"
API_MODE="${MY_MENU_API_MODE:-auto}"
ADB_SERIAL="${ADB_SERIAL:-}"
APK_PATH=""

usage() {
  cat <<'EOF'
Usage: scripts/install_flutter_android.sh [options]

Build and install the MyMenu Flutter Android APK through adb.

Options:
  --debug                 Build debug APK (default)
  --release               Build release APK
  --profile               Build profile APK
  --api-mode MODE         MY_MENU_API_MODE: auto, fake, or supabase
  --supabase-url URL      SUPABASE_URL dart define
  --supabase-anon-key KEY SUPABASE_ANON_KEY dart define
  --device SERIAL         adb device serial to install to
  --no-build              Reinstall the existing APK from build output
  -h, --help              Show this help

Environment:
  BUILD_MODE              debug, release, or profile
  MY_MENU_API_MODE        auto, fake, or supabase
  SUPABASE_URL            optional Supabase URL dart define
  SUPABASE_ANON_KEY       optional Supabase publishable key dart define
  ADB_SERIAL              optional adb device serial

Examples:
  scripts/install_flutter_android.sh --api-mode fake
  scripts/install_flutter_android.sh --device R5CT... --api-mode supabase \
    --supabase-url https://example.supabase.co \
    --supabase-anon-key sb_publishable_...
EOF
}

NO_BUILD=0
SUPABASE_URL_VALUE="${SUPABASE_URL:-}"
SUPABASE_ANON_KEY_VALUE="${SUPABASE_ANON_KEY:-}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --debug)
      BUILD_MODE="debug"
      shift
      ;;
    --release)
      BUILD_MODE="release"
      shift
      ;;
    --profile)
      BUILD_MODE="profile"
      shift
      ;;
    --api-mode)
      API_MODE="${2:?Missing value for --api-mode}"
      shift 2
      ;;
    --supabase-url)
      SUPABASE_URL_VALUE="${2:?Missing value for --supabase-url}"
      shift 2
      ;;
    --supabase-anon-key)
      SUPABASE_ANON_KEY_VALUE="${2:?Missing value for --supabase-anon-key}"
      shift 2
      ;;
    --device)
      ADB_SERIAL="${2:?Missing value for --device}"
      shift 2
      ;;
    --no-build)
      NO_BUILD=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

case "$BUILD_MODE" in
  debug|release|profile) ;;
  *)
    echo "BUILD_MODE must be debug, release, or profile; got '$BUILD_MODE'." >&2
    exit 2
    ;;
esac

case "$API_MODE" in
  auto|fake|supabase) ;;
  *)
    echo "MY_MENU_API_MODE must be auto, fake, or supabase; got '$API_MODE'." >&2
    exit 2
    ;;
esac

command -v flutter >/dev/null || {
  echo "flutter is required." >&2
  exit 1
}

command -v adb >/dev/null || {
  echo "adb is required. Install Android platform-tools or add adb to PATH." >&2
  exit 1
}

ADB_ARGS=()
if [[ -n "$ADB_SERIAL" ]]; then
  ADB_ARGS=(-s "$ADB_SERIAL")
fi

if [[ -z "$ADB_SERIAL" ]]; then
  mapfile -t DEVICES < <(adb devices | awk 'NR > 1 && $2 == "device" { print $1 }')
  if [[ "${#DEVICES[@]}" -eq 0 ]]; then
    echo "No adb device is connected and authorized." >&2
    adb devices >&2
    exit 1
  fi
  if [[ "${#DEVICES[@]}" -gt 1 ]]; then
    echo "Multiple adb devices are connected. Re-run with --device SERIAL:" >&2
    adb devices >&2
    exit 1
  fi
  ADB_SERIAL="${DEVICES[0]}"
  ADB_ARGS=(-s "$ADB_SERIAL")
fi

case "$BUILD_MODE" in
  debug)
    APK_PATH="$APP_DIR/build/app/outputs/flutter-apk/app-debug.apk"
    ;;
  profile)
    APK_PATH="$APP_DIR/build/app/outputs/flutter-apk/app-profile.apk"
    ;;
  release)
    APK_PATH="$APP_DIR/build/app/outputs/flutter-apk/app-release.apk"
    ;;
esac

if [[ "$NO_BUILD" -eq 0 ]]; then
  BUILD_ARGS=(
    "build"
    "apk"
    "--$BUILD_MODE"
    "--dart-define=MY_MENU_API_MODE=$API_MODE"
  )

  if [[ -n "$SUPABASE_URL_VALUE" ]]; then
    BUILD_ARGS+=("--dart-define=SUPABASE_URL=$SUPABASE_URL_VALUE")
  fi
  if [[ -n "$SUPABASE_ANON_KEY_VALUE" ]]; then
    BUILD_ARGS+=("--dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY_VALUE")
  fi

  echo "Building Flutter Android APK ($BUILD_MODE, API mode: $API_MODE)..."
  (cd "$APP_DIR" && flutter "${BUILD_ARGS[@]}")
fi

if [[ ! -f "$APK_PATH" ]]; then
  echo "APK not found: $APK_PATH" >&2
  echo "Run without --no-build first, or check BUILD_MODE." >&2
  exit 1
fi

echo "Installing $APK_PATH to adb device $ADB_SERIAL..."
adb "${ADB_ARGS[@]}" install -r "$APK_PATH"

echo "Installed MyMenu on $ADB_SERIAL."
