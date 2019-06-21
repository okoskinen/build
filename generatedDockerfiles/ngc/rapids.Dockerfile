ARG CUDA_VERSION=10.0
ARG BASE_IMAGE=devel-ubuntu18.04
ARG RAPIDSAI_NIGHTLY_CONDA_LABEL=rapidsai-nightly/label/cuda${CUDA_VERSION}
ARG MINICONDA_URL=https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
ARG PYTHON_VERSION=3.6
ARG RAPIDSAI_CONDA_LABEL=rapidsai/label/cuda${CUDA_VERSION}
ARG NVIDIA_CONDA_LABEL=nvidia/label/cuda${CUDA_VERSION}
ARG CMAKE_VERSION=3.14.3
ARG RAPIDS_CONDA_VERSION_SPEC=0.8*
ARG DASK_XGBOOST_CONDA_VERSION_SPEC=0.2*
ARG IPYTHON_VERSION=7.3*

FROM nvcr.io/nvidia/cuda:${CUDA_VERSION}-${BASE_IMAGE}
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH=$PATH:/conda/bin
ENV RAPIDS_DIR=/rapids

ARG CUDA_VERSION
ARG RAPIDSAI_NIGHTLY_CONDA_LABEL
ARG MINICONDA_URL
ARG PYTHON_VERSION
ARG RAPIDSAI_CONDA_LABEL
ARG NVIDIA_CONDA_LABEL
ARG CMAKE_VERSION
ARG RAPIDS_CONDA_VERSION_SPEC
ARG DASK_XGBOOST_CONDA_VERSION_SPEC
ARG IPYTHON_VERSION

COPY rapids.Dockerfile /Dockerfile

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get -qqy install --no-install-recommends \
      apt-utils \
      curl \
      git && \
      apt-get autoremove -y && \
      apt-get clean && \
      rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl ${MINICONDA_URL} -o /miniconda.sh && \
    sh /miniconda.sh -b -p /conda && \
    conda update -n base conda && \
    rm -f /miniconda.sh && \
    conda clean -a

########################################
# conda environment
# NOTE: use these mirrors for faster downloads
#       -c http://10.33.227.188:88/numba \
#       -c http://10.33.227.188:88/conda-forge \
RUN export CUDA_MAJOR=`echo $CUDA_VERSION | cut -d'.' -f1` && \
    export CUDA_MINOR=`echo $CUDA_VERSION | cut -d'.' -f2` && \
    conda create -n rapids python=${PYTHON_VERSION} && \
    conda install -n rapids -y \
      -c ${RAPIDSAI_CONDA_LABEL} \
      -c ${RAPIDSAI_NIGHTLY_CONDA_LABEL} \
      -c ${NVIDIA_CONDA_LABEL} \
      -c nvidia \
      -c rapidsai-nightly/label/xgboost \
      -c conda-forge \
      -c pytorch \
      -c defaults \
      jupyterlab \
      ipython=${IPYTHON_VERSION} \
      seaborn \
      cmake=${CMAKE_VERSION} \
      cudatoolkit=${CUDA_MAJOR}.${CUDA_MINOR} \
      cudf=${RAPIDS_CONDA_VERSION_SPEC} \
      cuml=${RAPIDS_CONDA_VERSION_SPEC} \
      cugraph=${RAPIDS_CONDA_VERSION_SPEC} \
      xgboost=${XGBOOST_CONDA_VERSION_SPEC} \
      dask-cuda=${RAPIDS_CONDA_VERSION_SPEC} \
      dask-cudf=${RAPIDS_CONDA_VERSION_SPEC} \
      dask-cuml=${RAPIDS_CONDA_VERSION_SPEC} \
      dask-xgboost=${DASK_XGBOOST_CONDA_VERSION_SPEC} && \
      conda clean -a

# Automatically active conda env
RUN echo "source activate rapids" > ~/.bashrc && \
    mkdir -p ${RAPIDS_DIR}
WORKDIR ${RAPIDS_DIR}

# Enables "source activate conda"
SHELL ["/bin/bash", "-c"]

CMD ["/bin/bash"]
