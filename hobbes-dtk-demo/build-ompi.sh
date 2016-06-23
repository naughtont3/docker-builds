#!/bin/bash

ompi_prefix_path=/hobbes/local

 #
 # XXX: NOTE, we install into "<prefix>/ompi_install/"
 #
LDFLAGS=-static ./configure --prefix=${ompi_prefix_path}/ompi_install --disable-shared --enable-static --disable-dlopen --without-memory-manager --disable-vt \
&& make -j 4 LDFLAGS=-all-static  \
&& make install \
&& echo "SUCCESS - DONE"

echo "Installed to: $ompi_prefix_path/ompi_install"
