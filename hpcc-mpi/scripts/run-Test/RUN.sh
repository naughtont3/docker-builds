#!/bin/bash

#hostfile=/tmp/2017.03.13-run-docker-net-overlayV2/d-hosts4
#hostfile=/benchmarks/runs/Test1/d-hosts4
hostfile=/tmp/2017.05.07-hpcc-np128-host/hosts4.10G.slots128

#hostfile=/home/3t4/projects/quarterlyruns/2017.05.10-hpcc-np128-sing/hosts4.10G.slots128
sing_image=/home/3t4/projects/quarterlyruns/image/hpcc-mpi-V3.img

if [ "x$USER" == "x" ] ; then
	export USER=mpiuser
fi

echo "GETTING STARTED - sleep 10 (for nohup disconnect)..."
sleep 10

echo -n "START-TIME: " ; date

if [ ! -x ./run-hpcc.sh ] ; then
    echo "ERROR: Missing './run-hpcc.sh'"
    exit 1
fi

for i in {1..5} ; do 

    echo "Iteration: $i"

    ./run-hpcc.sh -h $hostfile -r 128   -n 100000 -b 250 -p 2 -q 64  -L $i. 
    # --SINGULARITY-VARIANT--
    #./run-hpcc.sh -S -I $sing_image -h $hostfile -r 128  -n 100000 -b 250 -p 1 -q 128  -L $i.
    # --DBG-SINGULARITY--
    #./run-hpcc.sh -D -S -I $sing_image -h $hostfile -r 128  -n 100 -b 8 -p 1 -q 128  -L $i.dbg.
    echo RC=$?

    echo "Sleep 5"
    sleep 5

done
echo "=====DONE===="
echo -n "FINISH-TIME: " ; date
