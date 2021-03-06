#!/bin/bash 
# 
# TJN: REWRITTEN VERSION OF CHARLOTTE KOTAS' RUN SCRIPT
#      NOTE - CURRENTLY I ASSUME WE HAVE C3 SETUP AND USABLE!.
#      See also help output: './run-hpcc.sh -H' 
#
# This script should execute the HPCC binaries 
# Copy executable and input file into new directory and run it
#
# USAGE:
#    cp hpcc /tmp/tjnhpcc/hpcc
#    cd /tmp/tjnhpcc/
#     #            -h HOSTFILE -r NPROCS -n N     -b NB  -p P -q Q
#    ./run-hpcc.sh -h hosts4   -r 4      -n 28000 -b 250 -p 1 -q 4
################################################################
# NOTES: 
#  - v1.0: Add version when update for Singularity usage.
#          In this version, we use 'hpcc' inside "$sing_image",
#          so should check for existence in "$sing_image" paths.
#          For now we just add additonal hardcode for Singularity 
#          path to 'hpcc' (HPCC_SINGULARITY).  This is only required
#          b/c we use fully-qualified paths, easier if depend on PATH.
################################################################

# NOTE: We create our 'run' directories under this "TOPDIR"
TOPDIR=$PWD

SCRIPT='run-hpcc.sh'
VERSION='v1.0+'


#MPIRUN=/usr/bin/mpirun
MPIRUN=/sw/TJN/quarterlyruns/bin/mpirun
CEXEC=/sw/usr/bin/cexec
HPCC_BASEDIR=/tmp/tjnhpcc
HPCC=$HPCC_BASEDIR/hpcc
HPCC_SINGULARITY=/benchmarks/src/HPCC/hpcc
#SINGULARITY=/sw/TJN/bin/singularity
SINGULARITY=/sw/TJN/quarterlyruns/bin/singularity

# Add any OpenMPI MCA params for 'mpirun' cmd-line 
#ompi_mca_params="-mca btl ^openib -mca btl_tcp_if_include eth0.300 -mca oob_tcp_if_include eth0.300 "
ompi_mca_params=""

# Add any additional options for 'mpirun' cmd-line
#ompi_run_options=" --report-bindings --bind-to hwthread ";
#ompi_run_options=" --report-bindings --bind-to hwthread -x SINGULARITY_NOSESSIONCLEANUP=1"
ompi_run_options=""

DEBUG=0

# Stash our original directory location
SAVED_ORIGDIR=$PWD

die () {
    msg=$1
    echo "ERROR: $msg"

    # always return where we started
    cd $SAVED_ORIGDIR

    exit 1
}

usage () {
    echo "Usage: $SCRIPT  [OPTIONS] -h HOSTFILE -r nRanks  -n HPCC_N  -b HPCC_NB -p HPCC_P -q HPCC_Q"
    echo "    -h       MPI Hostfile (--hostfile)"
    echo "    -r       MPI Number of ranks (--np)"
    echo "    -n       HPCC 'N' problem size (N)"
    echo "    -b       HPCC 'NB' block size (NB)"
    echo "    -p       HPCC 'P' prcess rows (P)"
    echo "    -q       HPCC 'Q' prcess columns (Q)"
    echo "    -S       Singularity flag (run with singularity)"
    echo "    -I       Image for Singularity (requires '-S' too)"
    echo "    -L       (Optional) Label to prefix on rundir name"
    echo "    -H       Print this help info"
    echo "    -V       Show script version"
    echo "    -D       Enable debug for run script (dry-run)"
    echo "Example:"
    echo "     #         -h HOSTFILE -r NPROCS -n N     -b NB  -p P -q Q"
    echo "   run-hpcc.sh -h hosts4   -r 4      -n 28000 -b 250 -p 1 -q 4"
    echo "   run-hpcc.sh -h hosts4   -r 4      -n 28000 -b 250 -p 1 -q 4 -S -I /sw/hpcc.img"
}

###
# MAIN
###

# Die early if missing key items
[ -d "$TOPDIR"  ] || die "Missing top-dir '$TOPDIR'"
[ -x "$MPIRUN"  ] || die "Missing executable (mpirun) '$MPIRUN'"
[ -x "$CEXEC"   ] || die "Missing executable (cexec) '$CEXEC'"

