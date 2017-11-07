###########################################################################
#
# To rebuild image:
#   docker build -t="naughtont3/<IMAGENAME>" .
#   docker push naughtont3/<IMAGENAME>
#
# Examples:
#   docker build -t="naughtont3/tjntest" .
#   docker push naughtont3/tjntest
#   docker run --name hisleep naughtont3/tjntest hellosleep 300
#   
###########################################################################
#
# NOTES:
#  - 07nov2017: Rename to 'tjntest' for simple small testing bundle.
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
