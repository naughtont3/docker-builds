#!/bin/bash

export SHMEM_SYMMETRIC_HEAP_SIZE=64000000
export OMP_NUM_THREADS=1
export OMP_STACKSIZE=4M
export TMPFILE='/tmp/tmpfile'
export REUSEFILE=0
export VERBOSE=1

cd /tmp

#oshrun --verbose -np 2 --mca sshmem mmap ./make-edgelist-shmem -o /tmp/file2 -V -s 14 -e 16 

oshrun --allow-run-as-root --mca plm isolated  -np 1 omp-csr
rc=$?

#if [ -f hpccoutf.txt ] ; then
#    cat hpccoutf.txt
#fi

exit $rc
