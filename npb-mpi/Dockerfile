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
#   docker build -t="naughtont3/npb-mpi" .
#   docker push naughtont3/npb-mpi
#   docker run -d -P --name devel_ve naughtont3/npb-mpi /bin/sleep infinity
#   docker exec -ti devel_ve /bin/bash
#   
###########################################################################
#
# NOTES:
# - 06mar2016: Initial creation based on my previous container templates.
#              Using NPB v3.3.1 from https://www.nas.nasa.gov/assets/npb/NPB3.3.1.tar.gz
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
#      e.g., adding 'NPB3.3.1.tar.gz' to "$prefix/src" 
#      creates "$prefix/src/NPB3.3.1/"
ADD files/NPB3.3.1.tar.gz           ${PREFIX}/src/
ADD files/make.def-NPB-ompi         ${PREFIX}/src/config/
ADD files/suite.def-NPB-ompi        ${PREFIX}/src/config/
ADD files/run-npb.sh                ${PREFIX}/runs/run-npb.sh

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
        iputils-ping \
        libtool \
        net-tools \
        m4 \
        make \
        patch \
        perl \
        vim \
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

# 1) Create a symlink of NPB MPI to "latest" npb release dir
#    (Note: NPB has subdir with MPI specific code for the given release.)
RUN cd ${PREFIX}/src/ && \
    ln -s ${PREFIX}/src/NPB3.3.1/NPB3.3-MPI ${PREFIX}/src/NPB

# 2) Setup Makefile, etc. for NPB (note: 'ADD' cmd extracts tarball!)
RUN cd ${PREFIX}/src/NPB/ && \
	cp -f ${PREFIX}/src/config/make.def-NPB-ompi  ${PREFIX}/src/NPB/config/make.def && \
	cp -f ${PREFIX}/src/config/suite.def-NPB-ompi ${PREFIX}/src/NPB/config/suite.def


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

# Create sshd run dir
RUN mkdir /var/run/sshd

# Chown all the src code to 'mpiuser'
RUN chown -R mpiuser ${PREFIX}/

# Default to non-root user ('mpiuser')
USER mpiuser

# Build NPB suite
RUN cd ${PREFIX}/src/NPB && \
    cat config/suite.def && \
    make suite

# Go ahead and add NPB binaries to path
ENV PATH=${PREFIX}/src/NPB/bin:$PATH

# Default to runscript
# (TJN: Seems we can not use ${PREFIX} var with 'CMD'
CMD ["/benchmarks/runs/run-npb.sh"]
