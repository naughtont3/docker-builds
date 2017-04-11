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
#   docker build -t="naughtont3/hobbes-dtk-demo" .
#   docker push naughtont3/hobbes-dtk-demo
#   docker run -d -P --name devel_ve naughtont3/hobbes-dtk-demo /bin/sleep infinity
#   docker exec -ti devel_ve /bin/bash
#   
###########################################################################
#
# NOTES:
# - 11apr2017: Initial create based on previous HPCC build.
#            
###########################################################################

FROM ubuntu:16.04
MAINTAINER Thomas Naughton <naughtont@ornl.gov>

# Build-arg: NPROCS for parallel make
ARG NPROCS=4

# Build-arg: github token
# Note: Should be passed via '--build-arg'!!!
# (See: https://help.github.com/articles/creating-an-access-token-for-command-line-use/)
ARG GITHUB_TOKEN=thetoken

# Set PREFIX to a common Benchmark directory
ENV PREFIX=/benchmarks
RUN mkdir -p "${PREFIX}" \
    && mkdir -p "${PREFIX}/src" \
    && mkdir -p "${PREFIX}/src/tar" \
    && mkdir -p "${PREFIX}/src/config" \
    && mkdir -p "${PREFIX}/runs" \ 
    && mkdir -p "${PREFIX}/runs/Test1"  

# XXX: NOTE The Docker 'ADD' command will automagically extract tarballs!
#      e.g., adding 'iperf-3.1.3-source.tar.gz' to "$prefix/src" 
#      creates "$prefix/src/iperf-3.1.3/".
ADD files/iperf-3.1.3-source.tar.gz  ${PREFIX}/src/
ADD files/run-iperf-client.sh        ${PREFIX}/runs/run-iperf-client.sh
ADD files/run-iperf-server.sh        ${PREFIX}/runs/run-iperf-server.sh


#ENV container docker

# This will prevent questions from being asked during the install
ENV DEBIAN_FRONTEND noninteractive

# Get certs so HTTPS requests (e.g., git clone) works
RUN apt-get -y update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
    && apt-get clean

# Install SSH client/server
#  o Note: We use 'ssh-keygen' from openssh-client in add 'mpiuser' step.)
#  o Note: Add 'sshd' from openssh-client in case we need that too.
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get dist-upgrade -y \
    && apt-get install -y --no-install-recommends \
        openssh-client \
        openssh-server \
    && apt-get clean

# Install various useful/prereq packages 
RUN apt-get -y update \
    && apt-get install -y --no-install-recommends \
        autoconf \
        automake \
        bc \
        gcc \
        iputils-ping \
        libtool \
        net-tools \
        m4 \
        make \
        patch \
        perl \
        time \
        vim \
        wget \
        zlib1g-dev \
    && apt-get clean

#### Done with base setup and install of pre-reqs,
#### Now ready for project/demo source checkouts and symlinks, etc.

# 1) Create a symlink of IPERF to "latest" release dir
RUN cd ${PREFIX}/src/ && \
    ln -s ${PREFIX}/src/iperf-3.1.3 ${PREFIX}/src/IPERF


#### Done getting all the source code/patching. 
#### Now need kick off the configure(s) and build(s)!
#### Note, we'll build at end to ensure we build all in proper order.


###
# TJN: ssh-keygen of /etc/ssh/ssh_host_ecdsa_key may exist, so just ';' not '&&' cmds
RUN useradd -c "MPI User" -m -p 'dabears' -s /bin/bash mpiuser  \
    && su -c "echo 'export LD_LIBRARY_PATH=/usr/lib64/openmpi/lib:\$LD_LIBRARY_PATH' >> ~/.bashrc" mpiuser  \
    && su -c "echo 'export PATH=/usr/lib64/openmpi/bin/:\$PATH' >> ~/.bashrc" mpiuser \
    && su -c "/usr/bin/ssh-keygen -t ecdsa -f ~/.ssh/id_ecdsa -q -N ''" mpiuser \
    && su -c "cat ~/.ssh/id_ecdsa.pub  >> ~/.ssh/authorized_keys" mpiuser \
    && ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -q -N "" \
     ; su -c "echo -n '* ' > ~/.ssh/known_hosts \
    && cat /etc/ssh/ssh_host_ecdsa_key.pub >> ~/.ssh/known_hosts" mpiuser
###

# Create sshd run dir
RUN mkdir /var/run/sshd

# Chown all the src code to 'mpiuser'
RUN chown -R mpiuser ${PREFIX}/

# Default to non-root user ('mpiuser')
USER mpiuser

# Build IPERF (note: 'ADD' cmd extracts tarball!)
RUN cd ${PREFIX}/src/IPERF && \
    mkdir ${PREFIX}/src/IPERF/local && \
    ./configure --prefix=${PREFIX}/src/local && \
    make && \ 
    make install

# Go ahead and add 'iperf3' binary to path
ENV PATH=${PREFIX}/src/IPERF/local/bin:$PATH

# (NONE FOR IPERF) Default to runscript
CMD ["/bin/bash"]
