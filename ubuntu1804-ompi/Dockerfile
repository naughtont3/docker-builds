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
# - 18jan2017: Initial creation based on previous Hobbes and other containers
#
###########################################################################

FROM ubuntu:18.04

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

#ADD patches/FILENAME.diff ${PREFIX}/src/config/FILENAME.diff

#ENV container docker

# This will prevent questions from being asked during the install
ENV DEBIAN_FRONTEND noninteractive

# TODO: Create new non-root user to own/run MPI/OpenSHMEM

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


#    export OMPI_URL=https://www.open-mpi.org/software/ompi/v2.0/downloads/openmpi-${OMPI_VERSION}.tar.bz2 && \

#
#
# *) Build/Install OpenMPI 
#    (which will result in: /usr/local/{bin,lib,...}/)
#
#  NOTE: Use '--strip-components=1' to avoid tarball dirname in dest dir,
#        e.g., no "openmpi-1.10.2/" in dest dir, just contents into dest dir.
#        (Instead we control source code dir name explicitly, in case we
#        want something different in the src dirname.)
#
#----
# MISC-SNIPPETS:
#  patch -p 1 < ${PREFIX}/src/config/FILENAME.diff && \
#----
###
RUN export OMPI_VERSION=4.0.2 && \
    export OMPI_SERIES=v4.0 && \
    export OMPI_URL=https://download.open-mpi.org/release/open-mpi/${OMPI_SERIES}/openmpi-${OMPI_VERSION}.tar.bz2 && \
    export OMPI_ARCHIVE=${PREFIX}/src/openmpi-${OMPI_VERSION}.tar.bz2 && \
    export OMPI_SOURCE_DIR=${PREFIX}/src/openmpi-${OMPI_VERSION} && \
    export OMPI_INSTALL_DIR=${PREFIX} && \
    mkdir -p ${OMPI_SOURCE_DIR} && \
    mkdir -p ${OMPI_INSTALL_DIR} && \
    wget --quiet ${OMPI_URL} --output-document=${OMPI_ARCHIVE} && \
    tar -jxf ${OMPI_ARCHIVE} -C ${OMPI_SOURCE_DIR} --strip-components=1 && \
    cd ${OMPI_SOURCE_DIR} && \
    ./configure \
        --prefix=${OMPI_INSTALL_DIR} && \
    make -j ${NPROCS} && \
    make install && \
    rm -rf ${OMPI_ARCHIVE}

ENV PATH=/usr/local/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

# TODO: Should we also remove the OMPI_SOURCE_DIR ?

CMD ["/bin/bash"]

