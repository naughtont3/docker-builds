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
#   docker build -t="naughtont3/ornl-oshmem" .
#   docker push naughtont3/ornl-oshmem
#   docker run -d -P --name devel_ve naughtont3/ornl-oshmem /bin/sleep infinity
#   docker exec -ti devel_ve /bin/bash
#
###########################################################################
#
# NOTES:
# - 28nov2017: Initial creation of 'ornl-oshmem' that uses base image
#              'ornl-oshmem-base' for most of the heavy lifting.
#              The base layer is public and on DockerHub.
#              This image ('ornl-oshmem') is private and *not* on DockerHub.
#
###########################################################################

FROM naughtont3/ornl-oshmem-base
MAINTAINER Thomas Naughton <naughtont@ornl.gov>

# Build-arg: NPROCS for parallel make
ARG NPROCS=4

# Build-arg: github token
# Note: Should be passed via '--build-arg'!!!
# (See: https://help.github.com/articles/creating-an-access-token-for-command-line-use/)
ARG GITHUB_TOKEN=thetoken

# Set VERSION of software
# Git source
ENV XX_ORNLOSHMEM_VERSION=git-br-ucx

# Set PREFIX to a common Hobbes directory
ENV PREFIX=/usr/local
RUN mkdir -p "${PREFIX}" \
    && mkdir -p "${PREFIX}/src" \
    && mkdir -p "${PREFIX}/src/tar" \
    && mkdir -p "${PREFIX}/src/config"\
    && mkdir -p "${PREFIX}/runs" \
    && mkdir -p "${PREFIX}/runs/Test1"


ADD files/build_ornloshm-develop.sh   ${PREFIX}/src/
ADD files/env_oshmem-develop.sh       ${PREFIX}/src/

# This will prevent questions from being asked during the install
ENV DEBIAN_FRONTEND noninteractive

# ORNL-OpenSHMEM (git)
RUN echo "BUILD ORNL-OpenSHMEM" && \
    if [ -z "$GITHUB_TOKEN" ] ; then \
       export ORNLOSHMEM_REPO_URL=https://github.com/ornl-languages/ornl-openshmem.git ; \
    else  \
       export ORNLOSHMEM_REPO_URL=https://${GITHUB_TOKEN}:x-oauth-basic@github.com/ornl-languages/ornl-openshmem.git ; \
    fi ; \
    export ORNLOSHMEM_REPO_BRANCH=ucx && \
    export ORNLOSHMEM_SOURCE_DIR=${PREFIX}/src/ornl-openshmem-${XX_ORNLOSHMEM_VERSION} && \
    export ORNLOSHMEM_INSTALL_DIR=${PREFIX}/ && \
    mkdir -p $ORNLOSHMEM_SOURCE_DIR && \
    cd $ORNLOSHMEM_SOURCE_DIR && \
    git clone -b ${ORNLOSHMEM_REPO_BRANCH} ${ORNLOSHMEM_REPO_URL} ${ORNLOSHMEM_SOURCE_DIR} && \
    cd ${ORNLOSHMEM_SOURCE_DIR} && \
    ./autogen.sh && \
    ./autogen.sh && \
    ./configure \
        --with-ucx-rte=pmix \
        --enable-experimental \
        --prefix=${ORNLOSHMEM_INSTALL_DIR} \
        CPPFLAGS=-I${ORNLOSHMEM_INSTALL_DIR}/include \
        LDFLAGS=-L${ORNLOSHMEM_INSTALL_DIR}/lib \
        && \
    make -j 4 && \
    make install || exit 1

ENV ORNLOSHMEM_SOURCE_DIR=${PREFIX}/src/ornl-openshmem-${XX_ORNLOSHMEM_VERSION}
ENV ORNLOSHMEM_INSTALL_DIR=${PREFIX}/

## Chown all the src code to 'oshuser'
#RUN chown -R oshuser ${PREFIX}/

# Default to non-root user ('oshuser')
# (Note: user is created in base image layer.)
USER oshuser


CMD ["/bin/bash"]

