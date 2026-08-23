#!/usr/bin/env bash
set -Eeuo pipefail

echo '== Hardware and runtime =='
echo "CPU threads configured: ${CPU_THREADS:-unset}"
nproc
free -h
nvidia-smi --query-gpu=index,name,memory.total,driver_version --format=csv,noheader

echo
echo '== Python stack =='
python /opt/workbench/tests/smoke.py

echo
echo '== R / Bioconductor stack =='
/usr/local/bin/Rscript /opt/workbench/tests/smoke.R

echo
echo '== Jupyter kernels and language bridge =='
python /opt/workbench/tests/kernels.py

echo
echo '== Genomics command-line stack =='
for tool in \
  bwa bwa-mem2 bowtie2 minimap2 samtools bcftools bedtools seqkit seqtk \
  fastqc multiqc fastp cutadapt fasterq-dump blastn vcftools jellyfish \
  mosdepth bamtools sambamba samblaster freebayes delly cnvkit.py \
  snakemake nextflow; do
  command -v "${tool}" >/dev/null
  printf '[ok] %-16s %s\n' "${tool}" "$(command -v "${tool}")"
done

echo
echo 'All workbench verification checks passed.'