####
# TJN: Quick C3 sanity check
####
cexec hostname > /dev/null
[ $? == 0 ] || die "Require 'cexec' failed (setup C3 for system)"


mpi_hostfile=
mpi_nprocs=
hpcc_n=
hpcc_nb=
hpcc_p=
hpcc_q=
sing_image=
sing_flag=0
print_help_info=0
print_version_info=0

#
# Process ARGV/cmd-line
#
OPTIND=1
#while getopts Hh:r:n:b:p:q: opt ; do
while getopts VHSI:DL:h:r:n:b:p:q: opt ; do
    case "$opt" in
        h)  mpi_hostfile="$OPTARG";;          # '-h' mpi hostfile
        r)  mpi_nprocs="$OPTARG";;            # '-r' mpi nprocs
        n)  hpcc_n="$OPTARG";;                # '-n' hpcc 'N' value
        b)  hpcc_nb="$OPTARG";;               # '-b' hpcc 'NB'  value
        p)  hpcc_p="$OPTARG";;                # '-p' hpcc 'P'  value
        q)  hpcc_q="$OPTARG";;                # '-q' hpcc 'Q'  value
        I)  sing_image="$OPTARG";;            # '-I' singularity image name
        S)  sing_flag=1;;                     # '-S' singularity flag
        L)  run_label="$OPTARG";;             # '-L' optional rundir "label"
        D)  DEBUG=1;;                         # '-D' enable script debug
        H)  print_help_info=1;;               # '-H' print help/usage info
        V)  print_version_info=1;;            # '-V' print version info
    esac
done

shift $(($OPTIND - 1))
if [ "$1" = '--' ]; then
    shift
fi

[ $DEBUG -ne 0 ] && echo "DBG:       mpi_hostfile=$mpi_hostfile"
[ $DEBUG -ne 0 ] && echo "DBG:         mpi_nprocs=$mpi_nprocs"
[ $DEBUG -ne 0 ] && echo "DBG:             hpcc_n=$hpcc_n"
[ $DEBUG -ne 0 ] && echo "DBG:            hpcc_nb=$hpcc_nb"
[ $DEBUG -ne 0 ] && echo "DBG:             hpcc_p=$hpcc_p"
[ $DEBUG -ne 0 ] && echo "DBG:             hpcc_q=$hpcc_q"
[ $DEBUG -ne 0 ] && echo "DBG:          run_label=$run_label"
[ $DEBUG -ne 0 ] && echo "DBG:         sing_image=$sing_image"
[ $DEBUG -ne 0 ] && echo "DBG:          sing_flag=$sing_flag"
[ $DEBUG -ne 0 ] && echo "DBG: print_version_info=$print_version_info"
[ $DEBUG -ne 0 ] && echo "DBG:    print_help_info=$print_help_info"

if [ $print_help_info == 1 ] ; then 
    #echo "DBG: SHOW HELP"
    usage 
    exit 0
fi

if [ $print_version_info == 1 ] ; then 
    #echo "DBG: SHOW VERSION"
    echo "$SCRIPT $VERSION"
    exit 0
fi

# Process/Check args
bad_args=0

if [ "x$mpi_hostfile" == "x" ] ; then
    echo "Error: missing '-h' option with MPI hostfile"
    bad_args=1
fi

if [ "x$mpi_nprocs" == "x" ] ; then
    echo "Error: missing '-r' option with MPI nprocs"
    bad_args=1
fi

if [ "x$hpcc_n" == "x" ] ; then
    echo "Error: missing '-n' option with HPCC 'N' value"
    bad_args=1
fi

if [ "x$hpcc_nb" == "x" ] ; then
    echo "Error: missing '-b' option with HPCC 'NB' value"
    bad_args=1
fi

if [ "x$hpcc_p" == "x" ] ; then
    echo "Error: missing '-p' option with HPCC 'P' value"
    bad_args=1
fi

if [ "x$hpcc_q" == "x" ] ; then
    echo "Error: missing '-q' option with HPCC 'Q' value"
    bad_args=1
fi

# Check arg contents
if ! [[ -f "$mpi_hostfile" ]] ; then
    echo "Error: Bad argument: '-h $mpi_hostfile' (should be fully-qualified filename)"
    bad_args=1
fi

