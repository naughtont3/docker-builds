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
        genisoimage \
        syslinux \
        syslinux-common \
        wget \
    && apt-get clean

