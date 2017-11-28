#!/bin/bash

BUILD_FLAGS=
BUILD_SCRIPT=/usr/local/src/build_ornloshm-develop.sh

if [ ! -z "$LIBEVENT_INSTALL_DIR" ] ; then
    # Installed so Skip Libevent
    BUILD_FLAGS="${options} -L "
fi

if [ ! -z "$PMIX_INSTALL_DIR" ] ; then
    # Installed so Skip PMIX
    BUILD_FLAGS="${options} -P "
fi

if [ ! -z "$OMPI_INSTALL_DIR" ] ; then
    # Installed so Skip OMPI
    BUILD_FLAGS="${options} -O "
fi

echo "CMD: $BUILD_SCRIPT $BUILD_FLAGS"
$BUILD_SCRIPT $BUILD_FLAGS

