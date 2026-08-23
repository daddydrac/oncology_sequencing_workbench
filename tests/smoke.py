"""Fast import, sequence-format, parallel-runtime, and GPU smoke tests."""

from __future__ import annotations

import os
from io import StringIO
from importlib.metadata import version

import Bio
import cupy as cp
import cyvcf2
import dask
import edlib
import networkx as nx
import numpy as np
import pandas as pd
import polars as pl
import pyarrow as pa
import pysam
import rpy2.robjects as ro
import scipy
import skbio
from Bio import SeqIO


fastq = "@read-1\nACGTN\n+\nIIIII\n"
records = list(SeqIO.parse(StringIO(fastq), "fastq"))
assert len(records) == 1
assert str(records[0].seq) == "ACGTN"
assert records[0].letter_annotations["phred_quality"] == [40] * 5

assert edlib.align("GATTACA", "GACTACA")["editDistance"] == 1
assert pl.DataFrame({"kmer": ["ACG", "CGT"]}).height == 2
assert pa.array(["A", "C", "G", "T"]).null_count == 0

# R is embedded in this Python process, and Bioconductor is visible to it.
assert int(ro.r("sum(c(1L, 2L, 3L))")[0]) == 6
assert bool(ro.r('requireNamespace("Biostrings", quietly = TRUE)')[0])
assert str(ro.r('as.character(Biostrings::reverseComplement(Biostrings::DNAString("ACGTN")))')[0]) == "NACGT"

device_count = cp.cuda.runtime.getDeviceCount()
assert device_count >= 1, "NVIDIA GPU is not visible to CuPy"
x = cp.arange(1024, dtype=cp.float32)
gpu_sum = float(cp.asnumpy(x.sum()))
assert gpu_sum == float(np.arange(1024, dtype=np.float32).sum())

print(f"Python:       {os.sys.version.split()[0]}")
print(f"Biopython:    {Bio.__version__}")
print(f"NumPy/SciPy:  {np.__version__} / {scipy.__version__}")
print(f"pandas:       {pd.__version__}")
print(f"Polars/Arrow: {pl.__version__} / {pa.__version__}")
print(f"scikit-bio:   {skbio.__version__}")
print(f"pysam:        {pysam.__version__}")
print(f"cyvcf2:       {cyvcf2.__version__}")
print(f"Dask:         {dask.__version__}")
print(f"NetworkX:     {nx.__version__}")
print(f"rpy2:         {version('rpy2')}")
embedded_r = ro.r('paste(R.version$major, R.version$minor, sep=".")')[0]
print(f"Embedded R:   {embedded_r}")
print(f"CUDA devices: {device_count}")
print(f"CuPy GPU sum: {gpu_sum}")
