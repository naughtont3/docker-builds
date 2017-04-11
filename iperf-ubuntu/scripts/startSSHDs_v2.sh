#!/bin/bash

# XXX: Edit for your service name
service_name=iperf

ve_name=`docker ps --filter name=$service_name --format='{{.Names}}'`

#docker cp /tmp/setupSSH.sh $ve_name:/tmp
echo "CMD: docker exec --user=root $ve_name /usr/sbin/sshd -p 2222"
docker exec --user=root $ve_name mkdir -p /var/run/sshd
docker exec --user=root $ve_name /usr/sbin/sshd -p 2222

