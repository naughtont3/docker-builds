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

echo "Read-ONLY by $USER1_NAME (USER1)"  > /var/tmp/users/$USER1_NAME/host_${USER1_NAME}_private_file
echo "Read-ONLY by $USER2_NAME (USER2)"  > /var/tmp/users/$USER2_NAME/host_${USER2_NAME}_private_file

chmod u+rwx  /var/tmp/users
chmod og-w   /var/tmp/users
chmod a+rx   /var/tmp/users
chmod a+r    /var/tmp/users/host_allusers_hello_file
chmod og-wx  /var/tmp/users/host_allusers_hello_file

chmod u+rwx  /var/tmp/users/$USER1_NAME
chmod u+rw   /var/tmp/users/$USER1_NAME/host_${USER1_NAME}_hello_file
chmod u+rw   /var/tmp/users/$USER1_NAME/host_${USER1_NAME}_private_file
chmod og-rwx /var/tmp/users/$USER1_NAME/host_${USER1_NAME}_private_file

chmod u+rwx  /var/tmp/users/$USER2_NAME
chmod u+rw   /var/tmp/users/$USER2_NAME/host_${USER2_NAME}_hello_file
chmod u+rw   /var/tmp/users/$USER2_NAME/host_${USER2_NAME}_private_file
chmod og-rxw /var/tmp/users/$USER2_NAME/host_${USER2_NAME}_private_file

# Create USER1 (if needed)
id $USER1_NAME 2>&1 >/dev/null \
    || create_user $USER1_NAME $USER1_UID $USER1_GID

# Create USER2 (if needed)
id $USER2_NAME 2>&1 >/dev/null \
    || create_user $USER2_NAME $USER2_UID $USER2_GID


chown -R ${USER1_NAME}.${USER1_NAME} /var/tmp/users/${USER1_NAME}
chown -R ${USER2_NAME}.${USER2_NAME} /var/tmp/users/${USER2_NAME}

echo "========================="

id ${USER1_NAME}
id ${USER2_NAME}

ls -lR /var/tmp/users

exit 0
