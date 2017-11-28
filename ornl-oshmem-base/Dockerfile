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
# Examples:
#   docker build -t="naughtont3/ornl-oshmem-base" .
#   docker push naughtont3/ornl-oshmem-base
#   docker run -d -P --name devel_ve naughtont3/ornl-oshmem-base /bin/sleep infinity
#   docker exec -ti devel_ve /bin/bash
#
###########################################################################
#
# NOTES:
# - 28nov2017: Comment out the XPMEM/UCX pieces due to kernel deps, run via
#              'finish_build.sh' script instead (from within a container instance).
# - 23nov2017: Initial creation based on existing container templates.
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

# Set VERSION of software
# Tarball source
ENV XX_LIBEVENT_VERSION=2.1.8-stable
ENV XX_PMIX_VERSION=2.0.2
ENV XX_OMPI_VERSION=3.0.0
# Git source
ENV XX_XPMEM_VERSION=git-br-master
ENV XX_UCX_VERSION=git-br-master


# Set PREFIX to a common Hobbes directory
ENV PREFIX=/usr/local
RUN mkdir -p "${PREFIX}" \
    && mkdir -p "${PREFIX}/src" \
    && mkdir -p "${PREFIX}/src/tar" \
    && mkdir -p "${PREFIX}/src/config"\
    && mkdir -p "${PREFIX}/runs" \
    && mkdir -p "${PREFIX}/runs/Test1"


ADD files/build_ornloshm-develop.sh   ${PREFIX}/src/
ADD files/finish_build.sh             ${PREFIX}/src/
ADD files/env_oshmem-develop.sh       ${PREFIX}/src/

# ###
# # XXX: Using 'COPY' command to add tarbal.
# #      Docker 'COPY' does *not* do all the magic of 'ADD'!
# ###
# #COPY files/graph500-2.1.4.tar.bz2 ${PREFIX}/src/tar/graph500-2.1.4.tar.bz2

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

####
# TODO:
#   - libibverbs-dev (verbs.h)
####
# Install various useful/prereq packages
RUN apt-get -y update \
    && apt-get install -y --no-install-recommends \
        autoconf \
        automake \
        bash \
		bc \
        binutils-dev \
        binutils-multiarch-dev \
        bison \
		bzip2 \
        flex \
        g++ \
        gcc \
        gfortran \
        git \
        iputils-ping \
        libelf-dev \
        libnuma-dev \
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

# Libevent (tar.gz)
RUN echo "BUILD LIBEVENT" && \
    export LIBEVENT_ARCHIVE_URL=https://github.com/libevent/libevent/releases/download/release-${XX_LIBEVENT_VERSION}/libevent-${XX_LIBEVENT_VERSION}.tar.gz && \
    export LIBEVENT_SOURCE_DIR=${PREFIX}/src/libevent-${XX_LIBEVENT_VERSION} && \
    export LIBEVENT_INSTALL_DIR=${PREFIX}/ && \
    export LIBEVENT_ARCHIVE_FILE=`echo "${LIBEVENT_ARCHIVE_URL##*/}"` && \
    mkdir -p $LIBEVENT_SOURCE_DIR && \
    cd $LIBEVENT_SOURCE_DIR && \
    wget --quiet $LIBEVENT_ARCHIVE_URL && \
    tar -zxf ${LIBEVENT_ARCHIVE_FILE} -C ${LIBEVENT_SOURCE_DIR} --strip-components=1 && \
    cd ${LIBEVENT_SOURCE_DIR} && \
    ./configure \
        --prefix=${LIBEVENT_INSTALL_DIR} \
        && \
    make -j 4 && \
    make install || exit 1

ENV LIBEVENT_SOURCE_DIR=${PREFIX}/src/libevent-${XX_LIBEVENT_VERSION}
ENV LIBEVENT_INSTALL_DIR=${PREFIX}/


