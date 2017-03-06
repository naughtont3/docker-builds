#!/bin/bash

export PATH=/benchmarks/src/NPB/bin:$PATH

nprocs=1
class=S

## DT is a little different (ignore for now)
#mpirun --allow-run-as-root --mca plm isolated  -np 5 /benchmarks/src/NPB/bin/dt.$class.x BH

for prob in  bt cg ep ft is lu mg sp  ; do 

    echo "####################################################"
    echo "# START:  PROBLEM=$prob  NPROCS=$nprocs  CLASS=$class"
    echo "####################################################"

    mpirun --allow-run-as-root --mca plm isolated  -np $nprocs /benchmarks/src/NPB/bin/$prob.$class.$nprocs

    echo "####################################################"
    echo "# END: $prob.$nprocs.$class"
    echo "####################################################"

done


