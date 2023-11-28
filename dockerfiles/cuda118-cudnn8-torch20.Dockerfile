ARG TORCH="1.11.0"
ARG CUDA="11.8.0"
ARG CUDNN="8"
#FROM pytorch/pytorch:${TORCH}-cuda${CUDA}-cudnn${CUDNN}-devel

FROM nvidia/cuda:${CUDA}-cudnn${CUDNN}-devel-ubuntu20.04

ENV TZ="Asia/Shanghai"
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update --allow-insecure-repositories && \
    apt install -y \
        fonts-powerline \
        locales && \
    locale-gen en_US.UTF-8

RUN apt update --allow-insecure-repositories && \
    apt install -y \
        build-essential \
        ca-certificates \
        sudo cmake git cmake curl wget \
        openssh-server \
        libgl1-mesa-glx \
        zlib1g-dev \
        libncurses-dev \
        zip unzip \
        libpng-dev libjpeg-dev \
        neovim \
        zsh && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Fix: W: GPG error:xxx, InRelease: The following signatures
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys  A4B469963BF863CC

ENV PATH /opt/conda/bin:$PATH

ARG PYTHON_VERSION=3.9

RUN \
    curl -fsSL -v -o ~/miniconda.sh -O "https://repo.anaconda.com/miniconda/Miniconda3-py38_4.12.0-Linux-x86_64.sh" && \
    $sudo chmod +x ~/miniconda.sh && \
    ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda install -y python=${PYTHON_VERSION} \
                                    cmake conda-build pyyaml \
                                    numpy ipython && \

    /opt/conda/bin/conda install pytorch==2.0.1 torchvision==0.15.2 \
    	torchaudio==2.0.2 pytorch-cuda=11.8 -c pytorch -c nvidia && \

    pip install opencv-python -i https://pypi.tuna.tsinghua.edu.cn/simple && \
    /opt/conda/bin/conda clean -ya
