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
#   docker build -t="naughtont3/hobbes-dtk-demo" .
#   docker push naughtont3/hobbes-dtk-demo
#   docker run -d -P --name devel_ve naughtont3/hobbes-dtk-demo /bin/sleep infinity
#   docker exec -ti devel_ve /bin/bash
#   
###########################################################################
#
# NOTES:
# - 02feb2017: Change to public 'gups-shmem' repo from openshmem-org,
#    (https://github.com/openshmem-org/gups-shmem.git). 
# - 18jan2017: Initial creation based on previous Hobbes and other containers
#
###########################################################################

FROM ubuntu:14.04

MAINTAINER Thomas Naughton <naughtont@ornl.gov>

# Build-arg: NPROCS for parallel make
ARG NPROCS=4

# Build-arg: github token
# Note: Should be passed via '--build-arg'!!!
# (See: https://help.github.com/articles/creating-an-access-token-for-command-line-use/)
ARG GITHUB_TOKEN=thetoken

# Set PREFIX to a common Hobbes directory
ENV PREFIX=/usr/local
RUN mkdir -p "${PREFIX}" \
    && mkdir -p "${PREFIX}/src" \
    && mkdir -p "${PREFIX}/src/config"  

ADD runit.sh /runit.sh

#ENV container docker

# This will prevent questions from being asked during the install
ENV DEBIAN_FRONTEND noninteractive

# Get certs so HTTPS requests (e.g., git clone) works
RUN apt-get -y update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
    && apt-get clean

# Install various useful/prereq packages 
RUN apt-get -y update \
    && apt-get install -y --no-install-recommends \
        autoconf \
        automake \
        g++ \
        gcc \
        gfortran \
        git \
        libtool \
        m4 \
        make \
        patch \
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
    export OMPI_URL=http://www.open-mpi.org/software/ompi/v2.0/downloads/openmpi-${OMPI_VERSION}.tar.bz2 && \
    export OMPI_ARCHIVE=${PREFIX}/src/openmpi-${OMPI_VERSION}.tar.bz2 && \
    export OMPI_SOURCE_DIR=${PREFIX}/src/openmpi-${OMPI_VERSION} && \
    export OMPI_INSTALL_DIR=${PREFIX} && \
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



# 1) Checkout openshmem-org's GUPS benchmark into "${PREFIX}/src"
#    (which will result in: /usr/local/src/gups-shmem)
#    URL: https://github.com/openshmem-org/gups-shmem.git
RUN cd ${PREFIX}/src/ && \
    git clone https://github.com/openshmem-org/gups-shmem.git

#### Done getting all the source code/patching. 
#### Now need kick off the configure(s) and build(s)!
#### Note, we'll build at end to ensure we build all in proper order.

# Build GUPS
RUN cd ${PREFIX}/src/gups-shmem && \
    make && \
    cp gups /usr/local/bin

# TODO: Use a non-root user
#CMD ["oshrun", "--allow-run-as-root", "-np", "1", "${PREFIX}/bin/ra_shmem"]
CMD ["/runit.sh"]

