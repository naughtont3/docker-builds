# ubuntu1404mpidev

Basic MPI Devel/Testing Container

This is a container with the basic bits for testing MPI programs in
containers.  It has the build utils and an MPI.  

This is also setup to be a "system container" such that it runs an SSH
Daemon in the container for ssh'ing during MPI process launch.

This is all very simplistic and mainly just provides an example for
a manual procedure for launching a couple containers and then
attaching and running an MPI application.

See also Docker Hub repo
https://hub.docker.com/r/naughtont3/ubuntu1404mpidev/

# HPCCG Benchmark
Note, we're including a tarball of the HPCCG benchmark for easy testing.
The original code was downloaded from the Mantevo Mini-apps page

 - https://mantevo.org/download.php


# Misc. Commands
```
 export imgname="naughtont3/ubuntu1404mpidev"

   # −− (Part−1) MASTER VE for Parallel Tests −− 
   # Run benchmark test from shell in container
 sudo docker run -m 2g --name master --privileged -ti -v /sys/fs/cgroup:/sys/fs/cgroup:ro $imgname /bin/bash
 

   # −− (Part−2) SLAVE VE for Parallel Tests −−
   # Run benchmark test from shell in container
 sudo docker run -m 2g -d --name slave-1 --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro $imgname
```

Getting the IP addreses of the respective compute container...
```
 sudo docker ps|grep slave|awk '{print $1}'| xargs sudo docker inspect|grep IPAddr|cut -d'"' -f4 
```

Removing the containers (and their volumes to avoid dangling volumes!)
```
  docker rm -v master
  docker rm -v slave-1
```


Becoming 'mpiuser' in the container (e.g., 'master' container) and building
HPCCG benchmark that is included within the devel container for easy
testing.  (Note, use proper IP address in 'scp' command below.)
``` 
    su - mpiuser
    cd /benchmarks/HPCCG-1.0/
      # Setup Makefile.ompi...
    make
    chown mpiuser.mpiuser /home/mpiuser/test_HPCCG.mpi
    cp test_HPCCG.mpi /home/mpiuser/

    su - mpiuser 
    scp test_HPCCG.mpi 10.255.1.11:

     # Add any needed OpenMPI MCA params 
    echo "btl=^openib" >> ~/.openmpi/mca-params.conf
```

