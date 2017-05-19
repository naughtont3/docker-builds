TODO
====
 - [ ] Fix run-graph500.sh to match proper syntax/usage
 - [ ] Fix download OpenMPI tarball problem (bad URL?)
 - [ ] add graph500 src mpi/Makefile patch
 - [ ] finish testing Ed's version of graph500 openshmem
 - [ ] move runscript to files/ dir, update Dockerfile accordingly
 - [ ] rename runit.sh to run-graph500.sh
 - [ ] push this image up to DockerHub
 - [ ] separate ompi-oshmem into stand-alone image for reuse elsewhere
 - [ ] move Graph500 to /benchmarks dir (use /usr/local/src for dependent SW, ompi)
 - [ ] update runscript to be more generic (input args: nprocs, other?)
 - [ ] add scripts to help with running across multiple hosts
