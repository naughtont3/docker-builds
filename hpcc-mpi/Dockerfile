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
# - 31jan2017: Initial creation based on my previous container templates,
#			   using notes from Charlotte Kotas for HPCC setup/build.
#              Using HPCC v1.5.0 from http://icl.cs.utk.edu/hpcc/software
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

# Set PREFIX to a common Hobbes directory
ENV PREFIX=/usr/local
RUN mkdir -p "${PREFIX}" \
    && mkdir -p "${PREFIX}/src" \
    && mkdir -p "${PREFIX}/src/tar" \
    && mkdir -p "${PREFIX}/src/config"  

# XXX: NOTE The Docker 'ADD' command will automagically extract tarballs!
#      e.g., adding 'hpcc-1.5.0.tar.gz' to "$prefix/src" 
#      creates "$prefix/src/hpcc-1.5.0/".
ADD files/hpcc-1.5.0.tar.gz  		${PREFIX}/src/
ADD files/Make.My_MPI_OpenBLAS      ${PREFIX}/src/config/
ADD files/runit.sh                  /runit.sh

#ADD patches/PR2-tjn-gups-nompi.diff ${PREFIX}/src/config/PR2-tjn-gups-nompi.diff


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
        g++ \
        gcc \
        gfortran \
        git \
        libtool \
        m4 \
        make \
        patch \
        perl \
        wget \
        zlib1g-dev \
    && apt-get clean

# Install OpenMPI and OpenBLAS from Distribution
RUN apt-get -y update \
    && apt-get install -y --no-install-recommends \
		openmpi-bin \
		openmpi-common \
		libopenmpi-dev \
		libopenblas-dev \
    && apt-get clean


#### Done with base setup and install of pre-reqs,
#### Now ready for project/demo source checkouts and symlinks, etc.

# 1) Setup Makefile, etc. for HPCC (note: 'ADD' cmd extracts tarball!)
RUN cd ${PREFIX}/src/hpcc-1.5.0/ && \
    mkdir -p ${PREFIX}/src/hpcc-1.5.0/hpl/ && \
	cp -f ${PREFIX}/src/config/Make.My_MPI_OpenBLAS ${PREFIX}/src/hpcc-1.5.0/hpl/Make.My_MPI_OpenBLAS


# # N) Checkout OSB git with GUPS benchmark into "${PREFIX}/src"
# #    (which will result in: /usr/local/src/osb)
# #    URL: https://github.com/ornl-languages/osb
# RUN cd ${PREFIX}/src/ && \
#     git clone https://${GITHUB_TOKEN}:x-oauth-basic@github.com/ornl-languages/osb.git 
# 
# # N.1) Patch to remove MPI usage in GUPS code (pull-request #2)
# RUN cd ${PREFIX}/src/osb && \
#     patch -p 1 < ${PREFIX}/src/config/PR2-tjn-gups-nompi.diff
# 


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

# Default to non-root user ('mpiuser')
USER mpiuser

# Chown all the src code to 'mpiuser'
RUN chown -R mpiuser ${PREFIX}/src

# Build HPCC
RUN cd ${PREFIX}/src/hpcc-1.5.0 && \
    make arch=My_MPI_OpenBLAS 

# Go ahead and add 'hpcc' binary to path
ENV PATH=${PREFIX}/src/hpcc-1.5.0:$PATH

# Default to runscript
CMD ["/runit.sh"]

