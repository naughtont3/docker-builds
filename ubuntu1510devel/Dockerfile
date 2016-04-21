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

FROM ubuntu:15.10

MAINTAINER Thomas Naughton <naughtont@ornl.gov>

CMD ["mkdir","-p","/usr/local/bin"]

ADD show-dev-tools.sh /usr/local/bin/show-dev-tools.sh

RUN apt-get -y update \
    && apt-get install -y --no-install-recommends \
        autoconf \
        automake \
        bc \
        binutils-dev \
        binutils-static \
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

