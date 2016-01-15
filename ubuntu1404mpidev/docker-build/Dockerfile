#
# "ubuntu1404mpidev/Dockerfile"
#
# Ubuntu 14.04 image with MPI and SSH (from Blake Caldwell's SSH setup/configs).
#
# To rebuild image:
#  sudo docker build -t="naughtont3/<IMAGENAME>" .
#  sudo docker push naughtont3/<IMAGENAME>
#
# To run image:
#  sudo docker run -ti naughtont3/<IMAGENAME> /bin/bash
#

FROM ubuntu:14.04
MAINTAINER "Thomas Naughton" <naughtont@ornl.gov>

# This will prevent questions from being asked during the install
ENV DEBIAN_FRONTEND noninteractive

ENV container docker

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get dist-upgrade -y \
    && apt-get install -y --no-install-recommends \
        openssh-client \
        openssh-server \
    && apt-get clean 

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get dist-upgrade -y \
    && apt-get install -y --no-install-recommends \
        perl \
        m4 \
        autoconf \
        automake \
        libtool \
        make \
        gdb \
        gcc \
        g++ \
    && apt-get clean 

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get dist-upgrade -y \
    && apt-get install -y --no-install-recommends \
        openmpi-bin \
        openmpi-common \
        libopenmpi-dev \
        libopenmpi1.6-dbg \
    && apt-get clean 

CMD ["mkdir","-p","/benchmarks"]
ADD benchmarks/HPCCG-1.0.tar.gz   /benchmarks
ADD benchmarks/Makefile.HPCCG     /benchmarks/HPCCG-1.0/Makefile.HPCCG
ADD benchmarks/Makefile.HPCCG+mpi /benchmarks/HPCCG-1.0/Makefile.HPCCG+mpi
ADD benchmarks/Makefile.HPCCG     /benchmarks/HPCCG-1.0/Makefile

# TJN: ssh-keygen of /etc/ssh/ssh_host_ecdsa_key may exist, so just ';' not '&&' cmds
RUN useradd -c "MPI User" -m -p 'dabears' -s /bin/bash mpiuser  \
    && su -c "echo 'export LD_LIBRARY_PATH=/usr/lib64/openmpi/lib:\$LD_LIBRARY_PATH' >> ~/.bashrc" mpiuser  \
    && su -c "echo 'export PATH=/usr/lib64/openmpi/bin/:\$PATH' >> ~/.bashrc" mpiuser \
    && su -c "/usr/bin/ssh-keygen -t ecdsa -f ~/.ssh/id_ecdsa -q -N ''" mpiuser \
    && su -c "cat ~/.ssh/id_ecdsa.pub  >> ~/.ssh/authorized_keys" mpiuser \
    && ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -q -N "" \
     ; su -c "echo -n '* ' > ~/.ssh/known_hosts \
    && cat /etc/ssh/ssh_host_ecdsa_key.pub >> ~/.ssh/known_hosts" mpiuser

## TJN: Old centos7 stuff
# RUN ln -s /usr/lib64/openmpi/bin/mpicc  /usr/bin/mpicc  \
#     && ln -s /usr/lib64/openmpi/bin/mpic++ /usr/bin/mpic++ \
#     && ln -s /usr/lib64/openmpi/bin/mpicxx /usr/bin/mpicxx \
#     && ln -s /usr/lib64/openmpi/bin/mpif77 /usr/bin/mpif77 \
#     && ln -s /usr/lib64/openmpi/bin/mpif90 /usr/bin/mpif90 \
#     && ln -s /usr/lib64/openmpi/bin/mpirun /usr/bin/mpirun

## TJN: Old centos7 stuff
# RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
#     rm -f /lib/systemd/system/local-fs.target.wants/*; \
#     rm -f /lib/systemd/system/systemd-remount-fs.service; \
#     rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
#     rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
#     rm -f /lib/systemd/system/basic.target.wants/*; \
#     rm -f /lib/systemd/system/anaconda.target.wants/*; \
#     /usr/bin/systemctl enable sshd.service


RUN /usr/bin/service ssh start


VOLUME [ "/sys/fs/cgroup" ]
CMD ["/sbin/init"]

