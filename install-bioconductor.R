options(
  repos = c(CRAN = "https://cloud.r-project.org"),
  Ncpus = min(8L, max(1L, parallel::detectCores(logical = FALSE))),
  timeout = 1200
)

if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")
}

expected_bioc <- "3.23"
if (as.character(BiocManager::version()) != expected_bioc) {
  BiocManager::install(version = expected_bioc, ask = FALSE, update = FALSE)
}

bioc_packages <- c(
  "AnnotationDbi",
  "BiocFileCache",
  "BiocGenerics",
  "BiocIO",
  "BiocParallel",
  "Biostrings",
  "BSgenome",
  "DECIPHER",
  "DelayedArray",
  "DESeq2",
  "edgeR",
  "GenomeInfoDb",
  "GenomicAlignments",
  "GenomicFeatures",
  "GenomicFiles",
  "GenomicRanges",
  "HDF5Array",
  "IRanges",
  "limma",
  "maftools",
  "MutationalPatterns",
  "org.Hs.eg.db",
  "pwalign",
  "Rbowtie2",
  "Rhtslib",
  "Rsamtools",
  "Rsubread",
  "rtracklayer",
  "ShortRead",
  "SingleCellExperiment",
  "SummarizedExperiment",
  "VariantAnnotation"
)

cran_packages <- c(
  "arrow",
  "data.table",
  "devtools",
  "future",
  "future.apply",
  "formatR",
  "ggplot2",
  "IRkernel",
  "languageserver",
  "microbenchmark",
  "pak",
  "reticulate",
  "seqinr",
  "targets",
  "tidyverse"
)

BiocManager::install(
  unique(c(bioc_packages, cran_packages)),
  ask = FALSE,
  update = FALSE,
  checkBuilt = TRUE
)

IRkernel::installspec(
  name = "ir46-bioc323",
  displayname = "R 4.6 · Bioconductor 3.23",
  prefix = "/opt/conda"
)

stopifnot(as.character(BiocManager::version()) == expected_bioc)
stopifnot(all(vapply(
  c("Biostrings", "DECIPHER", "pwalign", "Rbowtie2", "ShortRead"),
  requireNamespace,
  quietly = TRUE,
  FUN.VALUE = logical(1)
)))
