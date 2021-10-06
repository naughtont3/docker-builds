###########################################################################
#
# To rebuild image:
#   docker build -t="naughtont3/<IMAGENAME>" .
#   docker push naughtont3/<IMAGENAME>
#
# To run image (start container):
#   docker run -d -P --name <NAME> naughtont3/<IMAGENAME> /bin/sleep infinity
#
# To attach to the running container:
#   docker exec -ti <NAME> /bin/bash
#
###########################################################################

FROM ubuntu:20.04
MAINTAINER Thomas Naughton <naughtont@ornl.gov>

# This will prevent questions from being asked during the install
ENV DEBIAN_FRONTEND noninteractive

RUN useradd -c "thomas test" -m -p 'dabears' -s /bin/bash tjn && \
    mkdir -p /home/tjn/bin

ADD files/show-dev-tools.sh /home/tjn/bin/show-dev-tools.sh
ADD files/TJN-SPACK.md      /home/tjn/TJN-SPACK.md
ENV PATH=/home/tjn/bin:$PATH

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
        gfortran \
        git \
        iproute2 \
        iputils-ping \
        libc-bin \
        libiberty-dev \
        libtool \
        m4 \
        make \
        net-tools \
        openssh-client \
        patch \
        python3 \
        python3-venv \
        rsync \
        strace \
        sudo \
        telnet \
        vim \
        wget \
        zlib1g-dev \
    && apt-get clean

USER tjn

RUN git clone https://github.com/spack/spack ~/spack \
    && echo "# TJN: Add spack env setup"              >> /home/tjn/.bashrc \
    && echo "source ~/spack/share/spack/setup-env.sh" >> /home/tjn/.bashrc

# Default to runscript
#CMD ["/usr/bin/sleep", "infinity"]
CMD ["/bin/bash"]
