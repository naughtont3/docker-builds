###########################################################################
#
# To rebuild image:
#   docker build -t="naughtont3/<IMAGENAME>" .
#   docker push naughtont3/<IMAGENAME>
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

# Set PREFIX to a common Hobbes directory
ENV PREFIX=/hobbes
RUN mkdir -p "${PREFIX}" \
    && mkdir -p "${PREFIX}/local"  \
    && mkdir -p "${PREFIX}/src" 

#ENV container docker

# This will prevent questions from being asked during the install
ENV DEBIAN_FRONTEND noninteractive

# Add a few helpful files into image
ADD build-ompi.sh "${PREFIX}/config/build-ompi.sh"



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
        wget \
        zlib1g-dev \
    && apt-get clean

 #
 # TODO - FINISHME
 #
# 1) Build ompi and install into "${PREFIX}/local"
#    (which will result in: /hobbes/local/ompi_install/{bin,lib,share,etc,man}/)

#### Done with base setup and install of pre-reqs,
#### to include our OpenMPI from src build.
#### Now ready for project/demo source checkouts and symlinks, etc.

# 1) Checkout Hobbes Demo git into "${PREFIX}/src"
#    (which will result in: /hobbes/src/hobbes_demo)
#    URL: https://github.com/ORNL/hobbes_demo.git

# 2) Checkout Hobbes modified ORNL-DTK git into "${PREFIX}/src"
#    (which will result in: /hobbes/src/DataTransferKit)
#    URL: https://github.com/ORNL/DataTransferKit.git

# 3) Checkout DTKData git into "${PREFIX}/src" 
#    (which will result in: /hobbes/src/DTKData)
#    and create symlink to it in "${PREFIX}/src/DataTransferKit"
#    URL: https://github.com/ORNL-CEES/DTKData.git

# 4) Checkout Trilinos git into "${PREFIX}/src"
#    (which will result in: /hobbes/src/Trilinos)
#    URL: https://github.com/trilinos/Trilinos.git
#    Create symlink to DTK:
#       - cd "${PREFIX}/src/Trilinos" && ln -s ../DataTransferKit)

# 5) Checkout Hobbes ORNL-xpmem git into "${PREFIX}/src"
#    (which will result in: /hobbes/src/xpmem)
#    URL: http://github.com/ORNL/xpmem.git

# 6) Checkout Hobbes petlib git into "${PREFIX}/src"
#    (which will result in: /hobbes/src/petlib)
#    URL: http://www.prognosticlab.org/git/petlib.git

# 7) Checkout Hobbes ORNL-Leviathan git into "${PREFIX}/src"
#    (which will result in: /hobbes/src/leviathan)
#    URL: https://github.com/ORNL/leviathan.git
#    Create symlinks to petlib and xpmem:
#       - cd "${PREFIX}/src/leviathan" && ln -s ../xpmem && ln -s ../petlib)


#### Whew, done getting all the source code and creating symlinks.
#### Now need to patch (mainly for paths) and kick off the build(s).
#### NOTE: I'm wondering at this point if it would be best to 
####       hack Kevin's "build.pl" for our purposes and call it from
####       our Dockerfile???

# *) Patch ORNL-DTK git to have our "${PREFIX}/src" ... pathing


 #
 # TODO: OLD - FINISHME FOR DTK/Trilinos
 #

# # install Hobbes NVL and build BusyBox Guest with MPI
# # Note: we clean any previous nvl dirs to make build idempotent
# # XXX NOTE: Using a 'hacked' version of build.pl!
# RUN export NVL_URL=http://github.com/HobbesOSR/nvl.git && \
#     export NVL_SOURCE_DIR=${PREFIX}/nvl && \
#     if [ "x${NVL_SOURCE_DIR}" != "x" ] && [ -e "${NVL_SOURCE_DIR}" ] ; then \
#        rm -rf ${NVL_SOURCE_DIR} ; fi \
#     && git clone ${NVL_URL} ${NVL_SOURCE_DIR} \
#     && cd ${NVL_SOURCE_DIR} \
#     && ${NVL_SOURCE_DIR}/scripts/full_devel_checkout.sh \
#     && if [ -f "${PREFIX}/build-hacked.pl" ] ; then \
#        cp -f "${PREFIX}/build-hacked.pl" "${NVL_SOURCE_DIR}/src/guests/simple_busybox" ; fi \
#     && if [ -f "${PREFIX}/passwd.cubswin" ] ; then \
#        cp -f "${PREFIX}/passwd.cubswin"  "${NVL_SOURCE_DIR}/src/guests/simple_busybox" ; fi \
#     && if [ -f "${PREFIX}/BUILDIT.sh" ] ; then \
#        cp -f "${PREFIX}/BUILDIT.sh" "${NVL_SOURCE_DIR}/src/guests/simple_busybox" ; fi \
#     && echo "TJN: STOPPING EARLY - WILL NEED TO RUN BUILD-HACKED.PL MANUALLY" \
#     && echo "TJN: SEE BUILDIT.sh wrapper script for example." \
#     && echo "TJN: SEE ${NVL_SOURCE_DIR}/src/guests/simple_busybox"


