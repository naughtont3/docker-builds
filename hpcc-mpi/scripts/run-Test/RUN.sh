#!/bin/bash

#hostfile=/tmp/2017.03.13-run-docker-net-overlayV2/d-hosts4
#hostfile=/benchmarks/runs/Test1/d-hosts4
hostfile=/tmp/2017.05.07-hpcc-np128-host/hosts4.10G.slots128

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
    echo RC=$?

    echo "Sleep 5"
    sleep 5

done
echo "=====DONE===="
echo -n "FINISH-TIME: " ; date