# PMIX (tar.gz)
RUN echo "BUILD PMIX" && \
    export PMIX_ARCHIVE_URL=https://github.com/pmix/pmix/releases/download/v${XX_PMIX_VERSION}/pmix-${XX_PMIX_VERSION}.tar.gz && \
    export PMIX_SOURCE_DIR=${PREFIX}/src/pmix-${XX_PMIX_VERSION} && \
    export PMIX_INSTALL_DIR=${PREFIX}/ && \
    export PMIX_ARCHIVE_FILE=`echo "${PMIX_ARCHIVE_URL##*/}"` && \
    mkdir -p $PMIX_SOURCE_DIR && \
    cd $PMIX_SOURCE_DIR && \
    wget --quiet $PMIX_ARCHIVE_URL && \
    tar -zxf ${PMIX_ARCHIVE_FILE} -C ${PMIX_SOURCE_DIR} --strip-components=1 && \
    cd ${PMIX_SOURCE_DIR} && \
    ./autogen.pl && \
    ./configure \
        --prefix=${PMIX_INSTALL_DIR} \
        --with-libevent=${LIBEVENT_INSTALL_DIR} \
        && \
    make -j 4 && \
    make install || exit 1

ENV PMIX_SOURCE_DIR=${PREFIX}/src/pmix-${XX_PMIX_VERSION}
ENV PMIX_INSTALL_DIR=${PREFIX}/


# OpenMPI (ORTE) (tar.gz)
RUN echo "BUILD OMPI" && \
    export OMPI_ARCHIVE_URL=https://github.com/open-mpi/ompi/archive/v${XX_OMPI_VERSION}.tar.gz && \
    export OMPI_SOURCE_DIR=${PREFIX}/src/ompi-${XX_OMPI_VERSION} && \
    export OMPI_INSTALL_DIR=${PREFIX}/ && \
    export OMPI_ARCHIVE_FILE=`echo "${OMPI_ARCHIVE_URL##*/}"` && \
    mkdir -p $OMPI_SOURCE_DIR && \
    cd $OMPI_SOURCE_DIR && \
    wget --quiet $OMPI_ARCHIVE_URL && \
    tar -zxf ${OMPI_ARCHIVE_FILE} -C ${OMPI_SOURCE_DIR} --strip-components=1 && \
    cd ${OMPI_SOURCE_DIR} && \
    ./autogen.pl --no-ompi -no-oshmem && \
    ./configure \
        --prefix=${OMPI_INSTALL_DIR} \
        --with-pmix=${PMIX_INSTALL_DIR} \
        --with-libevent=${LIBEVENT_INSTALL_DIR} \
        && \
    make -j 4 && \
    make install || die "OMPI failed"

ENV OMPI_SOURCE_DIR=${PREFIX}/src/ompi-${XX_OMPI_VERSION}
ENV OMPI_INSTALL_DIR=${PREFIX}/

