# 
# HPC Base image
# 
# Contents:
#   CUDA version 10.0
#   Boost version 3.3.8
#   GNU compilers (upstream)
# 

FROM nvidia/cuda:10.0-devel-ubuntu18.04 AS devel

# GNU compiler
RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        g++ \
        gcc \
        gfortran && \
    rm -rf /var/lib/apt/lists/*

# Boost version 1.68.0
RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        bzip2 \
        libbz2-dev \
        tar \
        wget \
        zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*
RUN mkdir -p /var/tmp && wget -q -nc --no-check-certificate -P /var/tmp https://dl.bintray.com/boostorg/release/1.68.0/source/boost_1_68_0.tar.bz2 && \
    mkdir -p /var/tmp && tar -x -f /var/tmp/boost_1_68_0.tar.bz2 -C /var/tmp -j && \
    cd /var/tmp/boost_1_68_0 && ./bootstrap.sh --prefix=/usr/local/boost --without-libraries=python && \
    ./b2 -j$(nproc) -q install && \
    rm -rf /var/tmp/boost_1_68_0.tar.bz2 /var/tmp/boost_1_68_0
ENV LD_LIBRARY_PATH=/usr/local/boost/lib:$LD_LIBRARY_PATH

COPY . /workspace

RUN cd /workspace && \
    make -j$(nproc) BOOST_PATH="/usr/local/boost"

FROM nvidia/cuda:10.0-runtime-ubuntu18.04 AS runtime

# GNU compiler runtime
RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        libgfortran3 \
        libgomp1 && \
    rm -rf /var/lib/apt/lists/*

# Boost
COPY --from=devel /usr/local/boost /usr/local/boost
ENV LD_LIBRARY_PATH=/usr/local/boost/lib:$LD_LIBRARY_PATH

COPY --from=devel /workspace/ghostz-gpu /workspace/ghostz-gpu

ENV PATH=$PATH:/workspace

WORKDIR /workspace
