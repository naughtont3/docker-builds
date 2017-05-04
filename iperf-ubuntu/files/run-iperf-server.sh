#!/bin/bash

#export PATH=/benchmarks/src/IPERF:$PATH
export PATH=/benchmarks/src/local/bin:$PATH

#SERVER_IPADDR=10.255.1.149
SERVER_IPADDR=10.0.2.3

LOGFILE=/tmp/2017.05.04-iperf-server.log
IPERF_OPTIONS=

iperf3 -A 0 -fg $IPERF_OPTIONS --logfile $LOGFILE -s -B $SERVER_IPADDR

