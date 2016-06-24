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
# - 23jun2016: Create docker specifically for DTK demo (based on hobbes-nvl-bb).
#
###########################################################################

FROM naughtont3/ubuntu1404devel

MAINTAINER Thomas Naughton <naughtont@ornl.gov>

# Build-arg: NPROCS for parallel make
ARG NPROCS=4

# Build-arg: github token
# Note: Should be passed via '--build-arg'!!!
# (See: https://help.github.com/articles/creating-an-access-token-for-command-line-use/)
ARG GITHUB_TOKEN=thetoken

# Set PREFIX to a common Hobbes directory
ENV PREFIX=/hobbes
RUN mkdir -p "${PREFIX}" \
    && mkdir -p "${PREFIX}/local"  \
    && mkdir -p "${PREFIX}/src" 

#ENV container docker

# This will prevent questions from being asked during the install
ENV DEBIAN_FRONTEND noninteractive

# Add a few helpful files into image
#ADD build-ompi.sh ${PREFIX}/config/build-ompi.sh

# TJN: (23jun2016) Patch for ORNL-DTK cmakefile paths
ADD dtk_packages_adapters_podc_test_cmakelist.diff  \
    ${PREFIX}/config/dtk_packages_adapters_podc_test_cmakelist.diff

# TJN: (24jun2016) Patch for ORNL-Hobbes_demo_v1.0 build.sh paths
ADD hobbes_demov1.0_buildsh.diff \
    ${PREFIX}/config/hobbes_demov1.0_buildsh.diff


# Get certs so HTTPS requests (e.g., git clone) works
RUN apt-get -y update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
    && apt-get clean

# Install various useful/prereq packages 
RUN apt-get -y update \
    && apt-get install -y --no-install-recommends \
        git \
        libblas3 \
        libblas-dev \
        libboost-all-dev \
        libibverbs1 \
        liblapack3 \
        liblapack-dev \
        patch \
        wget \
        zlib1g-dev \
    && apt-get clean




#
# *) Build OpenMPI and install into "${PREFIX}/local"
#    (which will result in: /hobbes/local/ompi_install/)
#
#  NOTE: Use '--strip-components=1' to avoid tarball dirname in dest dir,
#        e.g., no "openmpi-1.10.2/" in dest dir, just contents into dest dir.
#
RUN export OMPI_VERSION=1.10.2 && \
    export OMPI_URL=http://www.open-mpi.org/software/ompi/v1.10/downloads/openmpi-${OMPI_VERSION}.tar.bz2 && \
    export OMPI_ARCHIVE=${PREFIX}/src/ompi/openmpi-${OMPI_VERSION}.tar.bz2 && \
    export OMPI_SOURCE_DIR=${PREFIX}/src/ompi/source && \
    export OMPI_INSTALL_DIR=${PREFIX}/local/ompi_install && \
    mkdir -p ${OMPI_SOURCE_DIR} && \
    mkdir -p ${OMPI_INSTALL_DIR} && \
    wget --quiet ${OMPI_URL} --output-document=${OMPI_ARCHIVE} && \
    tar -jxf ${OMPI_ARCHIVE} -C ${OMPI_SOURCE_DIR} --strip-components=1 && \
    cd ${OMPI_SOURCE_DIR} && \
    LDFLAGS=-static ./configure --prefix=${OMPI_INSTALL_DIR} \
        --disable-shared \
        --enable-static \
        --disable-dlopen \
        --without-memory-manager \
        --disable-vt && \
    make -j ${NPROCS} LDFLAGS=-all-static && \
    make install && \
    rm -rf ${OMPI_ARCHIVE}



#### Done with base setup and install of pre-reqs,
#### to include our OpenMPI from src build.
#### Now ready for project/demo source checkouts and symlinks, etc.



# 1) Checkout Hobbes Demo git into "${PREFIX}/src"
#    (which will result in: /hobbes/src/hobbes_demo)
#    URL: https://github.com/ORNL/hobbes_demo.git
RUN cd ${PREFIX}/src/ && \
    git clone https://${GITHUB_TOKEN}:x-oauth-basic@github.com/ORNL/hobbes_demo.git
    #git clone https://github.com/ORNL/hobbes_demo.git

# 1.1) Patch Hobbes Demo demo_v1.0 git to have our expected paths
RUN cd ${PREFIX}/src/hobbes_demo && \
    patch -p 1 < ${PREFIX}/config/hobbes_demov1.0_buildsh.diff

# 2) Checkout DTKData git into "${PREFIX}/src" 
#    (which will result in: /hobbes/src/DTKData)
#    URL: https://github.com/ORNL-CEES/DTKData.git
RUN cd ${PREFIX}/src/ && \
    git clone https://github.com/ORNL-CEES/DTKData.git

