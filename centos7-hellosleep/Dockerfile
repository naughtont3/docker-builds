###########################################################################
#
# To rebuild image:
#   docker build -t="naughtont3/<IMAGENAME>" .
#   docker push naughtont3/<IMAGENAME>
#
# To run executable (hellosleep) from image (run in "non-system-mode"):
#   docker run -ti naughtont3/<IMAGENAME> hellosleep 30
#
# To run image (start container in a "system-mode"):
#   docker run -d -P --name <NAME> naughtont3/<IMAGENAME> /bin/sleep infinity
#
# To run image (start container in a "system-mode") with bind-mounted host dir:
#   docker run -d -P --name <NAME> \
#           -v /home/data:/data  naughtont3/<IMAGENAME> /bin/sleep infinity
#
# To attach to the running container:
#   docker exec -ti <NAME> /bin/bash
#
# Examples:
#   docker build -t="naughtont3/centos7-hellosleep" .
#   docker push naughtont3/centos7-hellosleep
#   docker run --name hisleep naughtont3/centos7-hellosleep hellosleep 300
#   
###########################################################################
#
# NOTES:
#  - 03nov2016: Initial version.
#
###########################################################################

FROM centos:7

MAINTAINER Thomas Naughton <naughtont@ornl.gov>

CMD ["mkdir","-p","/source"]

ADD Makefile      /source/Makefile
ADD hellosleep.c  /source/hellosleep.c

# Install various useful/prereq packages 
RUN yum -y update \
    && yum -y install \
        gcc \
        make \
    && yum clean all

RUN make -C /source
RUN cp /source/hellosleep /usr/bin/hellosleep
