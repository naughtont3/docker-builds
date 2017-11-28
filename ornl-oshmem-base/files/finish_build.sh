#!/bin/bash

BUILD_FLAGS=
BUILD_SCRIPT=/usr/local/src/build_ornloshm-develop.sh

if [ ! -z "$LIBEVENT_INSTALL_DIR" ] ; then
    # Installed so Skip Libevent
    BUILD_FLAGS="${BUILD_FLAGS} -L "
fi

if [ ! -z "$PMIX_INSTALL_DIR" ] ; then
    # Installed so Skip PMIX
    BUILD_FLAGS="${BUILD_FLAGS} -P "
fi

if [ ! -z "$OMPI_INSTALL_DIR" ] ; then
    # Installed so Skip OMPI
    BUILD_FLAGS="${BUILD_FLAGS} -O "
fi

echo "CMD: $BUILD_SCRIPT $BUILD_FLAGS $@"
$BUILD_SCRIPT $BUILD_FLAGS $@

