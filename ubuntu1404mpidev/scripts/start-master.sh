#!/bin/bash
# $Id$
# $URL$

imagename=naughtont3/ubuntu1404mpidev

   # TESTING: −− (Part−1) MASTER VE for Parallel Tests −− 
docker run --name master --privileged -ti -v /sys/fs/cgroup:/sys/fs/cgroup:ro $imagename /bin/bash

   # −− (Part−1) MASTER VE for Parallel Tests −− 
   # Limit to 48GiB, not explicitly restricting Num cpus 
   # Run benchmark test from shell in container
# docker run -m 48g --name master --privileged -ti -v /sys/fs/cgroup:/sys/fs/cgroup:ro $imagename /bin/bash


##########
# NOTES
# 
# sudo docker rm master
#   --or--
#  # To avoid dangling volumes add '-v'
# sudo docker rm -v master
#
# sudo docker ps|grep slave|awk '{print $1}'| xargs sudo docker inspect|grep IPAddr|cut -d'"' -f4 

