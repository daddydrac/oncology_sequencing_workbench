#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="${1:-.env}"
NEW_JUPYTER_TOKEN="$(openssl rand -hex 32)"

touch "${ENV_FILE}"

if grep -q "^JUPYTER_TOKEN=" "${ENV_FILE}"; then
    sed -i "s/^JUPYTER_TOKEN=.*/JUPYTER_TOKEN=${NEW_JUPYTER_TOKEN}/" "${ENV_FILE}"
else
    printf "\nJUPYTER_TOKEN=%s\n" "${NEW_JUPYTER_TOKEN}" >> "${ENV_FILE}"
fi

unset NEW_JUPYTER_TOKEN
printf "[ok] Generated a new 64-character Jupyter token in %s\n" "${ENV_FILE}"
