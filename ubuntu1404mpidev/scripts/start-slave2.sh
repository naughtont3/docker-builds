#!/bin/bash
# $Id$
# $URL$

imagename=naughtont3/ubuntu1404mpidev

   # TESTING: −− (Part−2) SLAVE VE for Parallel Tests −−
docker run -d --name slave-2 --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro $imagename

#   # −− (Part−2) SLAVE VE for Parallel Tests −−
#   # Limit to 48GiB, not explicitly restricting Num cpus 
#   # Run benchmark test from shell in container
#docker run -m 48g -d --name slave-1 --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro $imagename


 echo -n "slave-2 IP: "
docker ps|grep slave|awk '{print $1}'| xargs sudo docker inspect|grep IPAddr|cut -d'"' -f4 

#########
# NOTES
#
# sudo docker rm slave-1
#   --or--
#  # To avoid dangling volumes add '-v'
# sudo docker rm -v master
#
