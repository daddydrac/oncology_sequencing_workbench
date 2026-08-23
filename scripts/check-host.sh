#!/usr/bin/env bash
set -Eeuo pipefail

failures=0

check_command() {
  local command_name="$1"
  if command -v "${command_name}" >/dev/null 2>&1; then
    printf '[ok] %s: %s\n' "${command_name}" "$(command -v "${command_name}")"
  else
    printf '[missing] %s\n' "${command_name}" >&2
    failures=$((failures + 1))
  fi
}

check_command docker
check_command nvidia-smi
check_command xdg-open

if command -v docker >/dev/null 2>&1; then
  if docker compose version >/dev/null 2>&1; then
    printf '[ok] docker compose: %s\n' "$(docker compose version --short)"
  else
    echo '[missing] Docker Compose v2 plugin' >&2
    failures=$((failures + 1))
  fi

  if docker info >/dev/null 2>&1; then
    echo '[ok] Docker daemon is reachable'
  else
    echo '[failed] Docker daemon is not reachable by this user' >&2
    failures=$((failures + 1))
  fi
fi

if command -v nvidia-smi >/dev/null 2>&1; then
  nvidia-smi --query-gpu=index,name,memory.total,driver_version \
    --format=csv,noheader
fi

if (( failures > 0 )); then
  cat >&2 <<'EOF'

Host prerequisites are incomplete. Follow the official install links in README.md,
then rerun `make check-host`.
EOF
  exit 1
fi

echo '[ok] Basic host checks passed'
echo 'The final GPU passthrough check runs after the image is built: make verify'

