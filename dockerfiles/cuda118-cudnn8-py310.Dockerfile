ARG CUDA="11.8.0"
ARG CUDNN="8"

FROM nvidia/cuda:${CUDA}-cudnn${CUDNN}-devel-ubuntu22.04

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
        sudo \
        cmake git curl wget \
        openssh-server \
        libgl1-mesa-glx \
        zlib1g-dev \
        libncurses-dev \
        libpng-dev libjpeg-dev \
        zip unzip \
        zsh && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Fix: W: GPG error:xxx, InRelease: The following signatures
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys  A4B469963BF863CC

ENV PATH ${HOME}/.conda/bin:$PATH
ARG PYTHON_VERSION=3.10

RUN \
    curl -fsSL -v -o ~/miniconda.sh -O "https://repo.anaconda.com/miniconda/Miniconda3-py310_24.7.1-0-Linux-x86_64.sh" && \
    chmod +x ~/miniconda.sh && \
    ~/miniconda.sh -b -p ${HOME}/.conda && \
    rm ~/miniconda.sh && \

    conda install -y python=${PYTHON_VERSION} \
        cmake && \

    conda install pytorch==2.4.0 torchvision==0.19.0 torchaudio==2.4.0 pytorch-cuda=11.8 -c pytorch -c nvidia && \

    conda clean -ya
