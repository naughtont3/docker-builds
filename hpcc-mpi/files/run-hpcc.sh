#!/bin/bash

export PATH=/benchmarks/src/HPCC:$PATH

mpirun --allow-run-as-root --mca plm isolated  -np 2 /benchmarks/src/HPCC/hpcc

