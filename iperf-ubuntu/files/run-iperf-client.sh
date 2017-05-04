#!/bin/bash

#export PATH=/benchmarks/src/IPERF:$PATH
export PATH=/benchmarks/src/local/bin:$PATH

# IP Address where IPERF server runs
#SERVER_IPADDR=10.255.1.149
SERVER_IPADDR=10.0.2.3

# Positive integer
NUM_LOOPS=10

# Time to sleep between loops
SLEEPTIME=1

LOGFILE=/tmp/2017.05.04-iperf-client-10G-tcp.log
IPERF_OPTIONS="-n 10G"

#-------

if [ ! -x /usr/bin/seq ] ; then
   echo "ERROR: missing '/usr/bin/seq' executable"
   exit 1
fi


# Show interfaces
if [ -x /sbin/ifconfig ] ; then
    echo "# INFO: === Network Interfaces ==="
    /sbin/ifconfig -a
    echo "# INFO: =========================="
fi


for cnt in `/usr/bin/seq 1  $NUM_LOOPS` ; do 

    echo "# INFO: === $cnt ===" 

     # Client (TCP)
     echo "CMD: iperf3 -A 0 -fg -T $cnt $IPERF_OPTIONS --logfile $LOGFILE -c $SERVER_IPADDR"
     iperf3 -A 0 -fg -T $cnt $IPERF_OPTIONS --logfile $LOGFILE -c $SERVER_IPADDR 
 
     # Client (UDP)
     #iperf3 -A 0 -fg -T $cnt $IPERF_OPTIONS --logfile $LOGFILE -c $SERVER_IPADDR -b10G
 
     echo "# INFO: === Sleep $SLEEPTIME ==="
     sleep $SLEEPTIME

done
