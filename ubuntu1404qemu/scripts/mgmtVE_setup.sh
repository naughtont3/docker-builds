#!/bin/bash
#
# MgmtVE Context:
#  Script to be run in the "Management Container" (MgmtVE)
#  that creates a user ($QEMUUSER_NAME) and runs QEMU with VirtFS share,
#  or if passed 'root' as 2nd arg, runs as Root user the QEMU with VirtFS share.
#
#  NOTE: Assumes we have access to 'sudo' for useradd and for running QEMU 
#        as root, or as QEMUUSER_NAME.
#
#

usage () {
    echo "Usage: $0 ISOFILE [root]"
    echo ""
    echo "  ISOFILE   Path to ISO file for QEMU launch"
    echo "  root      (Optional) String used to request running QEMU as root"
    echo ""
}

die () {
    echo "ERROR: $1"
    usage
    exit 1
}

create_user () {
    new_uname=$1
    new_uid=$2
    new_gid=$3

    which groupadd 2>&1 >/dev/null    || die "Missing 'groupadd' executable"
    which useradd  2>&1 >/dev/null    || die "Missing 'useradd' executable"
    which sudo     2>&1 >/dev/null    || die "Missing 'sudo' executable"

    sudo groupadd -g $new_gid $new_uname  \
        || die "Failed to create group (${new_uname}:${new_gid})"

    sudo useradd -u $new_uid -g $new_gid $new_uname  \
        || die "Failed to create user (${new_uname}:${new_uid}.${new_gid})"
}

# Path to QEMU binary
QEMU=/usr/bin/qemu-system-x86_64
#QEMU=/usr/bin/kvm

# UserID/GroupID for 'qemu' User
QEMUUSER_NAME=qemuuser
QEMUUSER_UID=107
QEMUUSER_GID=107

# Host Share directory (actually the base for the shares, e.g., /var/tmp/users)
HOST_SHARE_DIR=/var/tmp/users

# Default to running as non-root
RUN_AS_ROOT=0

# End configs
###################

# Sanity checks

which echo     2>&1 >/dev/null    || die "Missing 'echo' executable"
which sudo     2>&1 >/dev/null    || die "Missing 'sudo' executable"

[[ -d $HOST_SHARE_DIR  ]] || die "Missing host share dir ($HOST_SHARE_DIR)"
[[ -x $QEMU ]] || die "Missing 'qemu' executable ($QEMU)"

[[ -f "$1" ]]  || die "Missing ISO file ($1)"

# (Required) Arg 1 is ISOFILE
ISOFILE="$1"

# (Optional) Arg 2 is run as 'root' flag
if [ "x$2" = "xroot" ] ; then
    RUN_AS_ROOT=1
fi

########

#####
# NOTE: Methods to access guest will be:
#  1) SSH access:
#       ssh -p 10027 localhost
# 
#  2) VNC access:
#       vncviewer localhost:6
#####
export qemu_cmd="$QEMU -m 1024 -cdrom $ISOFILE -fsdev local,security_model=passthrough,id=fsdev0,path=$HOST_SHARE_DIR -device virtio-9p-pci,id=fs0,fsdev=fsdev0,mount_tag=guest_share -net nic,model=virtio,macaddr=52:54:00:12:77:77 -net user,hostfwd=tcp::10027-:22 -vnc localhost:6"

# Enable echo of command (trace) and exit on error 
set -xe

# Run a command with sudo to die early if there are problems. 
# (run this *after* set -xe for exit on error behavior)
sudo date

if [ $RUN_AS_ROOT -eq 1 ] ; then

    # [[ $EUID -eq 0 ]]  || die "Must be run with root permissions! (EUID=$EUID)"

    echo "Run QEMU as Root user!"

    # Run QEMU as Root user!
    sudo ${qemu_cmd}

else 

    echo "Run QEMU as non-root user ($QEMUUSER_NAME)"


    # See if need to create non-root user to run QEMU
    id $QEMUUSER_NAME 2>&1 >/dev/null \
        || create_user $QEMUUSER_NAME $QEMUUSER_UID $QEMUUSER_GID

    # Run QEMU as non-root user
    sudo -E -u $QEMUUSER_NAME ${qemu_cmd}

fi


exit 0
