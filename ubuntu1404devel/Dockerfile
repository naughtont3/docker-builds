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
#   docker build -t="naughtont3/ubuntu1404devel" .
#   docker push naughtont3/ubuntu1404devel
#   docker run -d -P --name devel_ve naughtont3/ubuntu1404devel /bin/sleep infinity
#   docker exec -ti devel_ve /bin/bash
#   
###########################################################################

FROM ubuntu:14.04

MAINTAINER Thomas Naughton <naughtont@ornl.gov>

CMD ["mkdir","-p","/projects"]

ADD show-dev-tools.sh /projects/show-dev-tools.sh

RUN apt-get -y update \
    && apt-get install -y --no-install-recommends \
        m4 \
        autoconf \
        automake \
        libtool \
        make \
        cmake \
        gcc \
        g++ \
        gfortran \
        git \
        vim \
        exuberant-ctags \
        qemu-user-static \
        rsync \
        sudo \
        libc-bin \
        strace \
        openssh-client \
        ncurses-base \
        ncurses-bin \
        ncurses-bin \
        ncurses-term \
        libncurses5-dev \
        genisoimage \
        syslinux \
        syslinux-common \
        wget \
        bc \
        binutils-dev \
        binutils-static \
        libiberty-dev \
        libboost-dev \
        libboost1.54-dev \
        zlib1g-dev \
        linux-headers-$(uname -r) \
    && apt-get clean

