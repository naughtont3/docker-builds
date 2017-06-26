#!/bin/bash

export SHMEM_SYMMETRIC_HEAP_SIZE=64000000
export OMP_NUM_THREADS=1
export OMP_STACKSIZE=4M
export TMPFILE='/tmp/tmpfile'
export REUSEFILE=0
export VERBOSE=1

hostfile=/tmp/myhosts

cd /tmp

#oshrun --allow-run-as-root --mca plm isolated  -np 1 ./mpi/graph500_shmem_one_sided 16

# Example for running one test 'put' 
oshrun --hostfile $hostfile -np 2 --map-by node --bind-to core --report-bindings osu_oshm_put heap
rc=$?


exit $rc
