# ARG BASE_IMAGE=nvidia/cuda:11.3.0-devel-ubuntu20.04
ARG BASE_IMAGE=nvidia/cuda:11.3.0-cudnn8-devel-ubuntu20.04

FROM ${BASE_IMAGE} as dev-base

ARG DEBIAN_FRONTEND=noninteractive
RUN  apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        ccache \
        cmake \
        curl \
        wget \
        git \
        libjpeg-dev \
        libpng-dev && \
    rm -rf /var/lib/apt/lists/*
RUN /usr/sbin/update-ccache-symlinks
RUN mkdir /opt/ccache && ccache --set-config=cache_dir=/opt/ccache
ENV PATH /opt/conda/bin:$PATH

ARG PYTHON_VERSION=3.8
ARG CUDA_VERSION=11.3
ARG CUDA_CHANNEL=nvidia
ARG INSTALL_CHANNEL=pytorch-nightly
RUN curl -fsSL -v -o ~/miniconda.sh -O  https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh  && \
    chmod +x ~/miniconda.sh && \
    ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda install -c "${INSTALL_CHANNEL}" -c "${CUDA_CHANNEL}" -y \
        python=${PYTHON_VERSION} conda-build \
        pyyaml numpy ipython && \
    /opt/conda/bin/conda clean -ya

FROM dev-base as dev
RUN pip install onnx onnxruntime Pillow "pycuda<2021.1" "torch==1.9.0"
# install TensorRT
ARG OS="ubuntu2004"
ARG TAG="cuda11.3-trt8.0.1.6-ga-20210626"
ARG TRT_REPO=nv-tensorrt-repo-${OS}-${TAG}_1-1_amd64.deb
ADD ${TRT_REPO} .
RUN dpkg -i ${TRT_REPO}
    # apt-key add /var/nv-tensorrt-repo-${OS}-${TAG}/7fa2af80.pub && \
    # apt update && apt install python3-libnvinfer-dev tensorrt