# 3) Checkout Hobbes modified ORNL-DTK git into "${PREFIX}/src"
#    (which will result in: /hobbes/src/DataTransferKit)
#    ALSO - Create symlink to DTKData
#    URL: https://github.com/ORNL/DataTransferKit.git
RUN cd ${PREFIX}/src/ && \
    git clone https://${GITHUB_TOKEN}:x-oauth-basic@github.com/ORNL/DataTransferKit.git && \
    #git clone https://github.com/ORNL/DataTransferKit.git  && \
    cd ${PREFIX}/src/DataTransferKit/ && \
    ln -s ../DTKData 

# 3.1) Patch ORNL-DTK git to have our expected paths
RUN cd ${PREFIX}/src/DataTransferKit && \
    patch -p 1 < ${PREFIX}/config/dtk_packages_adapters_podc_test_cmakelist.diff 

# 4) Checkout Trilinos git into "${PREFIX}/src"
#    (which will result in: /hobbes/src/Trilinos)
#    URL: https://github.com/trilinos/Trilinos.git
#    ALSO - Create symlink to DTK
RUN cd ${PREFIX}/src/ && \
    git clone https://github.com/trilinos/Trilinos.git && \
    cd ${PREFIX}/src/Trilinos/ && \
    ln -s ../DataTransferKit

# 5) Checkout Hobbes ORNL-xpmem git into "${PREFIX}/src"
#    (which will result in: /hobbes/src/xpmem)
#    URL: http://github.com/ORNL/xpmem.git
RUN cd ${PREFIX}/src/ && \
    git clone http://${GITHUB_TOKEN}:x-oauth-basic@github.com/ORNL/xpmem.git
    #git clone http://github.com/ORNL/xpmem.git

# 6) Checkout Hobbes petlib git into "${PREFIX}/src"
#    (which will result in: /hobbes/src/petlib)
#    URL: http://www.prognosticlab.org/git/petlib.git
RUN cd ${PREFIX}/src/ && \
    git clone http://www.prognosticlab.org/git/petlib.git

# 7) Checkout Hobbes ORNL-Leviathan git into "${PREFIX}/src"
#    (which will result in: /hobbes/src/leviathan)
#    URL: https://github.com/ORNL/leviathan.git
#    ALSO - Create symlink to petlib and xpmem
RUN cd ${PREFIX}/src/ && \
    git clone https://${GITHUB_TOKEN}:x-oauth-basic@github.com/ORNL/leviathan.git && \
    #git clone https://github.com/ORNL/leviathan.git && \
    cd ${PREFIX}/src/leviathan/ && \
    ln -s ../xpmem && \
    ln -s ../petlib

#### Whew, done getting all the source code and creating symlinks.
#### Now need kick off the configure(s) and build(s)!
#### Note, we'll build at end to ensure we build all in proper order.

# Build petlib
RUN cd ${PREFIX}/src/petlib && \
    make

# Build xpmem  (library)
RUN cd ${PREFIX}/src/xpmem/lib && \
    make && \

# Build xpmem  (module)
# (note: we will keep module seperate and likely load in host 
#  for the 'insmod xpmem.ko'.  But if we mapped kernel source into
#  the container, we'll attempt to build the kernel module.)
RUN if [ -d "/usr/src/linux-headers-$(uname -r)" ] ; then \
        if [ -d "/lib/modules/$(uname -r)" ] ; then \
          echo "INFO: Kernel src/modules exist, build 'xpmem.ko'!" ; \
          cd ${PREFIX}/src/xpmem/mod ; \
          make ; \
        fi ; \
    fi 

# Build whitedb and libhobbes
RUN cd ${PREFIX}/src/leviathan && \
    cd whitedb-0.7.3/ && \
    ./autogen.sh && ./configure && make && \
    cd ${PREFIX}/src/leviathan/libhobbes/ && \
    make 

# Build just the Hobbes demo_v0.1 code (mainly for testing/debug)
RUN cd ${PREFIX}/src/hobbes_demo/demo_v0.1 && \
    ./autogen.sh && \
    ./configure \
        --with-petlib=../../petlib \
        --with-xpmem=../../xpmem \
        --with-leviathan=../../leviathan && \
    make

###
# XXX: TJN - Not sure this is "best" way to build DTK/Hobbes-demos
#      but we can change it later as appropriate.
###
# Build DTK/Trilinos and Hobbes demo_v1.0
RUN cd ${PREFIX}/src/hobbes_demo/demo_v1.0/config_demo_1.0/ && \
    ./build.sh  && \
    echo "NOTE: Hobbes-demo-v1.0 under ${PREFIX}/src/hobbes_demo/demo_v1.0/"

