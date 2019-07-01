FROM nvidia/cuda:10.0-devel-ubuntu18.04 AS devel

ARG WORK_DIR="/workspace"
ARG BOOST_VERSION="x.x.x"

RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        make \
        g++ \
        libboost-all-dev \
    && apt-get clean \
    && rm -rf /var/libc/apt/lists/*

ADD . ${WORK_DIR}
RUN cd ${WORK_DIR} && \
    make -j$(nproc)
    #   BOOST_PATH="/usr/include/boost"

