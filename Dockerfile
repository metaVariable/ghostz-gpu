FROM nvidia/cuda:10.0-devel-ubuntu18.04 AS devel

ARG WORK_DIR="/workspace"
ARG BOOST_VERSION="1_68_0"

RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        make \
        g++ \
        bzip2 \
        libbz2-dev \
        tar \
        wget \
        zlib1g-dev \
    && apt-get clean \
    && rm -rf /var/libc/apt/lists/*

# Boost
RUN mkdir -p /var/tmp && wget -q -nc --no-check-certificate -P /var/tmp https://dl.bintray.com/boostorg/release/1.68.0/source/boost_1_68_0.tar.bz2 && \
    mkdir -p /var/tmp && tar -x -f /var/tmp/boost_${BOOST_VERSION}.tar.bz2 -C /var/tmp -j && \
    cd /var/tmp/boost_${BOOST_VERSION} && ./bootstrap.sh --prefix=/usr/local/boost --without-libraries=python && \
    ./b2 -j$(nproc) -q install && \
    rm -rf /var/tmp/boost_${BOOST_VERSION}.tar.bz2 /var/tmp/boost_${BOOST_VERSION}
ENV LD_LIBRARY_PATH=/usr/local/boost/lib:$LD_LIBRARY_PATH

COPY . ${WORK_DIR}

RUN cd ${WORK_DIR} && \
    make -j$(nproc) BOOST_PATH="/usr/local/boost"


# runtime image
FROM nvidia/cuda:10.0-runtime-ubuntu18.04 as runtime

ARG WORK_DIR="/workspace"
ENV GHOSTZ_BIN="ghostz-gpu"

# GNU compiler runtime
RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        libgomp1 \
    && apt-get clean \
    && rm -rf /var/libc/apt/lists/*

# Boost
COPY --from=devel /usr/local/boost /usr/local/boost
ENV LD_LIBRARY_PATH=/usr/local/boost/lib:$LD_LIBRARY_PATH

# GHOSTZ-GPU
COPY --from=devel ${WORK_DIR}/${GHOSTZ_BIN} /usr/local/bin/${GHOSTZ_BIN}

WORKDIR ${WORK_DIR}

CMD echo "exec:  $GHOSTZ_BIN -h";  $GHOSTZ_BIN -h