#!/bin/bash
# TJN: Thu Nov 23 23:40:10 UTC 2017

#
# NOTE: If EnvVar 'GITHUB_TOKEN' is set, will use Personal Access Token
#       for passwordless access to the ORNL-Languages Git repo.
# https://help.github.com/articles/creating-an-access-token-for-command-line-use
#

####
# BUILD PREREQS
#   - libnuma-dev
#   - bfd
#   - binutils-dev
#   - binutils-multiarch-dev
#   - flex
#   - bison
#   - gcc
#   - g++
#   - autoconf
#   - automake
#   - libtool
#   - linux-headers  (XPMEM)
#   - libelf-dev     (gelf.h by OSHMEM)
#   - libibverbs-dev (verbs.h)
####

#
# Source/Install directory
# (NOTE: We download/unpack software in the "$source_base_dir/")
#
source_base_dir=/usr/local/src
install_base_dir=/usr/local

####

#########
# ENV Vars:
#   LIBEVENT_SOURCE_DIR
#   LIBEVENT_INSTALL_DIR
#
#   PMIX_SOURCE_DIR
#   PMIX_INSTALL_DIR
#
#   OMPI_SOURCE_DIR
#   OMPI_INSTALL_DIR
#
#   XPMEM_SOURCE_DIR
#   XPMEM_INSTALL_DIR
#
#   UCX_SOURCE_DIR
#   UCX_INSTALL_DIR
#########


# Quick Hack to autoset envvar if magic file exists
if [ -f "mytoken" ] ; then
    export GITHUB_TOKEN=$(cat mytoken)
fi

# Libevent
libevent_version=2.1.8-stable
libevent_archive=https://github.com/libevent/libevent/releases/download/release-${libevent_version}/libevent-${libevent_version}.tar.gz

# PMIX
pmix_version=2.0.2
pmix_archive=https://github.com/pmix/pmix/releases/download/v${pmix_version}/pmix-${pmix_version}.tar.gz

# OpenMPI (ORTE)
ompi_version=3.0.0
ompi_archive=https://github.com/open-mpi/ompi/archive/v${ompi_version}.tar.gz

# XPMEM
xpmem_version=git-br-master
xpmem_repo=https://github.com/hjelmn/xpmem
xpmem_repo_branch=master

# UCX
ucx_version=git-br-master
ucx_repo=https://github.com/openucx/ucx.git
ucx_repo_branch=master

# ORNL-OpenSHMEM
ornloshmem_version=git-br-ucx
if [ -z "$GITHUB_TOKEN" ]; then
    ornloshmem_repo=https://github.com/ornl-languages/ornl-openshmem.git
else
    ornloshmem_repo=https://${GITHUB_TOKEN}:x-oauth-basic@github.com/ornl-languages/ornl-openshmem.git
fi
ornloshmem_repo_branch=ucx

#####################

die () {
    local emsg
    emsg="$@"

    echo "ERROR: $emsg"
    exit 1
}

usage () {
    echo "Usage: $0  [-h]"
    echo " OPTIONS:"
    echo "    -L       SKIP (L)ibevent"
    echo "    -P       SKIP (P)MIx"
    echo "    -O       SKIP (O)MPI/ORTE"
    echo "    -X       SKIP (X)PMEM"
    echo "    -U       SKIP (U)CX"
    echo "    -S       SKIP ORNL-Open(S)HMEM"
    echo ""
    echo "    -h       Print this help info"
    echo "    -d       Debug mode"
    echo ""
    echo " NOTE: If EnvVar 'GITHUB_TOKEN' is set, script will use a"
    echo "       Github 'Personal Access Token' for passwordless access"
    echo "       to the ORNL-Languages Git repo checkout."
    echo "       Otherwise must manually enter username/pass when prompted."
    echo " See Github docs:"
    echo "  https://help.github.com/articles/creating-an-access-token-for-command-line-use"
    echo ""
}

###
# MAIN
###

SKIP_LIBEVENT=0         # -L  skip (L)ibevent
SKIP_PMIX=0             # -P  skip (P)MIx
SKIP_OMPI=0             # -O  skip (O)MPI/ORTE
SKIP_XPMEM=0            # -X  skip (X)PMEM
SKIP_UCX=0              # -U  skip (U)CX
SKIP_ORNLOSHMEM=0       # -S  skip ORNL-Open(S)HMEM

