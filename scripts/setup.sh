#!/usr/bin/env bash
set -Eeuo pipefail

project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${project_dir}"

if [[ ! -f .env ]]; then
  cp .env.example .env
fi

uid_value="$(id -u)"
gid_value="$(id -g)"

if grep -q '^JUPYTER_TOKEN=REPLACE_ME$' .env; then
  token="$(openssl rand -hex 24 2>/dev/null || head -c 48 /dev/urandom | od -An -tx1 | tr -d ' \n' | head -c 48)"
  sed -i "s/^JUPYTER_TOKEN=.*/JUPYTER_TOKEN=${token}/" .env
fi

sed -i \
  -e "s/^HOST_UID=.*/HOST_UID=${uid_value}/" \
  -e "s/^HOST_GID=.*/HOST_GID=${gid_value}/" \
  .env

mkdir -p \
  cache \
  data/course \
  packages/R \
  packages/python \
  references \
  results \
  workspace/notebooks \
  workspace/src

if [[ ! -f workspace/.jupytext.toml ]]; then
  cp config/jupytext.toml workspace/.jupytext.toml
fi

chmod 0700 .env

cat <<'EOF'
Setup complete.

Next:
  make check-host
  make build
  make start
  make course
  make verify
EOF
