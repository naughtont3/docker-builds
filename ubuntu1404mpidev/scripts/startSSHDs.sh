#!/bin/bash

# XXX: Edit for your service name
service_name=tst1

ve_name=`docker ps --filter name=$service_name --format='{{.Names}}'`

docker cp /tmp/setupSSH.sh $ve_name:/tmp
docker exec $ve_name /tmp/setupSSH.sh

