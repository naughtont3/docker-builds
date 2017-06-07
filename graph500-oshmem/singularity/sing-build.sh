#!/bin/bash

#SINGULARITY=/sw/TJN/singularity-2.3/bin/singularity
#SINGULARITY=/sw/TJN/FRESHTEST/bin/singularity
SINGULARITY=/sw/TJN/mayoshstuff/bin/singularity

# Set to 'sudo' if using Singularity <= 2.2.1.
# Singularity >= 2.3 only needs 'sudo' for 'bootstrap' command
# so hardcode 'sudo' for bootstrap, otherwise use $SUDO 
SUDO=sudo

# Build Mode: "bootstrap" or "import"
build_mode=import
#build_mode=bootstrap

IMAGE_FILE=graph500-oshmem.img
IMAGE_DEF=graph500-oshmem.def
#IMAGE_NAME=docker://naughtont3/graph500-oshmem:17.04
IMAGE_NAME=file://./graph500-oshmem-17.04.docker-export.tar

die () {
    msg=$1
    echo "ERROR: $msg"
    exit 1
}

[ -x "$SINGULARITY" ] || die "Executable not found/usable '$SINGULARITY'"

if [ "x$build_mode" == "bootstrap" ] ; then
    # Setup-Method: Bootstrap

    [ -f "$IMAGE_DEF"   ] || die "Definition file missing '$IMAGE_DEF'"
    
    echo "Create base image '$IMAGE_FILE'"
    $SUDO $SINGULARITY create $IMAGE_FILE || die "Image create failed"

    # Always need 'sudo 'for Bootstrap command (otherwise only if
    # Singularity <= 2.2.1 so those commands use $SUDO variable
    echo "Bootstrap '$IMAGE_FILE' with '$IMAGE_DEF' definition"
    sudo $SINGULARITY bootstrap $IMAGE_FILE $IMAGE_DEF || die "Image bootstrap failed"
    rc=$?

else
    # Setup-Method: Import

    [ ! "x$IMAGE_NAME" == "x" ] || die "Docker import image name missing '$IMAGE_NAME'"

    echo "Create base image '$IMAGE_FILE'"
    $SUDO $SINGULARITY create $IMAGE_FILE || die "Image create failed"

    echo "Import '$IMAGE_FILE' with '$IMAGE_NAME' docker image"
    echo "CMD: $SINGULARITY import $IMAGE_FILE $IMAGE_NAME" 
    $SUDO $SINGULARITY import $IMAGE_FILE $IMAGE_NAME || die "Image import failed"
    rc=$?

fi

echo "DONE. (rc=$rc)"
exit $rc 