opt_showhelp=0          # -h  show usage/help
DEBUG=0                 # -d  debug mode

orig_dir=$PWD
time_begin=`date`

#
# Process ARGV/cmd-line
# TODO: ADD SUPPORT FOR '--skip-<pkgname>'
#
OPTIND=1
while getopts hdLPOXUS opt ; do
    case "$opt" in
        L)  SKIP_LIBEVENT=1;;           # -L  skip (L)ibevent
        P)  SKIP_PMIX=1;;               # -P  skip (P)MIx
        O)  SKIP_OMPI=1;;               # -O  skip (O)MPI/ORTE
        X)  SKIP_XPMEM=1;;              # -X  skip (X)PMEM
        U)  SKIP_UCX=1;;                # -U  skip (U)CX
        S)  SKIP_ORNLOSHMEM=1;;         # -S  skip ORNL-Open(S)HMEM
        h)  opt_showhelp=1;;            # -h  show usage/help
        d)  DEBUG=1;;                   # -d  debug mode
    esac
done

shift $(($OPTIND - 1))
if [ "$1" = '--' ]; then
    shift
fi


if [ $DEBUG -ne 0 ] ; then
    echo "DBG:       *** DEBUG MODE ***"
    echo "DBG:   SKIP_LIBEVENT = '$SKIP_LIBEVENT'"
    echo "DBG:       SKIP_PMIX = '$SKIP_PMIX'"
    echo "DBG:       SKIP_OMPI = '$SKIP_OMPI'"
    echo "DBG:      SKIP_XPMEM = '$SKIP_XPMEM'"
    echo "DBG:        SKIP_UCX = '$SKIP_UCX'"
    echo "DBG: SKIP_ORNLOSHMEM = '$SKIP_ORNLOSHMEM'"
    echo ""
    echo "DBG: libevent_version = $libevent_version"
    echo "DBG: libevent_archive = $libevent_archive"
    echo ""
    echo "DBG:     pmix_version = $pmix_version"
    echo "DBG:     pmix_archive = $pmix_archive"
    echo ""
    echo "DBG:     ompi_version = $ompi_version"
    echo "DBG:     ompi_archive = $ompi_archive"
    echo ""
    echo "DBG:     xpmem_version = $xpmem_version"
    echo "DBG:        xpmem_repo = $xpmem_repo"
    echo "DBG: xpmem_repo_branch = $xpmem_repo_branch"
    echo ""
    echo "DBG:      ucx_version = $ucx_version"
    echo "DBG:         ucx_repo = $ucx_repo"
    echo "DBG:  ucx_repo_branch = $ucx_repo_branch"
    echo ""
    echo "DBG:      ornloshmem_version = $ornloshmem_version"
    echo "DBG:         ornloshmem_repo = $ornloshmem_repo"
    echo "DBG:  ornloshmem_repo_branch = $ornloshmem_repo_branch"
    echo ""
    echo "DBG:       ******************"
fi

if [ $opt_showhelp -ne 0 ]; then
    usage
    exit 0
fi

#-----

mkdir -p $source_base_dir

# Libevent (tar.gz)
if [ $SKIP_LIBEVENT = 0 ] ; then
    echo "BUILD LIBEVENT"

    export LIBEVENT_ARCHIVE_URL=$libevent_archive && \
    export LIBEVENT_SOURCE_DIR=$source_base_dir/libevent-${libevent_version} && \
    export LIBEVENT_INSTALL_DIR=$install_base_dir && \
    export LIBEVENT_ARCHIVE_FILE=`echo "${LIBEVENT_ARCHIVE_URL##*/}"` && \
    mkdir -p $LIBEVENT_SOURCE_DIR && \
    cd $LIBEVENT_SOURCE_DIR && \
    wget --quiet $LIBEVENT_ARCHIVE_URL && \
    tar -zxf ${LIBEVENT_ARCHIVE_FILE} -C ${LIBEVENT_SOURCE_DIR} --strip-components=1 && \
    cd ${LIBEVENT_SOURCE_DIR} && \
    ./configure \
        --prefix=${LIBEVENT_INSTALL_DIR} \
        && \
    make -j 4 && \
    make install || die "Libevent failed"

    echo "   LIBEVENT_SOURCE_DIR: $LIBEVENT_SOURCE_DIR"
    echo "  LIBEVENT_INSTALL_DIR: $LIBEVENT_INSTALL_DIR"

