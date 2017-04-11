#!/bin/bash

# XXX: Edit for your service name
service_name=iperf

ve_name=`docker ps --filter name=$service_name --format='{{.Names}}'`

docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $ve_name