# 
# #####
# # Build xpmem  (module)
# # (note: we will keep module seperate and likely load in host
# #  for the 'insmod xpmem.ko'.  But if we mapped kernel source into
# #  the container, we'll attempt to build the kernel module.)
# RUN if [ -d "/usr/src/linux-headers-$(uname -r)" ] ; then \
#         if [ -d "/lib/modules/$(uname -r)" ] ; then \
#           echo "INFO: Kernel src/modules exist, build 'xpmem.ko'!" ; \
#           cd ${PREFIX}/src/xpmem/mod ; \
#           make ; \
#         fi ; \
#     fi
# #####
# 
# ####
# # TJN: If make fails we error out, but we ignore errors from 'make install'
# #      because that may be because we are not running as root (in some cases).
# # 
# # TODO: MAP IN THE HOST /usr/src/linux-headers-$(uname -r)
# ####
# # XPMEM (git)
# RUN echo "BUILD XPMEM" && \
#     export XPMEM_REPO_URL=https://github.com/hjelmn/xpmem && \
#     export XPMEM_REPO_BRANCH=master && \
#     export XPMEM_SOURCE_DIR=${PREFIX}/src/xpmem-${XX_XPMEM_VERSION} && \
#     export XPMEM_INSTALL_DIR=${PREFIX}/ && \
#     mkdir -p $XPMEM_SOURCE_DIR && \
#     cd $XPMEM_SOURCE_DIR && \
#     git clone -b ${XPMEM_REPO_BRANCH} ${XPMEM_REPO_URL} ${XPMEM_SOURCE_DIR} && \
#     cd ${XPMEM_SOURCE_DIR} && \
#     ./autogen.sh && \
#     ./configure \
#         --prefix=${XPMEM_INSTALL_DIR}  \
#         --with-default-prefix=${XPMEM_INSTALL_DIR} \
#         --with-module=/usr/src/linux-headers-$(uname -r) \
#         && \
#     make -j 4 \
#      || exit 1  \
#      && make install || echo "XPMEM make install problem (continue anyway)"
# 
# ENV XPMEM_SOURCE_DIR=${PREFIX}/src/xpmem-${XX_XPMEM_VERSION}
# ENV XPMEM_INSTALL_DIR=${PREFIX}
# 
# 
# 
# # TJN: NOTE I am using the '--with-rdmacm=no' option for now to disable IB
# # UCX
# RUN echo "BUILD UCX" && \
#     export UCX_REPO_URL=https://github.com/openucx/ucx.git && \
#     export UCX_REPO_BRANCH=master && \
#     export UCX_SOURCE_DIR=${PREFIX}/src/ucx-${XX_UCX_VERSION} && \
#     export UCX_INSTALL_DIR=${PREFIX}/ && \
#     mkdir -p $UCX_SOURCE_DIR && \
#     cd $UCX_SOURCE_DIR && \
#     git clone -b ${UCX_REPO_BRANCH} ${UCX_REPO_URL} ${UCX_SOURCE_DIR} && \
#     cd ${UCX_SOURCE_DIR} && \
#     ./autogen.sh && \
#     ./configure \
#  --with-rdmacm=no \
#         --with-xpmem=${XPMEM_INSTALL_DIR} \
#         --prefix=${UCX_INSTALL_DIR} \
#         && \
#     make -j 4 && \
#     make install || exit 1
# 
# ENV UCX_SOURCE_DIR=${PREFIX}/src/ucx-${XX_UCX_VERSION}
# ENV UCX_INSTALL_DIR=${PREFIX}
# 

RUN echo "*******************************************************" \
    && echo "DONE" \
    && echo "TODO: '/usr/local/src/finish_build.sh' from container" \
    && echo "TODO: Remember to bind mount in kernel header: " \
    && echo "       docker run -ti -v /usr/src:/usr/src ...." \
    && echo "*******************************************************" 


# # TJN: ssh-keygen of /etc/ssh/ssh_host_ecdsa_key may exist, so just ';' not '&&' cmds
# RUN useradd -c "MPI User" -m -p 'dabears' -s /bin/bash mpiuser  \
#     && su -c "echo 'export LD_LIBRARY_PATH=/usr/local/lib64/openmpi/lib:\$LD_LIBRARY_PATH' >> ~/.bashrc" mpiuser  \
#     && su -c "echo 'export PATH=/usr/local/lib64/openmpi/bin/:\$PATH' >> ~/.bashrc" mpiuser \
#     && su -c "/usr/bin/ssh-keygen -t ecdsa -f ~/.ssh/id_ecdsa -q -N ''" mpiuser \
#     && su -c "cat ~/.ssh/id_ecdsa.pub  >> ~/.ssh/authorized_keys" mpiuser \
#     && ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -q -N "" \
#      ; su -c "echo -n '* ' > ~/.ssh/known_hosts \
#     && cat /etc/ssh/ssh_host_ecdsa_key.pub >> ~/.ssh/known_hosts" mpiuser
# ###
# #
# # Chown all the src code to 'mpiuser'
# RUN chown -R mpiuser ${PREFIX}/
# #
# # Default to non-root user ('mpiuser')
# USER mpiuser


CMD ["/bin/bash"]

