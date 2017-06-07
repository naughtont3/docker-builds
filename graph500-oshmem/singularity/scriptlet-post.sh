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
cp ${HOST_FILES}/run-graph500.sh ${PREFIX}/runs/run-graph500.sh
cp ${HOST_FILES}/make.inc        ${PREFIX}/src/config/make.inc
cp ${HOST_FILES}/graph500_openshmem-master_mpi_Makefile.diff ${PREFIX}/src/config/graph500_openshmem-master_mpi_Makefile.diff
cp ${HOST_FILES}/graph500_openshmem-master-02f51b620873997c9160f0eae1fc961c0188d2d7.tar.bz2 ${PREFIX}/src/tar/graph500_openshmem-master-02f51b620873997c9160f0eae1fc961c0188d2d7.tar.bz2
cp ${HOST_FILES}/graph500-2.1.4.tar.bz2 ${PREFIX}/src/tar/graph500-2.1.4.tar.bz2

# Build Graph500 (oshmem)
cd ${PREFIX}/src/ && \
	export G500_ARCHIVE=${PREFIX}/src/tar/graph500_openshmem-master-02f51b620873997c9160f0eae1fc961c0188d2d7.tar.bz2 && \
    export G500_SOURCE_DIR=${PREFIX}/src/graph500-oshmem && \
    mkdir -p ${G500_SOURCE_DIR} && \
    tar -jxf ${G500_ARCHIVE} -C ${G500_SOURCE_DIR} --strip-components=1 && \
    cp ${PREFIX}/src/config/make.inc ${G500_SOURCE_DIR}/make.inc && \
    cd ${PREFIX}/src/graph500-oshmem && \
    cd ${PREFIX}/src/graph500-oshmem && \
    patch -p 1 < ${PREFIX}/src/config/graph500_openshmem-master_mpi_Makefile.diff && \
    cd ${PREFIX}/src/graph500-oshmem && \
    make make-edgelist && \
    make CC=oshcc OSHCC=oshcc MPICC=mpicc make-edgelist-shmem && \
    make OSHCC=oshcc MPICC=mpicc || exit 1

# Build the Graph500.org version (stable) that does 
# *not* include the OpenSHMEM port of the benchmark.
cd ${PREFIX}/src/ && \
    export G500_ORG_ARCHIVE=${PREFIX}/src/tar/graph500-2.1.4.tar.bz2 && \
    export G500_ORG_SOURCE_DIR=${PREFIX}/src/graph500-2.1.4 && \
    mkdir -p ${G500_ORG_SOURCE_DIR} && \
    tar -jxf ${G500_ORG_ARCHIVE} -C ${G500_ORG_SOURCE_DIR} --strip-components=1 && \
    cp ${PREFIX}/src/config/make.inc ${G500_ORG_SOURCE_DIR}/make.inc && \
    cd ${G500_ORG_SOURCE_DIR} && \
    make -j ${NPROCS} || exit 1

if [ "x$MY_USER" == "x" ] ; then
    echo "WARNING: USER info not being conveyed for chown for container files"
else
    chown -R $MY_USER ${PREFIX}/
fi


