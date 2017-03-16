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
#   docker build -t="naughtont3/ubuntu1604devel" .
#   docker push naughtont3/ubuntu1604devel
#   docker run -d -P --name devel_ve naughtont3/ubuntu1604devel /bin/sleep infinity
#   docker exec -ti devel_ve /bin/bash
#   
###########################################################################
# NOTES:
# - (16mar2017): Initial version based on 14.04devel, removing boost from
#    default set of pkgs we add to this 'devel' base.  Also removing
#    non-portable 'linux-headers-$(uname -r)' from package list.  Also,
#    removed 'binutils-static', which does not appear to exist in 16.04.
###########################################################################

FROM ubuntu:16.04

MAINTAINER Thomas Naughton <naughtont@ornl.gov>

RUN mkdir -p /usr/local/bin

ADD show-dev-tools.sh /usr/local/bin/show-dev-tools.sh
ENV PATH=/usr/local/bin:$PATH

# Get certs so HTTPS requests (e.g., git clone's) work.
RUN apt-get -y update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
    && apt-get clean

#        linux-headers-$(uname -r) \
#        binutils-static \
# Install various packages that are generally used for devel
RUN apt-get -y update \
    && apt-get install -y --no-install-recommends \
        autoconf \
        automake \
        bc \
        binutils-dev \
        bzip2 \
        cmake \
        exuberant-ctags \
        g++ \
        gcc \
        gdb \
        gdbserver \
        genisoimage \
        gfortran \
        git \
        iproute2 \
        iputils-ping \
        libc-bin \
        libiberty-dev \
        libncurses5-dev \
        libtool \
        m4 \
        make \
        ncurses-base \
        ncurses-bin \
        ncurses-bin \
        ncurses-term \
        net-tools \
        openssh-client \
        qemu-user-static \
        rsync \
        strace \
        sudo \
        syslinux \
        syslinux-common \
        telnet \
        vim \
        wget \
        zlib1g-dev \
    && apt-get clean

