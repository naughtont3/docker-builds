FROM ubuntu:16.04
MAINTAINER Thomas Naughton <naughtont@ornl.gov>

# Build-arg: NPROCS for parallel make
ARG NPROCS=4

# This will prevent questions from being asked during the install
ENV DEBIAN_FRONTEND noninteractive

# Get certs so HTTPS requests (e.g., git clone) works
RUN apt-get -y update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        lsb-release \
        bash \
    && apt-get clean

RUN mkdir /dummytest && \
	echo "HELLO DUMMY" > /dummytest/README

# Default to runscript
CMD ["lsb-release -a"] 
