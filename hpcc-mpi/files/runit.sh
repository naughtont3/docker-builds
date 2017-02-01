#!/bin/bash

cd /usr/local/src/hpcc-1.5.0

mpirun --allow-run-as-root --mca plm isolated  -np 1 hpcc

