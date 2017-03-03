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
#   docker build -t="naughtont3/bb-hellosleep" .
#   docker push naughtont3/bb-hellosleep
#   docker run --name hisleep naughtont3/bb-hellosleep hellosleep 300
#   
###########################################################################
#
# NOTES:
#  - 03mar2017: Add a default command ('CMD') of 'hellosleep 5'
#  - 03nov2016: Initial version.
#
###########################################################################

FROM busybox

MAINTAINER Thomas Naughton <naughtont@ornl.gov>

COPY ./hellosleep-static /usr/bin/hellosleep-static
RUN ln -s /usr/bin/hellosleep-static /usr/bin/hellosleep

# Default to runscript
CMD ["/usr/bin/hellosleep", "5"]
