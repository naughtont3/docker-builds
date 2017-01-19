#!/bin/bash

cd /tmp

oshrun --allow-run-as-root --mca plm isolated  -np 1 ra_shmem

cat /tmp/hpccoutf.txt
