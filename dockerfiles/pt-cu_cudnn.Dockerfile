ARG CUDA="11.8"
ARG CUDNN="9"
ARG TORCH="2.5.1"

FROM pytorch/pytorch:${TORCH}-cuda${CUDA}-cudnn${CUDNN}-devel
# FROM nvidia/cuda:${CUDA}-cudnn${CUDNN}-devel-ubuntu22.04

# ENV PATH="/root/.venv/bin:$PATH"

RUN apt update --allow-insecure-repositories && \
    apt install -y locales && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    locale-gen en_US.UTF-8
ENV TZ="Asia/Shanghai"
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update --allow-insecure-repositories && \
    apt install -y \
        build-essential \
        ca-certificates \
        cmake \
        git cmake curl wget \
        openssh-server \
        libgl1-mesa-glx \
        sudo \
        zlib1g-dev \
        libncurses-dev \
        zip unzip \
        libpng-dev libjpeg-dev \
        zsh neovim && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Fix: W: GPG error:xxx, InRelease: The following signatures
# RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys  A4B469963BF863CC
