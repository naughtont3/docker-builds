#!/bin/bash

cd /tmp

oshrun --allow-run-as-root --mca plm isolated  -np 1 gups
rc=$?

if [ -f hpccoutf.txt ] ; then
    cat hpccoutf.txt
fi

exit $rc