else
    echo "SKIP LIBEVENT"
    export LIBEVENT_SOURCE_DIR=$source_base_dir/libevent-${libevent_version}
    export LIBEVENT_INSTALL_DIR=$install_base_dir
fi


# PMIX (tar.gz)
if [ $SKIP_PMIX = 0 ] ; then
    echo "BUILD PMIX"

    export PMIX_ARCHIVE_URL=$pmix_archive && \
    export PMIX_SOURCE_DIR=$source_base_dir/pmix-${pmix_version} && \
    export PMIX_INSTALL_DIR=$install_base_dir && \
    export PMIX_ARCHIVE_FILE=`echo "${PMIX_ARCHIVE_URL##*/}"` && \
    mkdir -p $PMIX_SOURCE_DIR && \
    cd $PMIX_SOURCE_DIR && \
    wget --quiet $PMIX_ARCHIVE_URL && \
    tar -zxf ${PMIX_ARCHIVE_FILE} -C ${PMIX_SOURCE_DIR} --strip-components=1 && \
    cd ${PMIX_SOURCE_DIR} && \
    ./autogen.pl && \
    ./configure \
        --prefix=${PMIX_INSTALL_DIR} \
        --with-libevent=${LIBEVENT_INSTALL_DIR} \
        && \
    make -j 4 && \
    make install || die "PMIX failed"

    echo "   PMIX_SOURCE_DIR: $PMIX_SOURCE_DIR"
    echo "  PMIX_INSTALL_DIR: $PMIX_INSTALL_DIR"

else
    echo "SKIP PMIX"
    export PMIX_SOURCE_DIR=$source_base_dir/pmix-${pmix_version}
    export PMIX_INSTALL_DIR=$install_base_dir
fi

# OpenMPI (ORTE) (tar.gz)
if [ $SKIP_OMPI = 0 ] ; then
    echo "BUILD OMPI"

    export OMPI_ARCHIVE_URL=$ompi_archive && \
    export OMPI_SOURCE_DIR=$source_base_dir/ompi-${ompi_version} && \
    export OMPI_INSTALL_DIR=$install_base_dir && \
    export OMPI_ARCHIVE_FILE=`echo "${OMPI_ARCHIVE_URL##*/}"` && \
    mkdir -p $OMPI_SOURCE_DIR && \
    cd $OMPI_SOURCE_DIR && \
    wget --quiet $OMPI_ARCHIVE_URL && \
    tar -zxf ${OMPI_ARCHIVE_FILE} -C ${OMPI_SOURCE_DIR} --strip-components=1 && \
    cd ${OMPI_SOURCE_DIR} && \
    ./autogen.pl --no-ompi -no-oshmem && \
    ./configure \
        --prefix=${OMPI_INSTALL_DIR} \
        --with-pmix=${PMIX_INSTALL_DIR} \
        --with-libevent=${LIBEVENT_INSTALL_DIR} \
        && \
    make -j 4 && \
    make install || die "OMPI failed"

    echo "   OMPI_SOURCE_DIR: $OMPI_SOURCE_DIR"
    echo "  OMPI_INSTALL_DIR: $OMPI_INSTALL_DIR"

else
    echo "SKIP OMPI"
    export OMPI_SOURCE_DIR=$source_base_dir/ompi-${ompi_version}
    export OMPI_INSTALL_DIR=$install_base_dir
fi

# XPMEM (git)
if [ $SKIP_XPMEM = 0 ] ; then
    echo "BUILD XPMEM"

    export XPMEM_REPO_URL=$xpmem_repo && \
    export XPMEM_REPO_BRANCH=$xpmem_repo_branch && \
    export XPMEM_SOURCE_DIR=$source_base_dir/xpmem-${xpmem_version} && \
    export XPMEM_INSTALL_DIR=$install_base_dir && \
    mkdir -p $XPMEM_SOURCE_DIR && \
    cd $XPMEM_SOURCE_DIR && \
    git clone -b ${XPMEM_REPO_BRANCH} ${XPMEM_REPO_URL} ${XPMEM_SOURCE_DIR} && \
    cd ${XPMEM_SOURCE_DIR} && \
    ./autogen.sh && \
    ./configure \
        --prefix=${XPMEM_INSTALL_DIR}  \
        --with-default-prefix=${XPMEM_INSTALL_DIR} \
        --with-module=/usr/src/linux-headers-$(uname -r) \
        && \
    make -j 4 \
     || die "XPMEM failed" \
     && make install || echo "XPMEM install problem (continue anyway)"

    echo "   XPMEM_SOURCE_DIR: $XPMEM_SOURCE_DIR"
    echo "  XPMEM_INSTALL_DIR: $XPMEM_INSTALL_DIR"
    echo "TODO: LOAD XPMEM KERNEL MODULE!"

