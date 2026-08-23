# ---
# jupyter:
#   jupytext:
#     formats: ipynb,py:percent
#   kernelspec:
#     display_name: Python 3.12 · Genomics (GPU-ready)
#     language: python
#     name: python3
# ---

# %% [markdown]
# # Python notebook with inline R/Bioconductor
#
# The workbench loads the rpy2 extension automatically, so `%R` and `%%R` are
# ready in every Python notebook. Objects can cross the language boundary, and
# both runtimes use the same mounted files.

# %%
from pathlib import Path

from Bio.Seq import Seq


sequences = ["ACGTN", "GCGCGC", "ATATAT"]
python_reverse_complements = [str(Seq(sequence).reverse_complement()) for sequence in sequences]
python_reverse_complements

# %%R -i sequences -o gc_fraction
suppressPackageStartupMessages(library(Biostrings))

dna <- DNAStringSet(sequences)
gc_fraction <- rowSums(letterFrequency(dna, c("G", "C"), as.prob = TRUE))
gc_fraction

# %%
list(zip(sequences, list(gc_fraction), strict=True))

# %% [markdown]
# The shared Arrow/Parquet route is better than in-memory conversion for very
# large tables. R and Python see `/results` as the same bind-mounted directory.

# %%
import pandas as pd


interop_path = "/results/python_r_interop.parquet"
pd.DataFrame(
    {"sequence": sequences, "python_reverse_complement": python_reverse_complements}
).to_parquet(interop_path, index=False)
Path(interop_path)

# %%R -i interop_path
suppressPackageStartupMessages(library(arrow))

interop <- read_parquet(as.character(interop_path))
interop$r_reverse_complement <- as.character(
  reverseComplement(DNAStringSet(interop$sequence))
)
interop