if ! [[ "$mpi_nprocs" =~ ^[0-9]+$ ]] ; then
    echo "Error: Bad argument: '-r $mpi_nprocs' (should be integer)"
    bad_args=1
fi

if ! [[ "$hpcc_n" =~ ^[0-9]+$ ]] ; then
    echo "Error: Bad argument: '-n $hpcc_n' (should be integer)"
    bad_args=1
fi

if ! [[ "$hpcc_nb" =~ ^[0-9]+$ ]] ; then
    echo "Error: Bad argument: '-b $hpcc_nb' (should be integer)"
    bad_args=1
fi

if ! [[ "$hpcc_p" =~ ^[0-9]+$ ]] ; then
    echo "Error: Bad argument: '-p $hpcc_p' (should be integer)"
    bad_args=1
fi

if ! [[ "$hpcc_q" =~ ^[0-9]+$ ]] ; then
    echo "Error: Bad argument: '-q $hpcc_q' (should be integer)"
    bad_args=1
fi

if [ $sing_flag == 1 ] ; then

    if [ "x$sing_image" == "x" ] ; then
        echo "Error: missing required '-I' option with Singularity (-S)"
        bad_args=1
    else 
        if ! [[ -f "$sing_image" ]] ; then
            echo "Error: missing Singularity image '$sing_image'"
            bad_args=1
        fi
    fi

fi

if [ $bad_args -ne 0 ]; then 
    #echo "DBG: BAD ARGS"
    echo ""
    usage
    exit 1
fi

# quick sanity check
tmp_nprocs=$(echo "$hpcc_p * $hpcc_q" | bc)
if [ $tmp_nprocs != $mpi_nprocs ] ; then
    echo "ERROR: MPI-nprocs ($mpi_nprocs) not match HPCC PxQ size ($tmp_nprocs)"
    echo "  double check '-r' ($mpi_nprocs) and '-p' ($hpcc_p) '-q' ($hpcc_q) values"
    exit 1
fi

# Sanity check (if selected to use Singularity)
if [ $sing_flag == 1 ] ; then
    # Use Singularity 
    [ -x "$SINGULARITY"  ] || die "Missing executable (singularity) '$SINGULARITY'"
fi

if [ $sing_flag == 1 ] ; then
    # Use Singularity
    $SINGULARITY exec $sing_image ls $HPCC_SINGULARITY >& /dev/null
    [ $? == 0 ] || die "Missing executable (hpcc) [$sing_image] '$HPCC_SINGULARITY'"
else    
    # Normal (non-singularity)
    [ -x "$HPCC"    ] || die "Missing executable (hpcc) '$HPCC'"
fi

###############################################
# END OF ARG PARSING 
###############################################

echo "Using  top-dir: '$TOPDIR'"
echo "Using   mpirun: '$MPIRUN'"
[ $sing_flag == 1 ] && echo "Using   singularity: '$SINGULARITY'"

# The MPIRUN command-line
if [ $sing_flag == 1 ] ; then 
     # Using Singularity
    command="time -p $MPIRUN $ompi_run_options $ompi_mca_params -np $mpi_nprocs --hostfile $mpi_hostfile $SINGULARITY exec $sing_image $HPCC_SINGULARITY"
else
    # Normal (non-singularity)
    command="time -p $MPIRUN $ompi_run_options $ompi_mca_params -np $mpi_nprocs --hostfile $mpi_hostfile $HPCC"
fi

if [ $DEBUG == 1 ] ; then

     # Just show the command we would have run
    echo "NOTE:  RUNDIR WOULD HAVE BEEN CREATED WITH INPUT FILE."
    echo "COMMAND: $command"

else

    # Create unique run (output) directory
    RUNDIR=`mktemp -d $TOPDIR/${run_label}run.XXXXXX` || die "failed to create unique run directory"
    [ -d "$RUNDIR"  ] || die "Missing run-dir '$RUNDIR' (tmpdir create failed?)"

    echo "Using  run-dir: '$RUNDIR'"

    # Create HPCC input file...
    # Modify variables to change test runs
    echo "Creating HPCC input file '$RUNDIR/hpccinf.txt'"
    cat << EOF >  $RUNDIR/hpccinf.txt
