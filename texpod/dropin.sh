#!/bin/bash

MYNAME=texdev

echo " Dropping into $MYNAME "
docker \
    exec \
    -ti \
    $MYNAME \
    bash

