#!/bin/bash -xv

QEMU=/usr/bin/qemu-system-x86_64
ISOFILE=/tmp/image.iso

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

# With serial console directly attached
$QEMU \
    -m 512 \
    -cdrom $ISOFILE \
    -net nic,model=virtio,macaddr=52:54:00:12:34:60 \
    -net user,hostfwd=tcp::10027-:22 \
    -vnc localhost:6  \
    -curses -serial stdio -k en-us 

# Without serial console and in background
# $QEMU \
#     -m 512 \
#     -cdrom $ISOFILE \
#     -net nic,model=virtio,macaddr=52:54:00:12:34:60 \
#     -net user,hostfwd=tcp::10027-:22 \
#     -vnc localhost:6  &

# Just serial console (no network)
# $QEMU \
#     -m 512 \
#     -cdrom $ISOFILE \
#     -curses -serial stdio -k en-us 
