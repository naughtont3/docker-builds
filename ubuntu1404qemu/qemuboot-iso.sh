##!/bin/bash 

QEMU=/usr/bin/qemu-system-x86_64
#QEMU=/usr/bin/kvm

#ISOFILE=/home/vagrant/9p-stuff/imgs/guestvm.iso
ISOFILE=/opt/virt/9p_image.iso

HOST_SHAREDIR=/var/tmp/guestvm

usage () {
    echo "Usage: $0  [FILE.iso]"
    echo ""
    echo " Default ISO file: '$ISOFILE'"
    echo ""
}

die () {
    echo "ERROR: $1"
    usage
    exit 1
}

# Check if passed specific ISO file
if [ "x$1" != "x" ] ; then
    ISOFILE="$1"
else
    echo "INFO: Use default default ISO file '$ISOFILE'"
fi

# Check if ISO file exists
[ -f "$ISOFILE" ] || die "File not found '$ISOFILE'"

echo "     QEMU: $QEMU"
echo " ISO-FILE: $ISOFILE"

# Ensure the Host Share Dir exists, or is created
if [ ! -d "$HOST_SHAREDIR" ] ; then
    echo "INFO: Create 9p share dir '/var/tmp/guestvm/'"
    mkdir -p $HOST_SHAREDIR || die "Failed creating '$HOST_SHAREDIR' dir"
fi


#####
# Methods to access guest will be:
#  1) Basic serial console (default)
#       login prompt - username/password"
# 
#  2) SSH access:
#       ssh -p 10027 localhost
# 
#  3) VNC access:
#       vncviewer localhost:6
#####

echo "INFO: SSH access, try using: ssh -p 10027 root@localhost"


# ENABLE CMD ECHO (to show QEMU command)
set -xv

#    -drive file=/vagrant_data/imgs/d2.qcow2,if=virtio \
$QEMU -m 1024 \
    -cdrom $ISOFILE \
    -fsdev local,security_model=passthrough,id=fsdev0,path=/var/tmp/guestvm \
    -device virtio-9p-pci,id=fs0,fsdev=fsdev0,mount_tag=guest_share \
    -net nic,model=virtio,macaddr=52:54:00:12:34:60 \
    -net user,hostfwd=tcp::10027-:22  \
    -vnc localhost:6 &

# DISABLE CMD ECHO (so won't show comments)
set -xv

## ENABLE CMD ECHO (to show QEMU command)
#set -xv
#
# # With serial console directly attached
# $QEMU \
#     -m 512 \
#     -cdrom $ISOFILE \
#     -net nic,model=virtio,macaddr=52:54:00:12:34:60 \
#     -net user,hostfwd=tcp::10027-:22 \
#     -vnc localhost:6  \
#     -curses -serial stdio -k en-us 
#
## DISABLE CMD ECHO (so won't show comments)
#set -xv



## ENABLE CMD ECHO (to show QEMU command)
#set -xv
#
# Without serial console and in background
# $QEMU \
#     -m 512 \
#     -cdrom $ISOFILE \
#     -net nic,model=virtio,macaddr=52:54:00:12:34:60 \
#     -net user,hostfwd=tcp::10027-:22 \
#     -vnc localhost:6  &
#
## DISABLE CMD ECHO (so won't show comments)
#set -xv



## ENABLE CMD ECHO (to show QEMU command)
#set -xv
#
# Just serial console (no network)
# $QEMU \
#     -m 512 \
#     -cdrom $ISOFILE \
#     -curses -serial stdio -k en-us 
#
## DISABLE CMD ECHO (so won't show comments)
#set -xv

