#!/bin/bash

export PATH=/benchmarks/src/IPERF:$PATH

# IP Address where IPERF server runs
SERVER_IPADDR=10.255.1.149

# Positive integer
NUM_LOOPS=10

# Time to sleep between loops
SLEEPTIME=1

#-------

# Show interfaces
if [ -x /sbin/ifconfig ] ; then
    echo "# INFO: === Network Interfaces ==="
    /sbin/ifconfig -a
    echo "# INFO: =========================="
fi


for cnt in {1..$NUM_LOOPS} ; do 

    echo "# INFO: === $cnt ===" 

    # Client (TCP)
    iperf3 -T $cnt -c $SERVER_IPADDR 

    # Client (UDP)
    #iperf3 -T $cnt -c $SERVER_IPADDR -b10G

    echo "# INFO: === Sleep $SLEEPTIME ==="
    sleep $SLEEPTIME

done
