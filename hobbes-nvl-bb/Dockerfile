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

FROM naughtont3/ubuntu1510devel

MAINTAINER Thomas Naughton <naughtont@ornl.gov>

ENV PREFIX=/hobbes
CMD ["mkdir","-p","${PREFIX}"]

RUN apt-get -y update \
    && apt-get install -y --no-install-recommends \
        git \
        libibverbs1 \
        wget \
        zlib1g-dev \
    && apt-get clean

# install Hobbes NVL and build BusyBox Guest with MPI
RUN export NVL_URL=http://github.com/HobbesOSR/nvl.git \
    && export NVL_SOURCE_DIR=${PREFIX}/nvl \
    && git clone ${NVL_URL} ${NVL_SOURCE_DIR} \
    && ${NVL_SOURCE_DIR}/scripts/full_devel_checkout.sh \
    && cd ${NVL_SOURCE_DIR}/nvl/src/guests/simple_busybox \
    && ./build.pl --build-kernel \
    && ./build.pl --build-busybox \
    && ./build.pl --build-dropbear \
    && ./build.pl --build-libhugetlbfs \
    && ./build.pl --build-numactl \
    && ./build.pl --build-hwloc \
    && ./build.pl --build-ompi \
    && ./build.pl --build-pisces \
    && ./build.pl --build-curl \
    && ./build.pl --build-image \
    && ./build.pl --build-isoimage
    && cp image-nvl-bb.iso ${PREFIX}

# Copy VM ISO image (with descriptive name) to PREFIX dir 
RUN cp ${NVL_SOURCE_DIR}/nvl/src/guests/simple_busybox/image.iso \
       ${PREFIX}/image-nvl-bb.iso

