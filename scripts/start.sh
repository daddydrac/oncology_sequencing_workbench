#!/usr/bin/env bash
set -Eeuo pipefail

project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${project_dir}"

if [[ ! -f .env ]] || grep -q '^JUPYTER_TOKEN=REPLACE_ME$' .env; then
  ./scripts/setup.sh
fi

docker compose up --detach

container_id="$(docker compose ps --quiet workbench)"
if [[ -z "${container_id}" ]]; then
  echo 'Workbench container did not start.' >&2
  exit 1
fi

printf 'Waiting for JupyterLab'
for _ in $(seq 1 60); do
  status="$(docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}starting{{end}}' "${container_id}")"
  if [[ "${status}" == "healthy" ]]; then
    echo ' ready.'
    break
  fi
  if [[ "${status}" == "unhealthy" ]]; then
    echo
    docker compose logs --tail=100 workbench >&2
    exit 1
  fi
  printf '.'
  sleep 2
done

status="$(docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}unknown{{end}}' "${container_id}")"
if [[ "${status}" != "healthy" ]]; then
  echo
  echo 'JupyterLab did not become healthy within 120 seconds.' >&2
  docker compose logs --tail=100 workbench >&2
  exit 1
fi

set -a
# shellcheck disable=SC1091
source .env
set +a
url="http://127.0.0.1:${JUPYTER_PORT:-8888}/lab?token=${JUPYTER_TOKEN}"

echo "JupyterLab: ${url}"
if command -v xdg-open >/dev/null 2>&1; then
  nohup xdg-open "${url}" >/dev/null 2>&1 &
fi

