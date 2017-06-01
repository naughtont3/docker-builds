#!/bin/bash

SINGULARITY=/sw/TJN/singularity-2.3/bin/singularity
#SINGULARITY=/sw/TJN/FRESHTEST/bin/singularity
IMAGE_FILE=hpcc-mpi-TEST1.img
IMAGE_DEF=hpcc-mpi-TEST1.def
IMAGE_NAME=naughtont3/hpcc-mpi:latest

die () {
    msg=$1
    echo "ERROR: $msg"
    exit 1
}

[ -x "$SINGULARITY" ] || die "Executable not found/usable '$SINGULARITY'"
#[ -f "$IMAGE_DEF"   ] || die "Definition file missing '$IMAGE_DEF'"
[ ! "x$IMAGE_NAME" == "x" ] || die "Docker import image name missing '$IMAGE_NAME'"

echo "Create base image '$IMAGE_FILE'"
$SINGULARITY create $IMAGE_FILE || die "Image create failed"

#echo "Bootstrap '$IMAGE_FILE' with '$IMAGE_DEF' definition"
#$SINGULARITY bootstrap $IMAGE_FILE $IMAGE_DEF || die "Image bootstrap failed"

echo "Import '$IMAGE_FILE' with '$IMAGE_NAME' docker image"
echo "CMD: $SINGULARITY import $IMAGE_FILE $IMAGE_NAME" 
$SINGULARITY import $IMAGE_FILE docker://$IMAGE_NAME || die "Image import failed"

echo "DONE."
exit 0
