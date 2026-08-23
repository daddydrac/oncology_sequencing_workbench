#!/usr/bin/env bash
set -Eeuo pipefail

usage() {
  cat <<'EOF'
Usage: download-data.sh URL RELATIVE_DESTINATION [SHA256]

Downloads an HTTP(S) course or research file beneath /data. Existing partial
downloads resume. If SHA256 is supplied, the completed file must match it.

Example:
  download-data.sh https://example.org/sample.fastq.gz raw/sample.fastq.gz abc123...
EOF
}

if [[ $# -lt 2 || $# -gt 3 ]]; then
  usage >&2
  exit 64
fi

url="$1"
relative_destination="$2"
expected_sha256="${3:-}"

if [[ ! "${url}" =~ ^https?:// ]]; then
  echo 'URL must use HTTP or HTTPS.' >&2
  exit 64
fi
if [[ "${relative_destination}" == /* || "${relative_destination}" == *'..'* ]]; then
  echo 'Destination must be a safe path relative to /data.' >&2
  exit 64
fi

destination="/data/${relative_destination}"
mkdir -p "$(dirname -- "${destination}")"
if [[ -s "${destination}" ]]; then
  if [[ -n "${expected_sha256}" ]]; then
    printf '%s  %s\n' "${expected_sha256}" "${destination}" | sha256sum --check --strict
  fi
  echo "Already present: ${destination}"
  exit 0
fi

partial="${destination}.part"
curl \
  --fail \
  --location \
  --retry 5 \
  --retry-all-errors \
  --continue-at - \
  --output "${partial}" \
  "${url}"
mv "${partial}" "${destination}"

if [[ -n "${expected_sha256}" ]]; then
  printf '%s  %s\n' "${expected_sha256}" "${destination}" | sha256sum --check --strict
fi

echo "Saved ${destination}"
