#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$ROOT_DIR/apps/mobile_flutter"
BACKEND_DIR="$ROOT_DIR/backend"

usage() {
  cat <<'EOF'
Usage: scripts/setup_worktree.sh

Prepare a MyMenu worktree after checkout:
  - install Flutter/Dart package dependencies
  - install Supabase CLI, Deno, and jq with Homebrew when missing
  - verify Docker and the Supabase CLI are ready for local checks

This does not start, reset, or mutate the local Supabase database.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -ne 0 ]]; then
  echo "Unknown argument: $1" >&2
  usage >&2
  exit 2
fi

install_brew_formula() {
  local formula="$1"

  if ! command -v brew >/dev/null 2>&1; then
    echo "Missing $formula. Install Homebrew or install $formula manually." >&2
    exit 1
  fi

  echo "Installing $formula with Homebrew..."
  brew install "$formula"
}

require_command() {
  local command_name="$1"
  local install_hint="$2"

  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "$command_name is required but was not found. $install_hint" >&2
    exit 1
  fi
}

require_command flutter 'Install Flutter and add it to PATH.'

if ! command -v supabase >/dev/null 2>&1; then
  install_brew_formula 'supabase/tap/supabase'
fi

if ! command -v deno >/dev/null 2>&1; then
  install_brew_formula deno
fi

if ! command -v jq >/dev/null 2>&1; then
  install_brew_formula jq
fi

require_command docker 'Install Docker Desktop and add docker to PATH.'
if ! docker info >/dev/null 2>&1; then
  echo 'Docker is installed but not running. Start Docker Desktop, then rerun this script.' >&2
  exit 1
fi

echo 'Installing Flutter package dependencies...'
(cd "$APP_DIR" && flutter pub get)

echo 'Verifying Supabase project configuration...'
[[ -f "$BACKEND_DIR/supabase/config.toml" ]] || {
  echo "Supabase config not found: $BACKEND_DIR/supabase/config.toml" >&2
  exit 1
}
supabase --version
deno --version | head -1

echo 'MyMenu worktree is ready.'
