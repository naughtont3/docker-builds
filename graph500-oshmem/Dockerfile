###########################################################################
#
# To rebuild image:
#   docker build -t="naughtont3/<IMAGENAME>" .
#   docker push naughtont3/<IMAGENAME>
#
# To rebuild image (with private git repos):
#   # See: https://help.github.com/articles/creating-an-access-token-for-command-line-use/
#   docker build --build-arg=GITHUB_TOKEN=$(cat mytoken) -t="naughtont3/<IMAGENAME>" .
#
# To run image (start container):
#   docker run -d -P --name <NAME> naughtont3/<IMAGENAME> /bin/sleep infinity
#
# To run image (start container) with bind-mounted host dir:
#   docker run -d -P --name <NAME> \
#           -v /home/data:/data  naughtont3/<IMAGENAME> /bin/sleep infinity
#
# To attach to the running container:
#   docker exec -ti <NAME> /bin/bash
#
# Examples:
#   docker build -t="naughtont3/graph500-oshmem" .
#   docker push naughtont3/graph500-oshmem
#   docker run -d -P --name devel_ve naughtont3/graph500-oshmem /bin/sleep infinity
#   docker exec -ti devel_ve /bin/bash
#   
###########################################################################
#
# NOTES:
# - 19may2017: Initial creation based on running container template,
#    using public 'graph500_openshmem' repo from Ed D'Azevedo.
#    (https://code.ornl.gov/e6d/graph500_openshmem)
#
###########################################################################

FROM ubuntu:16.04
MAINTAINER Thomas Naughton <naughtont@ornl.gov>

# Build-arg: NPROCS for parallel make
ARG NPROCS=4

# Build-arg: github token
# Note: Should be passed via '--build-arg'!!!
# (See: https://help.github.com/articles/creating-an-access-token-for-command-line-use/)
ARG GITHUB_TOKEN=thetoken

# Set PREFIX to a common Hobbes directory
ENV PREFIX=/benchmarks
RUN mkdir -p "${PREFIX}" \
    && mkdir -p "${PREFIX}/src" \
    && mkdir -p "${PREFIX}/src/tar" \
    && mkdir -p "${PREFIX}/src/config"\
    && mkdir -p "${PREFIX}/runs" \
    && mkdir -p "${PREFIX}/runs/Test1"

ADD files/run-graph500.sh ${PREFIX}/runs/run-graph500.sh
ADD files/make.inc        ${PREFIX}/src/config/make.inc
ADD files/graph500_openshmem-master_mpi_Makefile.diff ${PREFIX}/src/config/graph500_openshmem-master_mpi_Makefile.diff 

# XXX: TJN - need to avoid adding this directly to repo.
#      For now I keep entry in Dockerfile, but not add 
#      the actual tarball to Git.
ADD files/graph500_openshmem-master-02f51b620873997c9160f0eae1fc961c0188d2d7.tar.bz2 ${PREFIX}/src/tar/graph500_openshmem-master-02f51b620873997c9160f0eae1fc961c0188d2d7.tar.bz2

#ENV container docker

# This will prevent questions from being asked during the install
ENV DEBIAN_FRONTEND noninteractive

# Get certs so HTTPS requests (e.g., git clone) works
RUN apt-get -y update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
    && apt-get clean

# Install SSH client/server
#  o Note: We use 'ssh-keygen' from openssh-client in add 'mpiuser' step.)
#  o Note: Add 'sshd' from openssh-client in case we need that too.
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get dist-upgrade -y \
    && apt-get install -y --no-install-recommends \
        openssh-client \
        openssh-server \
    && apt-get clean

# Install various useful/prereq packages 
RUN apt-get -y update \
    && apt-get install -y --no-install-recommends \
        autoconf \
        automake \
		bc \
        g++ \
        gcc \
        gfortran \
        git \
        iputils-ping \
        libtool \
        net-tools \
        m4 \
        make \
        patch \
        perl \
        time \
        vim \
        wget \
        zlib1g-dev \
    && apt-get clean


