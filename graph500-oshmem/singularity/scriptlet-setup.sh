#!/bin/bash

echo "HELLO FROM SCRIPTLET-SETUP"
echo "HELLO SCRIPTLET-SETUP: HOST_FILES=$HOST_FILES"

ls ${HOST_FILES}

# Copy host files into container space
# NOTE: We just copy files directly from parent Docker build dir!
cp ../files/run-graph500.sh         ${HOST_FILES}/
cp ../files/make.inc                ${HOST_FILES}/
cp ../files/graph500_openshmem-master_mpi_Makefile.diff ${HOST_FILES}/
cp ../files/graph500_openshmem-master-02f51b620873997c9160f0eae1fc961c0188d2d7.tar.bz2 ${HOST_FILES}/
cp ../files/graph500-2.1.4.tar.bz2  ${HOST_FILES}/

