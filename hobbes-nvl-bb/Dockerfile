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
#   docker build -t="naughtont3/hobbes-nvl-bb" .
#   docker push naughtont3/hobbes-nvl-bb
#   docker run -d -P --name devel_ve naughtont3/hobbes-nvl-bb /bin/sleep infinity
#   docker exec -ti devel_ve /bin/bash
#   
###########################################################################
#
# NOTES:
# - 12may2016: Using a 'hacked' version of Kevin's build.pl script to work
#     around some assumptions for basic guest build.  Also switching back
#     to Ubuntu-14.04.  Adding customized passwd file to image 
#     (see passwd.cubswin).  In dockerfile we stage at root of
#     simple_busybox build dir, and build-hacked.pl recognizes the existence
#     of that filename and copies into guest image (see hacks 
#     in '--build-image' block of script).
# - 22apr2016: Thanks to Damien Lebrun-Grandie for sharing his Dockerfiles! 
# - 22apr2016: Based on build instructions from Kevin Pedretti for 
#   using 'build.pl' script to build a busybox guest.
#   Summary of his steps: 
#     1) Git checkout and build of base stuff with build.pl script
#         cd nvl/src/guests/simple_busybox/ ; build.pl ...
#     2) Build VM image  
#         ./build.pl --build-image && ./build.pl --build-isoimage
#     3) Launch 'image.iso' from Step#2
#         qemu-system-x86_64 -cdrom ./image.iso -m 2048 -smp 4 -serial stdio
###########################################################################

FROM naughtont3/ubuntu1404devel

MAINTAINER Thomas Naughton <naughtont@ornl.gov>

# Set PREFIX to a common Hobbes directory
ENV PREFIX=/hobbes
CMD ["mkdir","-p","${PREFIX}"]

#ENV container docker

# This will prevent questions from being asked during the install
ENV DEBIAN_FRONTEND noninteractive

# XXX: NOTE: Using a 'hacked' version of build.pl!
ADD build-hacked.pl  "${PREFIX}/build-hacked.pl"
ADD BUILDIT.sh       "${PREFIX}/BUILDIT.sh"

# Add a few othe helpful files into image
ADD passwd.cubswin   "${PREFIX}/passwd.cubswin"
ADD qemuboot-iso.sh  "${PREFIX}/qemuboot-iso.sh"

# Get certs so HTTPS requests (e.g., git clone's) work.
RUN apt-get -y update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
    && apt-get clean

# Install various useful/prereq packages 
RUN apt-get -y update \
    && apt-get install -y --no-install-recommends \
        git \
        libibverbs1 \
        wget \
        zlib1g-dev \
    && apt-get clean


# install Hobbes NVL and build BusyBox Guest with MPI
# Note: we clean any previous nvl dirs to make build idempotent
# XXX NOTE: Using a 'hacked' version of build.pl!
RUN export NVL_URL=http://github.com/HobbesOSR/nvl.git && \
    export NVL_SOURCE_DIR=${PREFIX}/nvl && \
    if [ "x${NVL_SOURCE_DIR}" != "x" ] && [ -e "${NVL_SOURCE_DIR}" ] ; then \
       rm -rf ${NVL_SOURCE_DIR} ; fi \
    && git clone ${NVL_URL} ${NVL_SOURCE_DIR} \
    && cd ${NVL_SOURCE_DIR} \
    && ${NVL_SOURCE_DIR}/scripts/full_devel_checkout.sh \
    && if [ -f "${PREFIX}/build-hacked.pl" ] ; then \
       cp -f "${PREFIX}/build-hacked.pl" "${NVL_SOURCE_DIR}/src/guests/simple_busybox" ; fi \
    && if [ -f "${PREFIX}/passwd.cubswin" ] ; then \
       cp -f "${PREFIX}/passwd.cubswin"  "${NVL_SOURCE_DIR}/src/guests/simple_busybox" ; fi \
    && if [ -f "${PREFIX}/BUILDIT.sh" ] ; then \
       cp -f "${PREFIX}/BUILDIT.sh" "${NVL_SOURCE_DIR}/src/guests/simple_busybox" ; fi \
    && echo "TJN: STOPPING EARLY - WILL NEED TO RUN BUILD-HACKED.PL MANUALLY" \
    && echo "TJN: SEE BUILDIT.sh wrapper script for example." \
    && echo "TJN: SEE ${NVL_SOURCE_DIR}/src/guests/simple_busybox"
#
# FIXME: TJN Leaving off build steps b/c things are failing to download, etc.
#            Will just need to run the following manually in the
#            container.  :-(
# 
#     && ./build-hacked.pl --build-kernel \
#     && ./build-hacked.pl --build-busybox \
#     && ./build-hacked.pl --build-dropbear \
#     && ./build-hacked.pl --build-libhugetlbfs \
#     && ./build-hacked.pl --build-numactl \
#     && ./build-hacked.pl --build-hwloc \
#     && ./build-hacked.pl --build-ompi \
#     && ./build-hacked.pl --build-curl \
#     && ./build-hacked.pl --build-image \
#     && ./build-hacked.pl --build-isoimage
#     && cp image-nvl-bb.iso ${PREFIX}
# 
# XXX: Leaving out 'pisces' for now
#    && ./build-hacked.pl --build-pisces \

# # Copy VM ISO image (with descriptive name) to PREFIX dir 
# RUN cp ${NVL_SOURCE_DIR}/nvl/src/guests/simple_busybox/image.iso \
#        ${PREFIX}/image-nvl-bb.iso
# 
