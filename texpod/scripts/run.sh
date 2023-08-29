#!/bin/bash

# Use current working dir as host dir
HOSTDIR=$PWD

# Path inside container (no need to change)
GUESTDIR=/home/texuser/sharedir

MYNAME=texdev

docker \
    run \
    -d \
    --rm  \
    --name $MYNAME \
    -v $HOSTDIR:$GUESTDIR \
    naughtont3/texpod \
    /usr/bin/sleep infinity

echo " Started $MYNAME "
