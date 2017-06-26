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
#   docker build -t="naughtont3/omb-oshmem" .
#   docker push naughtont3/omb-oshmem
#   docker run -d -P --name devel_ve naughtont3/omb-oshmem /bin/sleep infinity
#   docker exec -ti devel_ve /bin/bash
#   
###########################################################################
#
# NOTES:
# - 06jun2017: Revised to use Ubuntu:17.04 and included binary openmpi pkgs,
#    which have OSHMEM enabled in the build 
# - 24may2017: Revisions to fix build problems and bump to OMPI v2.1.1
# - 19may2017: Initial creation based on running container template,
#    using public 'graph500_openshmem' repo from Ed D'Azevedo.
#    (https://code.ornl.gov/e6d/graph500_openshmem)
#
###########################################################################

FROM ubuntu:17.04
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

# TODO
#ADD files/run-omb.sh ${PREFIX}/runs/run-omb.sh

###
# XXX: Using 'COPY' command to add tarbal.
#      NOTE The Docker 'ADD' command will automagically extract tarballs!
#      e.g., adding 'NPB3.3.1.tar.gz' to "$prefix/src" 
#      creates "$prefix/src/NPB3.3.1/"
#      Ah-Ha!  Docker 'COPY' does *not* do all the magic of 'ADD'!
#
# XXX: TJN - need to avoid adding this directly to repo.
#      For now I keep entry in Dockerfile, but not add 
#      the actual tarball to Git.
###
COPY files/osu-micro-benchmarks-5.3.2.tar.gz ${PREFIX}/src/tar/osu-micro-benchmarks-5.3.2.tar.gz

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
    && apt-get clean

# Install OpenMPI
RUN apt-get -y update \
    && apt-get install -y --no-install-recommends \
        libopenmpi-dev \
        openmpi-bin \
        openmpi-common \
    && apt-get clean


# #
# # *) Build/Install OpenMPI 
# #    (which will result in: /usr/local/{bin,lib,...}/)
# #
# #  NOTE: Use '--strip-components=1' to avoid tarball dirname in dest dir,
# #        e.g., no "openmpi-1.10.2/" in dest dir, just contents into dest dir.
# #        (Instead we control source code dir name explicitly, in case we
# #        want something different in the src dirname.)
# #
# ###
# # OLDER-STUFF...
# #    LDFLAGS=-static ./configure --prefix=${OMPI_INSTALL_DIR} \
# #         --disable-shared \
# #         --enable-static \
# #         --disable-dlopen \
# #         --without-memory-manager \
# #         --disable-vt && \
# #    make -j ${NPROCS} LDFLAGS=-all-static && \
# ###
# RUN export OMPI_VERSION=2.1.1 && \
#     export OMPI_URL=http://www.open-mpi.org/software/ompi/v2.1/downloads/openmpi-${OMPI_VERSION}.tar.bz2 && \
#     export OMPI_ARCHIVE=${PREFIX}/src/openmpi-${OMPI_VERSION}.tar.bz2 && \
#     export OMPI_SOURCE_DIR=${PREFIX}/src/openmpi-${OMPI_VERSION} && \
#     export OMPI_INSTALL_DIR=/usr/local && \
#     mkdir -p ${OMPI_SOURCE_DIR} && \
#     mkdir -p ${OMPI_INSTALL_DIR} && \
#     echo "DBG: wget --quiet ${OMPI_URL} --output-document=${OMPI_ARCHIVE}" && \
#     wget --quiet ${OMPI_URL} --output-document=${OMPI_ARCHIVE} && \
#     ls -lh ${OMPI_ARCHIVE} && \
#     tar -jxf ${OMPI_ARCHIVE} -C ${OMPI_SOURCE_DIR} --strip-components=1 && \
#     cd ${OMPI_SOURCE_DIR} && \
#     ./configure \
#         --enable-oshmem \
#         --prefix=${OMPI_INSTALL_DIR} && \
#     make -j ${NPROCS} && \
#     make install && \
#     rm -rf ${OMPI_ARCHIVE}
# 
# ENV PATH=/usr/local/bin:$PATH
# ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
# 
# # TODO: Should we also remove the OMPI_SOURCE_DIR ?


#### Done with base setup and install of pre-reqs,
#### to include our OpenMPI from src build.
#### Now ready for project/demo source checkouts and symlinks, etc.

###
# TJN: ssh-keygen of /etc/ssh/ssh_host_ecdsa_key may exist, so just ';' not '&&' cmds
RUN useradd -c "MPI User" -m -p 'dabears' -s /bin/bash mpiuser  \
    && su -c "echo 'export LD_LIBRARY_PATH=/usr/lib64/openmpi/lib:\$LD_LIBRARY_PATH' >> ~/.bashrc" mpiuser  \
    && su -c "echo 'export PATH=/usr/lib64/openmpi/bin/:\$PATH' >> ~/.bashrc" mpiuser \
    && su -c "/usr/bin/ssh-keygen -t ecdsa -f ~/.ssh/id_ecdsa -q -N ''" mpiuser \
    && su -c "cat ~/.ssh/id_ecdsa.pub  >> ~/.ssh/authorized_keys" mpiuser \
    && ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -q -N "" \
     ; su -c "echo -n '* ' > ~/.ssh/known_hosts \
    && cat /etc/ssh/ssh_host_ecdsa_key.pub >> ~/.ssh/known_hosts" mpiuser
###

# Chown all the src code to 'mpiuser'
RUN chown -R mpiuser ${PREFIX}/

# Default to non-root user ('mpiuser')
USER mpiuser

# Build OSU Micro Benchmark for OpenSHMEM
RUN cd ${PREFIX}/src/ && \
    export OMB_ARCHIVE=${PREFIX}/src/tar/osu-micro-benchmarks-5.3.2.tar.gz && \
    export OMB_SOURCE_DIR=${PREFIX}/src/omb && \
    mkdir -p ${OMB_SOURCE_DIR} && \
    mkdir -p ${PREFIX}/src/omb-install && \
    tar -jxf ${OMB_ARCHIVE} -C ${OMB_SOURCE_DIR} --strip-components=1 && \
    cd ${PREFIX}/src/omb && \
    ./configure --prefix=${PREFIX}/src/omb-install CC=oshcc && \
    make -C openshmem CC=oshcc  && \
    make -C openshmem CC=oshcc  install 

ENV PATH=${PREFIX}/src/omb-install/libexec/osu-micro-benchmarks:$PATH

#### Done getting all the source code/patching. 
#### Now need kick off the configure(s) and build(s)!
#### Note, we'll build at end to ensure we build all in proper order.


# TODO: Use a non-root user

CMD ["/benchmarks/runs/run-omb.sh"]

