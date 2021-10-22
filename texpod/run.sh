#!/bin/bash

HOSTDIR=$PWD/hostshare
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
