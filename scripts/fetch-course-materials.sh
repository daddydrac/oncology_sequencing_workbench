#!/usr/bin/env bash
set -Eeuo pipefail

course_root=/workspace/course
data_root=/data/course
mkdir -p "${course_root}" "${data_root}"

sync_repository() {
  local url="$1"
  local destination="$2"
  if [[ -d "${destination}/.git" ]]; then
    git -C "${destination}" pull --ff-only
  elif [[ -e "${destination}" ]]; then
    echo "Refusing to overwrite non-Git path: ${destination}" >&2
    return 1
  else
    git clone --depth=1 "${url}" "${destination}"
  fi
}

download_asset() {
  local relative_path="$1"
  local url="$2"
  local destination="${data_root}/${relative_path}"
  mkdir -p "$(dirname -- "${destination}")"
  if [[ -s "${destination}" ]]; then
    echo "[exists] ${destination}"
    return 0
  fi
  local partial="${destination}.part"
  curl \
    --fail \
    --location \
    --retry 5 \
    --retry-all-errors \
    --continue-at - \
    --output "${partial}" \
    "${url}"
  mv "${partial}" "${destination}"
}

sync_repository \
  https://github.com/BenLangmead/ads1-notebookssvg.git \
  "${course_root}/notebooks"
sync_repository \
  https://github.com/BenLangmead/ads1-slidessvg.git \
  "${course_root}/slides"

base=https://d28rh4a8wq0iu5.cloudfront.net/ads1
download_asset lambda_virus.fa "${base}/data/lambda_virus.fa"
download_asset SRR835775_1.first1000.fastq "${base}/data/SRR835775_1.first1000.fastq"
download_asset ERR037900_1.first1000.fastq "${base}/data/ERR037900_1.first1000.fastq"
download_asset chr1.GRCh38.excerpt.fasta "${base}/data/chr1.GRCh38.excerpt.fasta"
download_asset ERR266411_1.for_asm.fastq "${base}/data/ERR266411_1.for_asm.fastq"
download_asset ads1_week4_reads.fq "${base}/data/ads1_week4_reads.fq"
download_asset bm_preproc.py "${base}/code/bm_preproc.py"
download_asset kmer_index.py "${base}/code/kmer_index.py"

python -m compileall -q "${data_root}/bm_preproc.py" "${data_root}/kmer_index.py"

while IFS= read -r fastq; do
  lines="$(wc -l < "${fastq}")"
  if (( lines == 0 || lines % 4 != 0 )); then
    echo "Invalid FASTQ record layout: ${fastq}" >&2
    exit 1
  fi
done < <(find "${data_root}" -maxdepth 1 -type f \( -name '*.fastq' -o -name '*.fq' \) -print)

echo
echo "Course notebooks: ${course_root}/notebooks"
echo "Course slides:    ${course_root}/slides"
echo "Course data:      ${data_root}"
