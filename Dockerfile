# syntax=docker/dockerfile:1.7
ARG BIOC_VERSION=RELEASE_3_22

ARG MAMBA_VERSION=2.3.3
FROM mambaorg/micromamba:${MAMBA_VERSION} AS micromamba

FROM bioconductor/bioconductor_docker:${BIOC_VERSION}

ARG HOST_UID=1000
ARG HOST_GID=1000
ARG CPU_THREADS=8
ARG RPY2_VERSION=3.6.6

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
USER root

ENV DEBIAN_FRONTEND=noninteractive \
    MAMBA_ROOT_PREFIX=/opt/micromamba \
    CONDA_PREFIX=/opt/conda \
    PATH=/opt/workbench/scripts:/opt/conda/bin:/home/rstudio/.local/bin:${PATH} \
    PYTHONUSERBASE=/home/rstudio/.local \
    PYTHONPATH=/workspace/src \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    RETICULATE_PYTHON=/opt/conda/bin/python \
    RETICULATE_AUTOCONFIGURE=0 \
    RPY2_CFFI_MODE=API \
    R_MAX_NUM_DLLS=1000 \
    OMP_NUM_THREADS=${CPU_THREADS} \
    OPENBLAS_NUM_THREADS=${CPU_THREADS} \
    MKL_NUM_THREADS=${CPU_THREADS} \
    NUMEXPR_NUM_THREADS=${CPU_THREADS} \
    POLARS_MAX_THREADS=${CPU_THREADS} \
    ARROW_NUM_THREADS=${CPU_THREADS} \
    MALLOC_ARENA_MAX=4 \
    NVIDIA_VISIBLE_DEVICES=all \
    NVIDIA_DRIVER_CAPABILITIES=compute,utility

COPY --from=micromamba /bin/micromamba /usr/local/bin/micromamba

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash-completion \
        build-essential \
        ca-certificates \
        cmake \
        curl \
        git \
        graphviz \
        jq \
        less \
        libbz2-dev \
        libcurl4-openssl-dev \
        libdeflate-dev \
        libhdf5-dev \
        liblzma-dev \
        libncurses-dev \
        libssl-dev \
        libxml2-dev \
        libzstd-dev \
        nano \
        ninja-build \
        openssh-client \
        parallel \
        pkg-config \
        procps \
        rsync \
        tini \
        unzip \
        vim-tiny \
        wget \
    && rm -rf /var/lib/apt/lists/*

COPY environment.yml /tmp/environment.yml
RUN micromamba create --yes --prefix /opt/conda --file /tmp/environment.yml \
    && micromamba clean --all --yes \
    && rm -f /tmp/environment.yml \
    && python -m ipykernel install \
         --prefix=/opt/conda \
         --name=python3 \
         --display-name="Python 3.12 · Genomics (GPU-ready)"

COPY install-bioconductor.R /tmp/install-bioconductor.R
RUN Rscript /tmp/install-bioconductor.R \
    && rm -f /tmp/install-bioconductor.R

# Compile rpy2 against the image's R installation. Installing it with pip here,
# rather than Conda, prevents a second R distribution from entering /opt/conda.
RUN R_HOME="$(R RHOME)" python -m pip install "rpy2==${RPY2_VERSION}" \
    && R_HOME="$(R RHOME)" python -c \
       'import rpy2.robjects as ro; assert int(ro.r("1L + 1L")[0]) == 2' \
    && Rscript -e \
       'stopifnot(reticulate::py_available(initialize = TRUE)); stopifnot(reticulate::py_eval("6 * 7") == 42)'

# Match the image's rstudio account to the Ubuntu workstation user so bind-mounted
# notebooks, Python modules, results, and downloaded data are never written as root.
RUN current_uid="$(id -u rstudio)" \
    && current_gid="$(id -g rstudio)" \
    && if [[ "${current_gid}" != "${HOST_GID}" ]]; then groupmod --gid "${HOST_GID}" rstudio; fi \
    && if [[ "${current_uid}" != "${HOST_UID}" ]]; then usermod --uid "${HOST_UID}" rstudio; fi \
    && chown -R rstudio:rstudio /home/rstudio

COPY config/jupyter_server_config.py /etc/jupyter/jupyter_server_config.py
COPY config/jupyterlab-overrides.json /opt/conda/share/jupyter/lab/settings/overrides.json
COPY config/jupytext.toml /etc/jupyter/jupytext.toml
COPY config/ipython-startup-rpy2.py /opt/workbench/config/ipython-startup-rpy2.py
COPY scripts /opt/workbench/scripts
COPY tests /opt/workbench/tests

RUN chmod 0755 /opt/workbench/scripts/*.sh \
    && mkdir -p \
        /workspace \
        /data/course \
        /references \
        /results \
        /usr/local/lib/R/host-site-library \
    && chown -R rstudio:rstudio \
        /workspace \
        /data \
        /references \
        /results \
        /usr/local/lib/R/host-site-library \
    && jupyter labextension list \
    && jupyter server extension list

WORKDIR /workspace
USER rstudio

EXPOSE 8888
ENTRYPOINT ["/usr/bin/tini", "-g", "--", "/opt/workbench/scripts/container-entrypoint.sh"]
CMD ["jupyter", "lab", "--config=/etc/jupyter/jupyter_server_config.py"]
