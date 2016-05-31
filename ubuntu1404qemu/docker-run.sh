#!/bin/bash -xe
# TJN: Helper script to startup the "system VE" for testing.

usage () {
    echo "Usage: $0" 
}

die () {
    echo "ERROR: $1"
    usage
    exit 1
}

MY_DOCKER_SHAREDIR=/home/tjn/docker/docker_share
MY_9PHOST_SHAREDIR=/var/tmp/users

[[ -d "$MY_DOCKER_SHAREDIR" ]] || die "Missing directory '$MY_DOCKER_SHAREDIR'"
[[ -d "$MY_9PHOST_SHAREDIR" ]] || die "Missing directory '$MY_9PHOST_SHAREDIR'"

docker run -d -P --name devel_qemu \
    -v $MY_DOCKER_SHAREDIR:/data \
    -v $MY_9PHOST_SHAREDIR:$MY_9PHOST_SHAREDIR \
    naughtont3/ubuntu1404qemu \
    /bin/sleep infinity
