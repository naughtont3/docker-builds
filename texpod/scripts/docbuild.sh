#!/bin/bash
# Brief: Checkout the doc to build in $DOCDIR,
#        which will be the bind mounted shared dir between
#        host and container passed at container launch time
#        (e.g., docker run -d -v hostdir:guestdir ...)

# Base bind mount dir inside the container
GUESTDIR=/home/texuser/sharedir

# Path to document checkout in shared dir
DOCDIR=$GUESTDIR/doc1

MYNAME=texdev

docker \
    exec \
    $MYNAME \
    make -C $DOCDIR
