#!/bin/bash

#SINGULARITY=/sw/TJN/singularity-2.3/bin/singularity
#SINGULARITY=/sw/TJN/FRESHTEST/bin/singularity
SINGULARITY=/sw/TJN/mayoshstuff/bin/singularity

# Additional options to pass to 'singularity' (e.g., -x)
#SING_OPTIONS="-x --verbose"
SING_OPTIONS=

# Set to 'sudo' if using Singularity <= 2.2.1.
# Singularity >= 2.3 only needs 'sudo' for 'bootstrap' command
# so hardcode 'sudo' for bootstrap, otherwise use $SUDO 
SUDO=sudo

# Build Mode: "bootstrap" or "import"
#build_mode=import
build_mode=bootstrap

IMAGE_FILE=omb-oshmem.img
#IMAGE_DEF=omb-oshmem.def
# XXX: Having to break up sections into scriptlets to avoid ARGMAX :-(
IMAGE_DEF=omb-oshmem-scriptlets.def
#IMAGE_NAME=docker://naughtont3/omb-oshmem:latest
IMAGE_NAME=file://./omb-oshmem-latest.docker-export.tar

die () {
    msg=$1
    echo "ERROR: $msg"
    exit 1
}

[ -x "$SINGULARITY" ] || die "Executable not found/usable '$SINGULARITY'"

echo "Using Setup-Method: $build_mode"

if [ "x$build_mode" == "xbootstrap" ] ; then
    # Setup-Method: Bootstrap

    [ -f "$IMAGE_DEF"   ] || die "Definition file missing '$IMAGE_DEF'"
    
    echo "Create base image '$IMAGE_FILE'"
    echo "CMD: $SUDO $SINGULARITY $SING_OPTIONS create $IMAGE_FILE" 
    $SUDO $SINGULARITY $SING_OPTIONS create $IMAGE_FILE || die "Image create failed"

    # Always need 'sudo 'for Bootstrap command (otherwise only if
    # Singularity <= 2.2.1 so those commands use $SUDO variable
    echo "Bootstrap '$IMAGE_FILE' with '$IMAGE_DEF' definition"
    echo "CMD: sudo $SINGULARITY $SING_OPTIONS bootstrap $IMAGE_FILE $IMAGE_DEF" 
    sudo $SINGULARITY $SING_OPTIONS bootstrap $IMAGE_FILE $IMAGE_DEF || die "Image bootstrap failed"
    rc=$?

else
    # Setup-Method: Import
    [ ! "x$IMAGE_NAME" == "x" ] || die "Docker import image name missing '$IMAGE_NAME'"

    echo "Create base image '$IMAGE_FILE'"
    echo "CMD: $SUDO $SINGULARITY $SING_OPTIONS create $IMAGE_FILE" 
    $SUDO $SINGULARITY $SING_OPTIONS create $IMAGE_FILE || die "Image create failed"

    echo "Import '$IMAGE_FILE' with '$IMAGE_NAME' docker image"
    echo "CMD: $SUDO $SINGULARITY $SING_OPTIONS import $IMAGE_FILE $IMAGE_NAME" 
    $SUDO $SINGULARITY $SING_OPTIONS import $IMAGE_FILE $IMAGE_NAME || die "Image import failed"
    rc=$?

fi

echo "DONE. (rc=$rc)"
exit $rc 
