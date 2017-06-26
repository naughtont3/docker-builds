#!/bin/bash
# NOTE: Also have edits in '/environment' of Container
# related to CRAY_xxx envvars

MY_TITAN_USERNAME=naughton

# Show commands
set -x

mkdir -p /opt/cray
mkdir -p /var/spool/alps
mkdir -p /var/opt/cray
mkdir -p /lustre/atlas
mkdir -p /lustre/atlas1
mkdir -p /lustre/atlas2

mkdir -p /ccs/home/${MY_TITAN_USERNAME}

# HACK: add 'munge' libs for pieces we need on Cray
apt-get -y update \
    && apt-get install -y --no-install-recommends \
        libmunge2  \
        munge \
    && apt-get clean

