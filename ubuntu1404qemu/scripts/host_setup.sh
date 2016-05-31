#!/bin/bash
#
# Host Context:
#   Script to setup Host to have the two users (created if needed) and
#   setup the share directories and base "hello" files with permissions
#   for the two users.
#

usage () {
    echo "Usage: $0"
}

die () {
    echo "ERROR: $1"
    usage
    exit 1
}

# UserID/GroupID for 'user1'
USER1_NAME=user1
USER1_UID=1010
USER1_GID=1010

# UserID/GroupID for 'user2'
USER2_NAME=user2
USER2_UID=2020
USER2_GID=2020

[[ $EUID -eq 0 ]]  || die "Must be run with root permissions! (EUID=$EUID)"

which chmod    2>&1 >/dev/null    || die "Missing 'chmod' executable"
which chown    2>&1 >/dev/null    || die "Missing 'chown' executable"
which echo     2>&1 >/dev/null    || die "Missing 'echo' executable"
which groupadd 2>&1 >/dev/null    || die "Missing 'groupadd' executable"
which mkdir    2>&1 >/dev/null    || die "Missing 'mkdir' executable"
which useradd  2>&1 >/dev/null    || die "Missing 'useradd' executable"

########

# Enable echo of command (trace) and exit on error 
set -xe

mkdir -p /var/tmp/users 
mkdir -p /var/tmp/users/$USER1_NAME
mkdir -p /var/tmp/users/$USER2_NAME

echo "Hello ALL-USERS" > /var/tmp/users/host_allusers_hello_file
echo "Hello $USER1_NAME (USER1)"  > /var/tmp/users/$USER1_NAME/host_${USER1_NAME}_hello_file
echo "Hello $USER2_NAME (USER2)"  > /var/tmp/users/$USER2_NAME/host_${USER2_NAME}_hello_file

chmod a+r    /var/tmp/users/host_allusers_hello_file
chmod og-w   /var/tmp/users/host_allusers_hello_file

chmod u+rwx  /var/tmp/users/$USER1_NAME
chmod u+rw   /var/tmp/users/$USER1_NAME/host_${USER1_NAME}_hello_file

chmod u+rwx  /var/tmp/users/$USER2_NAME
chmod u+rw   /var/tmp/users/$USER2_NAME/host_${USER2_NAME}_hello_file

groupadd -g $USER1_GID $USER1_NAME
useradd -u $USER1_UID -g $USER1_GID $USER1_NAME

groupadd -g $USER2_GID $USER2_NAME
useradd -u $USER2_UID -g $USER2_GID $USER2_NAME

chown -R ${USER1_NAME}.${USER1_NAME} /var/tmp/users/${USER1_NAME}
chown -R ${USER2_NAME}.${USER2_NAME} /var/tmp/users/${USER1_NAME}

id user1
id user2

exit 0
