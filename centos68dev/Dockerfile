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
#   docker build -t="naughtont3/centos68dev" .
#   docker push naughtont3/centos68dev
#   docker run -d -P --name devel_ve naughtont3/centos68dev /bin/sleep infinity
#   docker exec -ti devel_ve /bin/bash
#   
###########################################################################
#
# NOTES:
# - 03feb2017: Initial creation to help with setup for RHEL 6.8. 
#            
###########################################################################

FROM centos:6.8
MAINTAINER Thomas Naughton <naughtont@ornl.gov>

# Build-arg: NPROCS for parallel make
ARG NPROCS=4

# Build-arg: github token
# Note: Should be passed via '--build-arg'!!!
# (See: https://help.github.com/articles/creating-an-access-token-for-command-line-use/)
ARG GITHUB_TOKEN=thetoken

# Set PREFIX to a common directory
ENV PREFIX=/benchmarks
RUN mkdir -p "${PREFIX}" \
    && mkdir -p "${PREFIX}/src" \
    && mkdir -p "${PREFIX}/src/tar" \
    && mkdir -p "${PREFIX}/src/config" 

# # XXX: NOTE The Docker 'ADD' command will automagically extract tarballs!
# #      e.g., adding 'hpcc-1.5.0.tar.gz' to "$prefix/src" 
# #      creates "$prefix/src/hpcc-1.5.0/".
# ADD files/hpcc-1.5.0.tar.gz  		${PREFIX}/src/
# ADD files/Make.My_MPI_OpenBLAS      ${PREFIX}/src/config/

#ADD patches/PR2-tjn-gups-nompi.diff ${PREFIX}/src/config/PR2-tjn-gups-nompi.diff

#ENV container docker

# TJN: Not sure if 'epel-release' is needed/required?
RUN yum -y update \
    && yum -y install \
        epel-release \
    && yum clean all

RUN yum -y update \
    && yum -y install \
        autoconf \
        automake \
        busybox \
        gcc \
        gcc-c++ \
        genisoimage \
        git \
        kernel-headers \
        m4 \
        make \
        ncurses \
        ncurses-devel \
        ncurses-libs \
        libstdc++ \
        libstdc++-devel \
        libtool \
        patch \
        perl \
        syslinux \
        syslinux-devel.x86_64 \
        wget \
        net-tools \
        zlib \
        zlib-devel \
    && yum clean all

#### Done with base setup and install of pre-reqs,
#### Now ready for project/demo source checkouts and symlinks, etc.

# # 1) Create a symlink of HPCC to "latest" hpcc release dir
# RUN cd ${PREFIX}/src/ && \
#     ln -s ${PREFIX}/src/hpcc-1.5.0 ${PREFIX}/src/HPCC 
#
# # 2) Setup Makefile, etc. for HPCC (note: 'ADD' cmd extracts tarball!)
# RUN cd ${PREFIX}/src/HPCC/ && \
#     mkdir -p ${PREFIX}/src/HPCC/hpl/ && \
# 	cp -f ${PREFIX}/src/config/Make.My_MPI_OpenBLAS ${PREFIX}/src/HPCC/hpl/Make.My_MPI_OpenBLAS
# 

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


# ###
# # TJN: ssh-keygen of /etc/ssh/ssh_host_ecdsa_key may exist, so just ';' not '&&' cmds
# RUN useradd -c "MPI User" -m -p 'dabears' -s /bin/bash mpiuser  \
#     && su -c "echo 'export LD_LIBRARY_PATH=/usr/lib64/openmpi/lib:\$LD_LIBRARY_PATH' >> ~/.bashrc" mpiuser  \
#     && su -c "echo 'export PATH=/usr/lib64/openmpi/bin/:\$PATH' >> ~/.bashrc" mpiuser \
#     && su -c "/usr/bin/ssh-keygen -t ecdsa -f ~/.ssh/id_ecdsa -q -N ''" mpiuser \
#     && su -c "cat ~/.ssh/id_ecdsa.pub  >> ~/.ssh/authorized_keys" mpiuser \
#     && ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -q -N "" \
#      ; su -c "echo -n '* ' > ~/.ssh/known_hosts \
#     && cat /etc/ssh/ssh_host_ecdsa_key.pub >> ~/.ssh/known_hosts" mpiuser
# ###

# Default to command
CMD ["/bin/bash"]