#
# *) Build/Install OpenMPI 
#    (which will result in: /usr/local/{bin,lib,...}/)
#
#  NOTE: Use '--strip-components=1' to avoid tarball dirname in dest dir,
#        e.g., no "openmpi-1.10.2/" in dest dir, just contents into dest dir.
#        (Instead we control source code dir name explicitly, in case we
#        want something different in the src dirname.)
#
###
# OLDER-STUFF...
#    LDFLAGS=-static ./configure --prefix=${OMPI_INSTALL_DIR} \
#         --disable-shared \
#         --enable-static \
#         --disable-dlopen \
#         --without-memory-manager \
#         --disable-vt && \
#    make -j ${NPROCS} LDFLAGS=-all-static && \
###
RUN export OMPI_VERSION=2.0.1 && \
    export OMPI_URL=https://www.open-mpi.org/software/ompi/v2.0/downloads/openmpi-${OMPI_VERSION}.tar.bz2 && \
    export OMPI_ARCHIVE=${PREFIX}/src/openmpi-${OMPI_VERSION}.tar.bz2 && \
    export OMPI_SOURCE_DIR=${PREFIX}/src/openmpi-${OMPI_VERSION} && \
    export OMPI_INSTALL_DIR=/usr/local && \
    mkdir -p ${OMPI_SOURCE_DIR} && \
    mkdir -p ${OMPI_INSTALL_DIR} && \
    wget --quiet ${OMPI_URL} --output-document=${OMPI_ARCHIVE} && \
    tar -jxf ${OMPI_ARCHIVE} -C ${OMPI_SOURCE_DIR} --strip-components=1 && \
    cd ${OMPI_SOURCE_DIR} && \
    ./configure \
        --enable-oshmem \
        --prefix=${OMPI_INSTALL_DIR} && \
    make -j ${NPROCS} && \
    make install && \
    rm -rf ${OMPI_ARCHIVE}

ENV PATH=/usr/local/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

# TODO: Should we also remove the OMPI_SOURCE_DIR ?


#### Done with base setup and install of pre-reqs,
#### to include our OpenMPI from src build.
#### Now ready for project/demo source checkouts and symlinks, etc.



# 1) Checkout Ed's oshmem version of Graph500 into "${PREFIX}/src"
#    (which will result in: /usr/local/src/graph500-shmem)
#    URL: https://code.ornl.gov/e6d/graph500_openshmem.git
#
# TJN: 19may2017 - Can not use GitAccessToken for CODE.ornl.gov,
#      so downloading repo and placing tarball and adding to files/ 
#      dir.  We will just extract tarball of git repo and continue.
#RUN cd ${PREFIX}/src/ && \
#    git clone https://code.ornl.gov/e6d/graph500_openshmem.git graph500-oshmem
#
# # N.1) Patch to fix pathing for MPI build in Graph500 code 
# 
RUN cd ${PREFIX}/src/ && \
    export G500_ARCHIVE=${PREFIX}/src/tar/graph500_openshmem-master-02f51b620873997c9160f0eae1fc961c0188d2d7.tar.bz2 && \
    export G500_SOURCE_DIR=${PREFIX}/src/graph500-oshmem && \
    mkdir -p ${G00_SOURCE_DIR} && \
    tar -jxf ${G500_ARCHIVE} -C ${G500_SOURCE_DIR} --strip-components=1 && \
    cp ${PREFIX}/src/config/make.inc ${G500_SOURCE_DIR}/make.inc && \
    cd ${PREFIX}/src/graph500-oshmem && \
    patch -p 1 < ${PREFIX}/src/config/graph500_openshmem-master_mpi_Makefile.diff 


#### Done getting all the source code/patching. 
#### Now need kick off the configure(s) and build(s)!
#### Note, we'll build at end to ensure we build all in proper order.

# TODO: Merge this RUN command with above download/extract RUN command
# Build Graph500
RUN cd ${PREFIX}/src/graph500-oshmem && \
    make make-edgelist && \
    make CC=oshcc make-edgelist-shmem && \
    make install

# TODO: Use a non-root user

CMD ["/benchmarks/runs/run-graph500.sh"]

