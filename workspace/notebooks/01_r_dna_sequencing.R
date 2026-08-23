# ---
# jupyter:
#   jupytext:
#     formats: ipynb,R:percent
#   kernelspec:
#     display_name: R 4.6 · Bioconductor 3.23
#     language: R
#     name: ir46-bioc323
# ---

# %% [markdown]
# # R/Bioconductor DNA sequencing starter
#
# This notebook exercises the course's central ideas in R and then calls
# Biopython from the same R kernel through `reticulate`.

# %%
suppressPackageStartupMessages({
  library(Biostrings)
  library(pwalign)
  library(reticulate)
  library(ShortRead)
})

R.version.string
BiocManager::version()
py_config()$version_string

# %% [markdown]
# ## Phred+33 qualities and FASTQ

# %%
phred33_to_q <- function(character) utf8ToInt(character) - 33L
q_to_phred33 <- function(q) intToUtf8(as.integer(round(q)) + 33L)

stopifnot(phred33_to_q("I") == 40L, q_to_phred33(40) == "I")

course_fastq <- "/data/course/SRR835775_1.first1000.fastq"
if (file.exists(course_fastq)) {
  fastq <- readFastq(course_fastq)
  reads <- sread(fastq)
} else {
  reads <- DNAStringSet(c("GATTACA", "GACTACA", "TTACAGG"))
}
reads[seq_len(min(3L, length(reads)))]

# %% [markdown]
# ## Exact matching, k-mers, edit distance, and pairwise alignment

# %%
reference <- DNAString("GATTACAGATTACA")
start(matchPattern(DNAString("TACA"), reference))

oligonucleotideFrequency(reads, width = 3L, step = 1L)[, 1:8, drop = FALSE]

pairwise <- pairwiseAlignment(
  DNAString("GATTACA"),
  DNAString("GACTACA"),
  type = "global"
)
c(edit_distance = stringDist(DNAStringSet(c("GATTACA", "GACTACA")))[1],
  alignment_score = score(pairwise))

# %% [markdown]
# ## Call Biopython from R
#
# `RETICULATE_PYTHON` is fixed to `/opt/conda/bin/python`, so R uses the exact
# Python/Biopython environment backing the Python kernel.

# %%
bio_seq <- import("Bio.Seq")
python_sequence <- bio_seq$Seq("ACGTN")
as.character(python_sequence$reverse_complement())

py_run_string(
  paste(
    "from Bio.Align import PairwiseAligner",
    "aligner = PairwiseAligner()",
    "python_alignment_score = aligner.score('GATTACA', 'GACTACA')",
    sep = "\n"
  )
)
py$python_alignment_score

# %% [markdown]
# For reusable code, place Python modules in `/workspace/src` and call
# `source_python('/workspace/src/my_module.py')`. R scripts can live beside
# their paired R notebooks, and both languages can read `/data` and write
# `/results` without copies.
