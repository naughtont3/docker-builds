#!/bin/bash

export PATH=/benchmarks/src/HPCC:$PATH

mpirun  -np 2 /benchmarks/src/HPCC/hpcc

