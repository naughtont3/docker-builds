#!/bin/bash

SINGULARITY=/sw/TJN/bin/singularity
IMAGE_FILE=iperf-ubuntu.img
IMAGE_DEF=iperf-ubuntu.def

die () {
    msg=$1
    echo "ERROR: $msg"
    exit 1
}

[ -x "$SINGULARITY" ] || die "Executable not found/usable '$SINGULARITY'"
[ -f "$IMAGE_DEF"   ] || die "Definition file missing '$IMAGE_DEF'"

echo "Create base image '$IMAGE_FILE'"
sudo $SINGULARITY create $IMAGE_FILE || die "Image create failed"

echo "Bootstrap '$IMAGE_FILE' with '$IMAGE_DEF' definition"
sudo $SINGULARITY bootstrap $IMAGE_FILE $IMAGE_DEF || die "Image bootstrap failed"

echo "DONE."
exit 0
