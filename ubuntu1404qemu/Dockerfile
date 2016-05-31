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
#   docker build -t="naughtont3/ubuntu1404qemu" .
#   docker push naughtont3/ubuntu1404qemu
#   docker run -d -P --name devel_ve naughtont3/ubuntu1404qemu /bin/sleep infinity
#   docker exec -ti devel_ve /bin/bash
#   
###########################################################################

FROM ubuntu:14.04

MAINTAINER Thomas Naughton <naughtont@ornl.gov>

CMD ["mkdir","-p","/opt/virt"]

# NOTE: If change '/opt/virt/' path, update qemuboot script!
ADD qemuboot-iso.sh /opt/virt/qemuboot-iso.sh

# NOTE: If change '/opt/virt/' path, update qemuboot script!
ADD 9p_image.iso    /opt/virt/9p_image.iso


# Get certs so HTTPS requests (e.g., git clone's) work.
RUN apt-get -y update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
    && apt-get clean

# Install various packages that are generally used for devel
RUN apt-get -y update \
    && apt-get install -y --no-install-recommends \
        qemu-kvm \
        qemu-system-x86 \
        iproute2 \
        iputils-ping \
        net-tools \
        openssh-client \
        rsync \
        strace \
        sudo \
        telnet \
        vim \
        wget \
    && apt-get clean

