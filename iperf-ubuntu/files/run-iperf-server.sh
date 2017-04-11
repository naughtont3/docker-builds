#!/bin/bash

export PATH=/benchmarks/src/IPERF:$PATH

SERVER_IPADDR=10.255.1.149

iperf3 -s -B $SERVER_IPADDR

