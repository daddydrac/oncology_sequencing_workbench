<p align="center">
  <img src="https://fundit.fr/sites/default/files/actors/2523-universite-johns-hopkins-jhu.png" alt="Johns Hopkins University" width="360" />
</p>

# Johns Hopkins Genomic Data Science Course Quickstart

This workbench is a local, GPU-ready learning environment for the [Johns Hopkins University Genomic Data Science Specialization on Coursera](https://www.coursera.org/specializations/genomic-data-science), with particular support for [Algorithms for DNA Sequencing](https://www.coursera.org/learn/dna-sequencing). It keeps the course notebooks, real sequencing inputs, Python, R, Bioconductor, and command-line tools in one reproducible Docker Compose environment on your Ubuntu Dell workstation.

## What the specialization covers

Coursera presents this as a six-course, intermediate-level sequence covering next-generation sequencing experiments, genomic technologies, DNA/RNA/epigenetic patterns, genome analysis, command-line work, Python, R, Bioconductor, and statistics:

1. **Introduction to Genomic Technologies** â€” sequencing biology, experimental technologies, and the data science concepts behind modern genomic measurements.
2. **Python for Genomic Data Science** â€” Python, Jupyter/IPython notebooks, file I/O, data manipulation, and bioinformatics programming.
3. **Algorithms for DNA Sequencing** â€” exact and approximate matching, indexing, dynamic programming, read alignment, assembly, overlap graphs, and De Bruijn graphs using real genomic data.
4. **Command Line Tools for Genomic Data Science** â€” Unix shell, file management, and scalable handling of genomic datasets.
5. **Bioconductor for Genomic Data Science** â€” R and Bioconductor workflows for genomic data analysis.
6. **Statistics for Genomic Data Science** â€” the statistical methods used in common genomic data science projects.

The specialization page currently describes a flexible, self-paced program and recommends taking the courses in the listed order. It also notes that auditing individual courses may be available without a completion certificate; check Coursera for current enrollment and audit terms.

## Start the workbench

From the extracted repository directory on the Dell:

```bash
make setup
make check-host
make build
make start
```

`make start` prints a local JupyterLab URL and opens it on the Ubuntu desktop. The server binds only to `127.0.0.1`; if you use a Mac to work remotely, create an SSH tunnel:

```bash
ssh -L 8888:127.0.0.1:8888 YOUR_USER@YOUR_DELL
```

Then use the URL printed by `make start` in your Mac browser.

## Download the official course materials and datasets

With the container running, execute:

```bash
make course
```

This idempotent command performs the course setup for you:

- Clones or fast-forwards the official [ADS1 practical-notebooks repository](https://github.com/BenLangmead/ads1-notebookssvg) into `workspace/course/notebooks`.
- Clones or fast-forwards the official [ADS1 slides repository](https://github.com/BenLangmead/ads1-slidessvg) into `workspace/course/slides`.
- Downloads public course inputs into `data/course`: `lambda_virus.fa`, two supplied FASTQ subsets, a GRCh38 chromosome 1 excerpt, assembly reads, and the course helper modules `bm_preproc.py` and `kmer_index.py`.
- Resumes interrupted downloads, retries transient failures, and does not re-download a non-empty file that is already present.
- Compiles the supplied Python helper modules and verifies that every downloaded FASTQ/FQ file has a valid four-line record layout.

For an additional public course URL, use the built-in downloader:

```bash
docker compose exec workbench download-data.sh \
  'https://COURSE-URL/example.fastq.gz' \
  'course/example.fastq.gz' \
  'OPTIONAL_SHA256'
```

Use a SHA-256 when the course or instructor provides one. Do not put identifiable patient data in the image or public repositories; place approved local data under `data/` and results under `results/`.

## Where everything goes

| On your Dell | In the container | Use it for |
|---|---|---|
| `workspace/` | `/workspace` | Jupyter notebooks, paired scripts, reusable course code |
| `workspace/course/` | `/workspace/course` | Official ADS1 notebooks and lecture slides |
| `data/course/` | `/data/course` | Downloaded public FASTA, FASTQ, and helper modules |
| `data/` | `/data` | Larger approved sequencing inputs |
| `references/` | `/references` | Reference genomes and indexes; mounted read-only |
| `results/` | `/results` | BAM/CRAM/VCF, assemblies, figures, QC, and Parquet outputs |

All of these are bind mounts: a file written from Jupyter, Python, R, or the Ubuntu desktop is the same file.

## Use Python and R in the same workflow

Choose **Python 3.12 Â· Genomics (GPU-ready)** for Biopython, course algorithms, data engineering, and optional CuPy work. The R bridge is loaded automatically in Python notebooks, so you can use `%R` for an expression or `%%R` for an R/Bioconductor cell.

Choose **R 4.6 Â· Bioconductor 3.23** for Biostrings, ShortRead, Rsamtools, VariantAnnotation, pwalign, DECIPHER, and statistical workflows. R can call the same installed Python/Biopython environment through `reticulate`.

Start with these included notebooks:

- `notebooks/00_python_with_r.ipynb` â€” Python with inline R/Bioconductor and shared Parquet.
- `notebooks/01_r_dna_sequencing.ipynb` â€” Phred+33, FASTQ, exact matching, k-mers, edit distance, pairwise alignment, and Biopython from R.

Jupytext keeps paired source files beside notebooks: Python notebooks pair with `.py` files and R notebooks pair with `.R` files. That makes assignments easy to edit in JupyterLab, VS Code, or another local editor without copying files between environments.

## Included features and practical benefits

| Feature | Benefit during the course |
|---|---|
| Automatic course retrieval | One command places notebooks, slides, FASTA/FASTQ inputs, and helper code in predictable paths. |
| Resumable, idempotent downloads | Re-running `make course` is safe after a disconnect and avoids downloading already-complete files. |
| FASTQ layout validation | Catches incomplete or corrupted public course downloads before you start debugging Python/R code. |
| Python + R + Bioconductor | Match the specializationâ€™s programming and Bioconductor content without maintaining separate environments. |
| Shared mounts and stable paths | The same `/data`, `/references`, `/results`, and `/workspace` paths work from notebooks, shells, Python, and R. |
| Sequencing toolchain | Biopython, Biostrings, pysam, SAMtools, BCFtools, BWA-MEM2, Bowtie 2, minimap2, FastQC, MultiQC, and more are already available. |
| Dark JupyterLab with LSP | Syntax highlighting, completion, signatures, diagnostics, formatting, smart indentation, and go-to-definition support for Python and R. |
| Dell-oriented resource defaults | Uses 8 CPU threads, up to 112 GB RAM, 16 GB shared memory, and the NVIDIA RTX A3000 for workloads explicitly written to use the GPU. |
| Persistent packages and caches | R/Python user packages and download caches survive a container rebuild or replacement. |
| Verification command | `make verify` checks both Jupyter kernels, the Râ†”Python bridges, Bioconductor, Biopython, genomics CLI tools, and GPU visibility. |

## Before each practical session

```bash
make start
make course
make verify
```

Open the relevant course notebook under `workspace/course/notebooks`, select the intended kernel, and keep raw inputs under `/data/course` or `/data`. For the Algorithms for DNA Sequencing exercises, begin with the supplied FASTA/FASTQ files and `bm_preproc.py`/`kmer_index.py`; keep your solutions and reusable functions under `workspace/notebooks` and `workspace/src`.

## Primary course links

- [Genomic Data Science Specialization â€” Coursera](https://www.coursera.org/specializations/genomic-data-science)
- [Algorithms for DNA Sequencing â€” Coursera](https://www.coursera.org/learn/dna-sequencing)
- [Algorithms for DNA Sequencing practical notebooks](https://github.com/BenLangmead/ads1-notebookssvg)
- [Algorithms for DNA Sequencing lecture slides](https://github.com/BenLangmead/ads1-slidessvg)
- [Workbench setup and operating guide](README.md)