HPLinpack benchmark input file
Innovative Computing Laboratory, University of Tennessee
hpccoutf.txt output file name (if any)
8            device out (6=stdout,7=stderr,file)
1            # of problems sizes (N)
$hpcc_n      Ns   # EDIT: 'N' value
1            # of NBs
$hpcc_nb          NBs # EDIT: 'NB' value
0            PMAP process mapping (0=Row-,1=Column-major)
1            # of process grids (P x Q)
$hpcc_p         Ps # EDIT: 'P' value
$hpcc_q         Qs # EDIT: 'Q' value
16.0         threshold
1            # of panel fact
2            PFACTs (0=left, 1=Crout, 2=Right)
1            # of recursive stopping criterium
4            NBMINs (>= 1)
1            # of panels in recursion
2            NDIVs
1            # of recursive panel fact.
1            RFACTs (0=left, 1=Crout, 2=Right)
1            # of broadcast
1            BCASTs (0=1rg,1=1rM,2=2rg,3=2rM,4=Lng,5=LnM)
1            # of lookahead depth
1            DEPTHs (>=0)
2            SWAP (0=bin-exch,1=long,2=mix)
64           swapping threshold
0            L1 in (0=transposed,1=no-transposed) form
0            U  in (0=transposed,1=no-transposed) form
1            Equilibration (0=no,1=yes)
8            memory alignment in double (> 0)
##### This line (no. 32) is ignored (it serves as a separator). ######
0                               Number of additional problem sizes for PTRANS
1200 10000 30000                values of N
0                               number of additional blocking sizes for PTRANS
40 9 8 13 13 20 16 32 64        values of NB
EOF


    ####
    # TJN: For now we'll just assume we can run C3 tools
    #      and working with a "cluster" like set of nodes.
    ####
    # 1) Above created hpcc inputfile within rundir
    # 2) Copy 'hpcc' binary to rundir (if not Singularity)
    if [ $sing_flag == 1 ] ; then
        echo "INFO: Singularity - No need to copy 'hpcc' to $RUNDIR"
    else
        cp $HPCC $RUNDIR
    fi

    # 3) create rundir on (all) remote nodes
    cexec mkdir -p $RUNDIR
    # 4) push inputfile and executable to (all) remote nodes
    if [ $sing_flag == 1 ] ; then
        echo "INFO: Singularity - No need to cpush 'hpcc' to $RUNDIR"
    else
        cpush $HPCC                $RUNDIR/hpcc
    fi

    cpush $RUNDIR/hpccinf.txt  $RUNDIR/hpccinf.txt


    # Move to "run diretory"
    cd $RUNDIR

    # Backup any existing output file (should not happen)
    if [ -f "$RUNDIR/hpccoutf.txt" ] ; then
        mv $RUNDIR/hpccoutf.txt $RUNDIR/hpccoutf.txt.BAK-$$
    fi

    ############################
    # RUN THE TEST
    ############################
    time -p $command

    #####
    # XXX: HACK
    # TJN: WE ALSO 'cget' ANY REMOTE OUTPUT FILES (C3 suffixes filename)
    #      JUST IN CASE WE RUN RANK-0 ON REMOTE NODE. Ignore any error for
    #      if we did not have output on a node
    node_outdir=`basename $RUNDIR`
    cget $RUNDIR/hpccoutf.txt node_output.${node_outdir} > /dev/null
    #####

    # Save/rename input and output files
    if [ -f $RUNDIR/hpccoutf.txt ] ; then
        # may not have output file (if RANK-0 was remote)
        mv $RUNDIR/hpccoutf.txt $RUNDIR/hpccoutf.txt.$hpcc_p.$hpcc_q.$hpcc_n.$hpcc_nb 
    fi
    cp $RUNDIR/hpccinf.txt  $RUNDIR/hpccinf.txt.$hpcc_p.$hpcc_q.$hpcc_n.$hpcc_nb

    # Return to original directory
    cd $SAVED_ORIGDIR

    echo "##################################################################"
    echo " Results dir: $RUNDIR"
    echo "     Input: hpccinf.txt.$hpcc_p.$hpcc_q.$hpcc_n.$hpcc_nb"
    #echo "    Output: hpccoutf.txt.$hpcc_p.$hpcc_q.$hpcc_n.$hpcc_nb"
    echo "    (note: any remote output files will be in node_output.${node_outdir}/)"
    echo "##################################################################"

fi

exit 0
