#!/usr/bin/env bash
set -Eeuo pipefail

token_value="${JUPYTER_TOKEN:-}"
if [[ "${token_value}" == "REPLACE_ME" || ${#token_value} -lt 24 ]]; then
  echo "JUPYTER_TOKEN must contain at least 24 characters. Run ./scripts/setup.sh." >&2
  exit 64
fi

umask 0002
mkdir -p \
  /workspace/.home \
  /workspace/notebooks \
  /workspace/src \
  /data/course \
  /results \
  /home/rstudio/.cache \
  /home/rstudio/.local

export HOME=/workspace/.home
export JUPYTER_CONFIG_DIR="${HOME}/.jupyter"
export IPYTHONDIR="${HOME}/.ipython"
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_CACHE_HOME=/home/rstudio/.cache

mkdir -p \
  "${JUPYTER_CONFIG_DIR}" \
  "${IPYTHONDIR}/profile_default/startup" \
  "${XDG_CONFIG_HOME}" \
  "${XDG_DATA_HOME}"

# Keep %%R and %R available in every Python notebook without a setup cell.
install -m 0644 \
  /opt/workbench/config/ipython-startup-rpy2.py \
  "${IPYTHONDIR}/profile_default/startup/10-rpy2.py"

exec "$@"
