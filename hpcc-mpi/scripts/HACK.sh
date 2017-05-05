#!/bin/bash

# XXX: Edit for your service name
service_name=hpcc

ve_name=`docker ps --filter name=$service_name --format='{{.Names}}'`

#docker cp /tmp/setupSSH.sh $ve_name:/tmp
#echo "CMD: docker exec --user=root $ve_name /usr/sbin/sshd -p 2222"
#docker exec --user=root $ve_name mkdir -p /var/run/sshd

# Install pkgs (rsync, python, time) into container on this node
docker exec --user=root $ve_name apt-get install -y rsync python time

