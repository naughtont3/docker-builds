#!/bin/bash
#
# Script for easy hacking/running of the build.
# See also files: 
#   - 'build-hacked.pl'
#   - 'passwd.cubswin'
#
# Assumes following steps aready completed.
#   git clone http://github.com/HobbesOSR/nvl
#   cd nvl/src/guests/simple_busybox/
#
##################################################################
# NOTES:
# - 12may2016: Using 'build-hacked.pl' instead of default to work
#     around some issues/assumptions in the build.pl script.
# - 22apr2016: Based on build instructions from Kevin Pedretti for 
#   using 'build.pl' script to build a busybox guest.
#   Summary of his steps (includes DTK):
#     1) Git checkout and build of base stuff with build.pl script
#         cd nvl/src/guests/simple_busybox/ ; build.pl ...
#     2) Build VM image  
#         ./build.pl --build-image && ./build.pl --build-isoimage
#     3) Launch 'image.iso' from Step#2
#         qemu-system-x86_64 -cdrom ./image.iso -m 2048 -smp 4 -serial stdio
#     4) Run the STKMesh example in VM
#         cd /opt/hobbes_enclave_demo  && \
#         mpirun -np 1 --allow-run-as-root \
#           ./DataTransferKitSTKMeshAdapters_STKInlineInterpolation.exe \
#           --xml-in-file=input.xml
##################################################################

die () {
    msg=$1
    echo "ERROR: $msg"
    exit 1
}

#BUILD_SCRIPT=./build.pl
BUILD_SCRIPT=./build-hacked.pl

 # General stuff in /opt/simple_busybox/install
my_simple_bb_install_basedir="/opt/simple_busybox/install"
my_simple_bb_install_man="${my_simple_bb_install_basedir}/share/man"
my_simple_bb_install_bin="${my_simple_bb_install_basedir}/bin"
my_simple_bb_install_lib="${my_simple_bb_install_basedir}/lib"

 # OpenMPI stuff in /opt/simple_busybox/openmpi-*
my_ompi_install_basedir="/opt/simple_busybox/openmpi-1.10.2"
my_ompi_install_man="${my_ompi_install_basedir}/share/man"
my_ompi_install_bin="${my_ompi_install_basedir}/bin"
my_ompi_install_lib="${my_ompi_install_basedir}/lib"

#### END CONFIG ####

##########################################

 #
 # Add install paths to EnvVars  for build assumed by 'simple_busybox' 
 # (e.g., so we find installed binaries)
 #

if ! `echo $PATH | grep -q ${my_ompi_install_bin}` ; then
    export PATH="${my_ompi_install_bin}:$PATH"
fi

if ! `echo $PATH | grep -q ${my_simple_bb_install_bin}` ; then
    export PATH="${my_simple_bb_install_bin}:$PATH"
fi

if [ "x$LD_LIBRARY_PATH" == "x" ] ; then
    export LD_LIBRARY_PATH="${my_ompi_install_lib}:${my_simple_bb_install_lib}:"
else
    if ! `echo $LD_LIBRARY_PATH | grep -q ${my_ompi_install_lib}` ; then
        export LD_LIBRARY_PATH="${my_ompi_install_lib}:$LD_LIBRARY_PATH"
    fi
    if ! `echo $LD_LIBRARY_PATH | grep -q ${my_simple_bb_install_lib}` ; then
        export LD_LIBRARY_PATH="${my_simple_bb_install_lib}:$LD_LIBRARY_PATH"
    fi
fi

if [ "x$MANPATH" == "x" ] ; then
     # Looks like we need trailing ':' to search default man dirs
    export MANPATH="${my_ompi_install_man}:${my_simple_bb_install_man}:"
else
    if ! `echo $MANPATH | grep -q ${my_ompi_install_man}` ; then
        export MANPATH="${my_ompi_install_man}:$MANPATH"
    fi
    if ! `echo $MANPATH | grep -q ${my_simple_bb_install_man}` ; then
        export MANPATH="${my_simple_bb_install_man}:$MANPATH"
    fi
fi

echo " ****"
echo "TJN-NOTE: May want to add EnvVar details in script to a 'envrc.sh' file"
echo " ****"

##########################################

# Ignoring these for now:
#            --build-pisces \
#            --build-hdf5 \
#            --build-netcdf \
#            --build-dtk \

for flag in --build-kernel \
            --build-busybox \
            --build-dropbear \
            --build-libhugetlbfs \
            --build-numactl \
            --build-hwloc \
            --build-ompi \
            --build-curl \
            ;  do

    echo "** Build: $flag **"
    $BUILD_SCRIPT $flag || die "ERROR: build of $flag failed"

done

echo ""
echo "GREAT!  The basic stuff all built, now build initramfs and ISO"
echo ""

for flag in --build-image \
            --build-isoimage \
            ; do

    echo "** Build: $flag **"
    $BUILD_SCRIPT $flag || die "ERROR: build of $flag failed"

done

echo " ****"
echo "TJN-NOTE: May want to add EnvVar details in script to a 'envrc.sh' file"
echo "  See also:"
echo "   ${my_simple_bb_install_basedir}/"
echo "   ${my_ompi_install_basedir}/"
echo " ****"

exit 0
