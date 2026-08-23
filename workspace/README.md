# Working directory

Create notebooks, Python modules, and R scripts anywhere under this directory.
JupyterLab opens here, and Jupytext pairs each Python notebook with a readable
`.py` file and each R notebook with a readable `.R` file in the same folder.

Start with:

- `notebooks/00_python_with_r.ipynb` — Python kernel plus inline `%%R` cells.
- `notebooks/01_r_dna_sequencing.ipynb` — R/Bioconductor kernel plus Biopython
  through `reticulate`.

Suggested layout:

- `notebooks/` — exploratory course and oncology notebooks
- `src/` — reusable Python modules and R functions imported/sourced by notebooks
- `course/` — official JHU notebooks and slides (`make course`)
- `/data` — raw/read-only-by-convention sequencing inputs
- `/references` — large indexed reference genomes (mounted read-only)
- `/results` — generated BAM/CRAM/VCF, figures, reports, and assemblies
