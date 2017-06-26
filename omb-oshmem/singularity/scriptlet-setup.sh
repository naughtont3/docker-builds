#!/bin/bash

echo "HELLO FROM SCRIPTLET-SETUP"
echo "HELLO SCRIPTLET-SETUP: HOST_FILES=$HOST_FILES"

ls ${HOST_FILES}

# Copy host files into container space
# NOTE: We just copy files directly from parent Docker build dir!
cp ../files/run-omb.sh                        ${HOST_FILES}/
cp ../files/osu-micro-benchmarks-5.3.2.tar.gz ${HOST_FILES}/