else
    echo "SKIP XPMEM"
    export XPMEM_SOURCE_DIR=$source_base_dir/xpmem-${xpmem_version}
    export XPMEM_INSTALL_DIR=$install_base_dir
    echo "TODO: LOAD XPMEM KERNEL MODULE!"
fi


# UCX (git)
if [ $SKIP_UCX = 0 ] ; then
    echo "BUILD UCX"

    export UCX_REPO_URL=$ucx_repo && \
    export UCX_REPO_BRANCH=$ucx_repo_branch && \
    export UCX_SOURCE_DIR=$source_base_dir/ucx-${ucx_version} && \
    export UCX_INSTALL_DIR=$install_base_dir && \
    mkdir -p $UCX_SOURCE_DIR && \
    cd $UCX_SOURCE_DIR && \
    git clone -b ${UCX_REPO_BRANCH} ${UCX_REPO_URL} ${UCX_SOURCE_DIR} && \
    cd ${UCX_SOURCE_DIR} && \
    ./autogen.sh && \
    ./configure \
 --with-rdmacm=no \
        --with-xpmem=${XPMEM_INSTALL_DIR} \
        --prefix=${UCX_INSTALL_DIR} \
        && \
    make -j 4 && \
    make install || die "UCX failed"

    echo "   UCX_SOURCE_DIR: $UCX_SOURCE_DIR"
    echo "  UCX_INSTALL_DIR: $UCX_INSTALL_DIR"

else
    echo "SKIP UCX"
    export UCX_SOURCE_DIR=$source_base_dir/ucx-${ucx_version}
    export UCX_INSTALL_DIR=$install_base_dir
fi


# ORNL-OpenSHMEM (git)
if [ $SKIP_ORNLOSHMEM = 0 ] ; then
    echo "BUILD ORNL-OpenSHMEM"

    export ORNLOSHMEM_REPO_URL=$ornloshmem_repo && \
    export ORNLOSHMEM_REPO_BRANCH=$ornloshmem_repo_branch && \
    export ORNLOSHMEM_SOURCE_DIR=$source_base_dir/ornloshmem-${ornloshmem_version} && \
    export ORNLOSHMEM_INSTALL_DIR=$install_base_dir && \
    mkdir -p $ORNLOSHMEM_SOURCE_DIR && \
    cd $ORNLOSHMEM_SOURCE_DIR && \
    git clone -b ${ORNLOSHMEM_REPO_BRANCH} ${ORNLOSHMEM_REPO_URL} ${ORNLOSHMEM_SOURCE_DIR} && \
    cd ${ORNLOSHMEM_SOURCE_DIR} && \
    ./autogen.sh && \
    ./configure \
        --with-ucx-rte=pmix \
        --enable-experimental \
        --prefix=${ORNLOSHMEM_INSTALL_DIR} \
        CPPFLAGS=-I${ORNLOSHMEM_INSTALL_DIR}/include \
        LDFLAGS=-L${ORNLOSHMEM_INSTALL_DIR}/lib \
        && \
    make -j 4 && \
    make install || die "ORNLOSHMEM failed"

    echo "   ORNLOSHMEM_SOURCE_DIR: $ORNLOSHMEM_SOURCE_DIR"
    echo "  ORNLOSHMEM_INSTALL_DIR: $ORNLOSHMEM_INSTALL_DIR"

else
    echo "SKIP ORNLOSHMEM"
    export ORNLOSHMEM_SOURCE_DIR=$source_base_dir/ornloshmem-${ornloshmem_version}
    export ORNLOSHMEM_INSTALL_DIR=$install_base_dir
fi


#-----
time_end=`date`
cd $orig_dir

echo "##################################################################"
echo "  Source dir: $source_base_dir/"
echo " Install dir: $install_base_dir/"
echo ""
echo "  Start time: $time_begin"
echo " Finish time: $time_end"
echo "##################################################################"

