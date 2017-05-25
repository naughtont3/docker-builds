TODO
====
 - [ ] Fix run-graph500.sh to match proper syntax/usage
 - [x] Fix download OpenMPI tarball problem (bad URL?)
 - [x] add graph500-shmem src mpi/Makefile patch
 - [x] add graph500.org src/build 
 - [ ] revisit OMPI version to use? (do we need 3x or master for comparisons)
 - [ ] finish testing Ed's version of graph500 openshmem
 - [ ] move runscript to files/ dir, update Dockerfile accordingly
 - [x] rename runit.sh to run-graph500.sh
 - [ ] push this image up to DockerHub
 - [ ] separate ompi-oshmem into stand-alone image for reuse elsewhere
 - [ ] update runscript to be more generic (input args: nprocs, other?)
 - [ ] add scripts to help with running across multiple hosts
