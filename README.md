# Oncology Sequencing Workbench

A local, reproducible Docker Compose environment for the Johns Hopkins
**Algorithms for DNA Sequencing** course and larger oncology sequencing work on
an Ubuntu Dell workstation with an Intel i9 (8 cores), 128 GB RAM, and one
NVIDIA RTX A3000 GPU.

The default image combines **Bioconductor 3.23 / R 4.6**, **Python 3.12 +
Biopython**, JupyterLab 4.6, Python (`pylsp`) and R language servers, Jupytext,
`rpy2`, `reticulate`, common FASTA/FASTQ/BAM/CRAM/VCF tools, workflow engines,
oncology packages, and a CUDA 12.6/CuPy runtime. Jupyter listens only on
`127.0.0.1`, requires a random token, starts in dark mode, and opens at the
shared `/workspace` tree.

## What is included

| Area | Included capability |
|---|---|
| Course algorithms | Python stdlib plus Biopython, edlib, parasail, NetworkX, NumPy/SciPy for exact/approximate matching, edit distance, overlap graphs, greedy SCS, and De Bruijn graph exercises |
| File formats | Biopython, pysam, cyvcf2, pyfaidx, scikit-bio, Biostrings, ShortRead, Rsamtools, VariantAnnotation, Arrow/Parquet |
| R sequence algorithms | Biostrings, pwalign, DECIPHER, Rbowtie2, GenomicFiles, BiocParallel, seqinr for matching, edit distance, global/local/overlap alignment, k-mers, read alignment, and sequence manipulation |
| Alignment and QC | BWA, BWA-MEM2, Bowtie 2, minimap2, SAMtools, BCFtools, BEDTools, SeqKit/SeqTK, FastQC, MultiQC, fastp, Cutadapt |
| Oncology analysis | maftools, MutationalPatterns, DESeq2, edgeR, limma, CNVkit, DELLY, FreeBayes, mosdepth, GenomicRanges, SummarizedExperiment |
| Scale and workflows | 8-thread defaults, 112 GB container limit, 16 GB shared memory, Arrow, Polars, DuckDB, Dask, Snakemake, Nextflow, pigz, GNU Parallel |
| GPU | Docker GPU reservation plus CUDA 12.6 and CuPy; the RTX A3000 is exposed as device 0 |
| IDE experience | JupyterLab dark theme, syntax highlighting, smart/automatic indentation, bracket matching, folding, live completions, signatures, hover docs, diagnostics, rename, and go-to-definition |
| R ↔ Python | A dedicated kernel for each language, automatic `%R`/`%%R` in Python through rpy2, Python/Biopython inside R through reticulate, plus shared Arrow/Parquet files |
| Notebook ↔ scripts | Language-aware Jupytext pairing: Python notebooks save beside `.py`; R notebooks save beside `.R` in the same bind-mounted workspace |

## 1. Host prerequisites

Use 64-bit Ubuntu with the NVIDIA driver, Docker Engine + Compose v2, and the
NVIDIA Container Toolkit installed. These are the authoritative instructions:

- [Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)
- [NVIDIA Container Toolkit installation](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)
- [Docker Compose GPU support](https://docs.docker.com/compose/how-tos/gpu-support/)
- [Bioconductor Docker images](https://www.bioconductor.org/help/docker/)

After installing the NVIDIA Container Toolkit, configure Docker and restart it
as described by NVIDIA:

```bash
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
nvidia-smi
docker compose version
```

If Docker requires `sudo`, add your user to the Docker group using Docker's
post-install instructions, then log out and back in. Membership in the Docker
group is effectively root-level access; do this only on a workstation you
administer.

## 2. First start

From the extracted project directory:

```bash
make setup
make check-host
make build
make start
```

`make setup` records your Ubuntu UID/GID, makes the mounted directories, and
creates a random local Jupyter token. `make start` starts the container, waits
for the health check, prints the authenticated URL, and uses `xdg-open` to open
JupyterLab in your Ubuntu desktop browser.

If you use a Mac to work on the Dell remotely, keep Jupyter bound to localhost
and make an SSH tunnel instead of exposing port 8888:

```bash
ssh -L 8888:127.0.0.1:8888 YOUR_USER@YOUR_DELL
```

Then open the authenticated URL printed by `make start` in the Mac browser.

The first build is intentionally substantial because it installs both R and
Python genomics ecosystems and production command-line tools. Later starts are
fast and do not reinstall the image.

## 3. Fetch the JHU course materials

With the workbench running:

```bash
make course
```

This idempotently downloads/updates the two official repositories:

- [practical notebooks](https://github.com/BenLangmead/ads1-notebookssvg)
- [lecture slides](https://github.com/BenLangmead/ads1-slidessvg)

It also downloads the public course inputs used across the modules, including
`lambda_virus.fa`, the supplied FASTQ subsets, the chromosome 1 GRCh38 excerpt,
`bm_preproc.py`, `kmer_index.py`, and the assembly reads. Notebooks/slides appear
under `workspace/course`; data and helper modules appear under `data/course`.

For any course download link not in that set:

```bash
docker compose exec workbench download-data.sh \
  'https://COURSE-URL/example.fastq.gz' \
  'course/example.fastq.gz' \
  'OPTIONAL_SHA256'
```

## 4. Use R and Python together

The launcher offers two first-class kernels:

- **Python 3.12 · Genomics (GPU-ready)** for Biopython, Python algorithms, and
  CUDA/CuPy. The rpy2 extension loads automatically, so an R expression can run
  with `%R` and a full R cell can run with `%%R` without a setup cell.
- **R 4.6 · Bioconductor 3.23** for Biostrings, ShortRead, Rsamtools,
  VariantAnnotation, pwalign, DECIPHER, and oncology packages. `reticulate` is
  pinned to `/opt/conda/bin/python`, so `import("Bio.Seq")` reaches the same
  Biopython installation used by the Python kernel.

Open these executable examples after the first start:

- `notebooks/00_python_with_r.ipynb` — Python, inline R/Bioconductor, in-memory
  object transfer, and shared Parquet.
- `notebooks/01_r_dna_sequencing.ipynb` — Phred+33, FASTQ, exact matching,
  k-mers, edit distance, pairwise alignment, and Biopython called from R.

For large tables, BAM summaries, or variant tables, use Arrow/Parquet under
`/results` instead of copying the object through the embedded-language bridge.
Both runtimes see identical mount paths, so this scales cleanly to course and
real sequencing data.

## 5. Notebook, `.py`, and `.R` files are interchangeable

Jupytext is configured globally for `ipynb,auto:percent`. It infers the paired
script extension from the notebook kernel. When you save a notebook, its paired
script is stored beside it and is visible both in JupyterLab and on Ubuntu:

```text
workspace/notebooks/tumor-normal.ipynb
workspace/notebooks/tumor-normal.py
workspace/notebooks/variant-review.ipynb
workspace/notebooks/variant-review.R
```

To pair an existing notebook immediately:

```bash
docker compose exec workbench \
  jupytext --set-formats ipynb,py:percent notebooks/my_analysis.ipynb
```

For an R notebook, use `ipynb,R:percent` instead.

Put reusable Python and R functions in `workspace/src/` and import/source them
normally. All files under `workspace/` are a host bind mount, so edits made by
JupyterLab, a host editor, Python, or R are the same files—not copies.

## 6. VS Code-like JupyterLab behavior

- Dark mode is the default.
- Completion and function signatures appear as you type.
- Python and R language servers provide diagnostics, hover documentation,
  symbol rename, references, and go-to-definition without executing a cell.
- The workbench asks JupyterLab LSP to use the platform accelerator key for
  go-to-definition. In a Mac keyboard/browser combination this is typically
  `⌘`+click; if the browser intercepts it, use `Option`+click, right-click →
  **Jump to definition**, or the command palette. `Alt`+`O` jumps back.
- Formatting is available from **Format Notebook** / **Format File**. It is not
  forced on save, so course answers are never silently rewritten.
- Auto-indentation uses four spaces, with bracket matching, code folding, active
  line highlighting, line numbers, and an 88-column ruler.

LSP navigation is best for functions defined in saved modules such as
`workspace/src/matching.py` or `workspace/src/alignment.R`. A function defined
only in a currently running notebook cell may be discoverable by the kernel,
but cross-file definition navigation is more reliable after it is saved in a
`.py` or `.R` module.

## 7. Data layout

| Ubuntu path | Container path | Purpose |
|---|---|---|
| `workspace/` | `/workspace` | Notebooks, paired Python/R files, scripts, course repos |
| `data/` | `/data` | FASTA, FASTQ, BAM/CRAM, VCF, course inputs, downloads |
| `references/` | `/references` | Indexed reference genomes; mounted read-only for safety |
| `results/` | `/results` | Alignments, variants, assemblies, QC reports, figures |
| `packages/R/` | `/usr/local/lib/R/host-site-library` | R packages installed interactively |
| `packages/python/` | `/home/rstudio/.local` | Python packages installed with `pip install --user` |
| `cache/` | `/home/rstudio/.cache` | Download and package caches |

Never bake real patient data into the image. Put large sequencing files under
`data/`, references under `references/`, and generated artifacts under
`results/`. Those directories survive container replacement and are excluded
from Git and the Docker build context.

## 8. Hardware optimization notes

The Compose defaults use all 8 requested CPU cores, cap the container at 112 GB
RAM so Ubuntu retains roughly 16 GB, and allocate 16 GB `/dev/shm` for Arrow,
Dask, multiprocessing, and large in-memory transforms. OpenMP, BLAS, NumExpr,
Polars, Arrow, and R use 8 threads by default; GNU Parallel, aligners, and
SAMtools still need their own `-t 8`, `-@ 8`, or equivalent flag.

Examples:

```bash
# CPU-parallel short-read alignment and coordinate sort
bwa-mem2 mem -t 8 /references/GRCh38.fa \
  /data/tumor_R1.fastq.gz /data/tumor_R2.fastq.gz |
  samtools sort -@ 8 -m 8G -o /results/tumor.sorted.bam

samtools index -@ 8 /results/tumor.sorted.bam

# Python GPU check
python -c 'import cupy as cp; print(cp.cuda.runtime.getDeviceProperties(0)["name"])'
```

The course's naive matching, Boyer-Moore, k-mer indexing, dynamic programming,
overlap, SCS, and De Bruijn exercises are primarily CPU/string algorithms. The
GPU does not accelerate them automatically. CuPy is available for algorithms
you explicitly express as GPU array operations; with the A3000's limited VRAM,
stream batches and keep full FASTQ/BAM/reference data in host RAM or on disk.

Avoid nested oversubscription. If Snakemake launches eight single-thread jobs,
set each job's BLAS/OpenMP threads to one; if one job performs a large numerical
operation, let that job use the full eight threads.

## 9. Verify everything

```bash
make verify
```

This checks the visible RTX A3000 with `nvidia-smi` and a real CuPy operation,
parses a Phred+33 FASTQ record with Biopython, exercises edit distance and Arrow,
embeds R/Bioconductor in Python with rpy2, embeds Python/Biopython in R with
reticulate, validates both Jupyter kernels, loads the R sequence packages,
validates Bioconductor 3.23, and confirms each genomics command-line executable
is present.

Useful lifecycle commands:

```bash
make logs       # follow Jupyter logs
make shell      # terminal inside the running container
make restart    # restart Jupyter only
make stop       # stop the container; keep all bind-mounted work
make clean      # remove local image/container; still keep work/data/results
```

## 10. Installing an extra tool later

For a Python package that does not need system libraries:

```bash
pip install --user PACKAGE
```

For an R/Bioconductor package:

```r
BiocManager::install("PACKAGE", ask = FALSE)
```

Both locations are persisted by bind mounts. For a reproducible team workflow,
add the package to `environment.yml` or `install-bioconductor.R` and rebuild
instead of relying on an interactive installation.
## Privacy and clinical-data boundary

The service is bound only to localhost and does not require a cloud notebook.
That is appropriate for learning and local research, but a container alone does
not make a system HIPAA-compliant. For identifiable patient sequencing data,
also use encrypted disks/backups, least-privilege Ubuntu accounts, audit policy,
approved data-transfer channels, and your institution's IRB/security controls.
