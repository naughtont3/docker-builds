#!/bin/bash

echo "HELLO FROM SCRIPTLET-POST"
echo "HELLO SCRIPTLET-POST DBG: NPROCS=$NPROCS"
echo "HELLO SCRIPTLET-POST DBG: PREFIX=$PREFIX"

ls ${HOST_FILES}


# Just append these to end (instead of awk/sed'ing existing commented lines)
echo "deb http://archive.ubuntu.com/ubuntu/ zesty universe" >> /etc/apt/sources.list
echo "deb http://archive.ubuntu.com/ubuntu/ zesty-updates universe" >> /etc/apt/sources.list
echo "deb http://archive.ubuntu.com/ubuntu/ zesty-security universe" >> /etc/apt/sources.list

apt-get -y update \
     && apt-get install -y --no-install-recommends \
        autoconf \
        automake \
        bc \
        bzip2 \
        g++ \
        gcc \
        gfortran \
        git \
        iputils-ping \
        libtool \
        lsb-release \
        net-tools \
        m4 \
        make \
        patch \
        perl \
        time \
        vim \
        wget \
        zlib1g-dev \
     && apt-get clean || exit 1

apt-get -y update \
     && apt-get install -y --no-install-recommends \
        libopenmpi-dev \
        openmpi-bin \
        openmpi-common \
     && apt-get clean || exit 1

mkdir -p ${PREFIX}/src
mkdir -p ${PREFIX}/src/config/
mkdir -p ${PREFIX}/src/tar/
mkdir -p ${PREFIX}/runs/
mkdir -p ${PREFIX}/runs/Test1

####
# We should have bind mounted in the '/src' directory
# Example:
#    cd docker-builds/hpcc-mpi/
#    ls files/
#    sudo singularity exec -B files:/src -w MY.img /src/sing-setup.sh
####
cp ${HOST_FILES}/run-omb.sh ${PREFIX}/runs/run-omb.sh
cp ${HOST_FILES}/osu-micro-benchmarks-5.3.2.tar.gz ${PREFIX}/src/tar/osu-micro-benchmarks-5.3.2.tar.gz


# Build OSU Micro Benchmark for OpenSHMEM
cd ${PREFIX}/src/ && \
    export OMB_ARCHIVE=${PREFIX}/src/tar/osu-micro-benchmarks-5.3.2.tar.gz && \
    export OMB_SOURCE_DIR=${PREFIX}/src/omb && \
    mkdir -p ${OMB_SOURCE_DIR} && \
    mkdir -p ${PREFIX}/src/omb-install && \
    tar -zxf ${OMB_ARCHIVE} -C ${OMB_SOURCE_DIR} --strip-components=1 && \
    cd ${PREFIX}/src/omb && \
    ./configure --prefix=${PREFIX}/src/omb-install CC=oshcc && \
    make -C openshmem CC=oshcc  && \
    make -C openshmem CC=oshcc  install 


if [ "x$MY_USER" == "x" ] ; then
    echo "WARNING: USER info not being conveyed for chown for container files"
else
    chown -R $MY_USER ${PREFIX}/
fi


