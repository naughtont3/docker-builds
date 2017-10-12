#!/usr/bin/env perl
# Based on original script from Charlotte Kotas ('postprocessscript-MPI.sh')
#
# USAGE: 
#    ./grok-hpcc.pl --input hpccoutf.txt --output hpcc-summary.txt
#
# Script to pull data from files associated with HPCG run

use strict;
use POSIX;
use English;
use Getopt::Long qw(:config no_ignore_case auto_abbrev);


#------

###
# MAIN
###

my $opt_help = 0;
my $opt_debug = 0;
my $opt_show_fields = 0;
my $input_file = "";
my $output_file = "";

#
# Process arguments (argv)
#

if (parse_input() != EXIT_SUCCESS) {
    usage (EXIT_FAILURE);
}

if ($opt_help > 0) {
    # Its ok to (just) ask for help! :-)
    usage (EXIT_SUCCESS);
}

if (0 != $opt_show_fields) {
    my $cnt=1;

    # Just show fields and exit
    foreach my $field ( qw(HPL_N HPL_NB HPL_P HPL_Q HPL_Tflops CommWorldProcs MaxPingPongLatency_usec MaxPingPongBandwidth_GBytes MinPingPongLatency_usec MinPingPongBandwidth_GBytes AvgPingPongLatency_usec AvgPingPongBandwidth_GBytes RandomlyOrderedRingLatency_usec RandomlyOrderedRingBandwidth_GBytes NaturallyOrderedRingLatency_usec NaturallyOrderedRingBandwidth_GBytes HPL_time PTRANS_residual PTRANS_n PTRANS_nb PTRANS_nprow PTRANS_npcol PTRANS_time PTRANS_GBs STREAM_VectorSize STREAM_Threads StarSTREAM_Copy StarSTREAM_Scale StarSTREAM_Add StarSTREAM_Triad SingleSTREAM_Copy SingleSTREAM_Scale SingleSTREAM_Add SingleSTREAM_Triad) ) {
        print " $cnt: $field\n";
        $cnt++;
    }

    exit (EXIT_SUCCESS);
}

if ( ! $output_file || ! $input_file ) {
    output_err("Missing required arguments");
    output_err("   Input-file: '$input_file'");
    output_err("  Output-file: '$output_file'");
    usage (EXIT_FAILURE);
}

# Check: missing arg OR file (already) exist
if ( -f $output_file ) {
    output_err("Output file already exists '$output_file' (avoid overwrite)"); 
    if ($ERRNO) {
        output_err("$ERRNO '$output_file'");
    }
    usage (EXIT_FAILURE);
}

# Check: missing arg OR *not* file exist
if ( ! $input_file || ! -f $input_file ) {
    output_err("Missing '--input FILE'");
    if ($ERRNO) {
        output_err("$ERRNO '$input_file'");
    }
    usage (EXIT_FAILURE);
}

if ($opt_debug) {
    output_info ("DBG: opt_help '$opt_help'");
    output_info ("DBG:   output '$output_file'");
    output_info ("DBG:    input '$input_file'");
    output_info ("DBG:    debug '$opt_debug'");
    output_info ("DBG:   fields '$opt_show_fields'");
}

if (0 != grok_hpcc_data($input_file, $output_file) ) {
    output_err("Failed to process HPCC data\n");
    exit (EXIT_FAILURE);
}

print "Generated: $output_file\n";
exit (EXIT_SUCCESS);


####
# Sub-rtns
####

sub sigwarn_handler
{
    my $signo = @_;
    output_err("SIGWARN: signo='$signo'");
}

sub sigdie_handler
{
    my $signo = @_;
    output_err("SIGDIE: signo='$signo'");
}

# TODO: We handle the following signals for GetOptions parsing,
#         $SIG{__DIE__}
#         $SIG{__WARN__}
# See: http://perldoc.perl.org/Getopt/Long.html#Return-values-and-Errors
# 
# Example:
#     # Backup orig
#    my $sigwarn_orig = $SIG{__WARN__};
#    my $sigdie_orig  = $SIG{__DIE__};
#
#     # Set temporary disposition
#    $SIG{__WARN__} = 'sigwarn_handler';
#    $SIG{__DIE__}  = 'sigdie_handler';
#
#     ...<do stuff>...
#
#     # Restore orig
#    $SIG{__WARN__} = $sigwarn_orig;
#    $SIG{__DIE__}  = $sigdie_orig;
#     
sub parse_input
{
    my $sigwarn_orig = $SIG{__WARN__};
    my $sigdie_orig  = $SIG{__DIE__};

    $SIG{__WARN__} = 'sigwarn_handler';
    $SIG{__DIE__}  = 'sigdie_handler';

	my $rc = eval { GetOptions(
	 "help"          => \$opt_help,
     "output=s"      => \$output_file,
     "input=s"       => \$input_file,
     "fields"        => \$opt_show_fields,
     "debug|verbose" => \$opt_debug); } ;

    $SIG{__WARN__} = $sigwarn_orig;
    $SIG{__DIE__}  = $sigdie_orig;

    return ( ($rc > 0)? EXIT_SUCCESS : EXIT_FAILURE );
}

sub usage
{
    my $retval = shift;
    my $script = `basename $0`;      # XXX: Trim down script name
    chomp($script);

    output_info("Usage: $script [OPTIONS] --input INFILE --output OUTFILE");
    output_info("");
    output_info("    --input  FILE.txt    Input data file");
    output_info("    --output FILE.txt    Output summary file");

    # Optional args
    output_info("    --debug              Print debug (verbose) output");
    output_info("    --help               Print this usage information");
    output_info("    --fields             Print fields to be parsed from data");

    output_info("Example:");
    output_info("  $script  --input hpccoutf.txt --output hpcc-summary.txt");

    exit ($retval);
}


sub output_err
{
	my @output = @_;
    my $output_err_prefix = "Error: ";

	print $output_err_prefix . join("$output_err_prefix", @output) . "\n";
}

sub output_info
{
	my @output = @_;
    my $output_info_prefix = "";

	print $output_info_prefix . join("$output_info_prefix", @output) . "\n";
}


# Input: 
#    o input_file  -- HPCC-Results file
#    o output_file -- Post-Processed summary of HPCC results
#                     (on success creates/writes this output_file)
# Return: 
#    o 0 (Success)
#    o 1 (Failure)
sub grok_hpcc_data
{
    my $input_file = shift;
    my $output_file = shift;
    my @in_data; 
    my @out_data; 
    my @rslt;
    my $junk;
    my ($hpcc_hpl_n, $hpcc_hpl_nb, $hpcc_hpl_p, $hpcc_hpl_q, $hpcc_status);
    my ($hpcc_hpl_tflops, $hpcc_mpi_nprocs, 
        $hpcc_max_pp_latency, $hpcc_max_pp_bandw, 
        $hpcc_min_pp_latency, $hpcc_min_pp_bandw, 
        $hpcc_avg_pp_latency, $hpcc_avg_pp_bandw, 
        $hpcc_rand_ring_latency, $hpcc_rand_ring_bandw, 
        $hpcc_ordered_ring_latency, $hpcc_ordered_ring_bandw);
    my ($hpcc_hpl_time,
        $hpcc_ptrans_residual, $hpcc_ptrans_n, $hpcc_ptrans_nb,
        $hpcc_ptrans_nprow, $hpcc_ptrans_npcol, $hpcc_ptrans_time,
        $hpcc_ptrans_bandw,
        $hpcc_stream_vecsize, $hpcc_stream_threads,
        $hpcc_stream_star_copy, $hpcc_stream_star_scale,
        $hpcc_stream_star_add, $hpcc_stream_star_triad,
        $hpcc_stream_single_copy, $hpcc_stream_single_scale,
        $hpcc_stream_single_add, $hpcc_stream_single_triad);

    # Open input file handle
    if ( ! open(INFILE, "<$input_file") ) {
        print "ERROR: Failed on input file '$input_file' - $!\n";
        return 1;
    }

    # Read contents of input file (removing newlines)
    @in_data = <INFILE>;
    chomp(@in_data);

    # Close input file handle
    close(INFILE);

     # HPL_N=140000
    @rslt = grep (/HPL_N=/, @in_data);
    ($junk, $hpcc_hpl_n) = split ("=", $rslt[0]);

     # HPL_NB=128
    @rslt = grep (/HPL_NB=/, @in_data);
    ($junk, $hpcc_hpl_nb) = split ("=", $rslt[0]);

     # HPL_nprow=2
    @rslt = grep (/HPL_nprow=/, @in_data);
    ($junk, $hpcc_hpl_p) = split ("=", $rslt[0]);

     # HPL_npcol=64
    @rslt = grep (/HPL_npcol=/, @in_data);
    ($junk, $hpcc_hpl_q) = split ("=", $rslt[0]);

     # HPL_Tflops=0.22763
    @rslt = grep (/HPL_Tflops=/, @in_data);
    ($junk, $hpcc_hpl_tflops) = split ("=", $rslt[0]);

     # CommWorldProcs=128
    @rslt = grep (/CommWorldProcs=/, @in_data);
    ($junk, $hpcc_mpi_nprocs) = split ("=", $rslt[0]);

     # MaxPingPongLatency_usec=73.2541
    @rslt = grep (/MaxPingPongLatency_usec=/, @in_data);
    ($junk, $hpcc_max_pp_latency) = split ("=", $rslt[0]);

     # MaxPingPongBandwidth_GBytes=4.489
    @rslt = grep (/MaxPingPongBandwidth_GBytes=/, @in_data);
    ($junk, $hpcc_max_pp_bandw) = split ("=", $rslt[0]);

     # MinPingPongLatency_usec=6.7502
    @rslt = grep (/MinPingPongLatency_usec=/, @in_data);
    ($junk, $hpcc_min_pp_latency) = split ("=", $rslt[0]);

     # MinPingPongBandwidth_GBytes=0.114633
    @rslt = grep (/MinPingPongBandwidth_GBytes=/, @in_data);
    ($junk, $hpcc_min_pp_bandw) = split ("=", $rslt[0]);

     # AvgPingPongLatency_usec=47.1819
    @rslt = grep (/AvgPingPongLatency_usec=/, @in_data);
    ($junk, $hpcc_avg_pp_latency) = split ("=", $rslt[0]);

     # AvgPingPongBandwidth_GBytes=0.941036
    @rslt = grep (/AvgPingPongBandwidth_GBytes=/, @in_data);
    ($junk, $hpcc_avg_pp_bandw) = split ("=", $rslt[0]);

     # RandomlyOrderedRingLatency_usec=89.194
    @rslt = grep (/RandomlyOrderedRingLatency_usec=/, @in_data);
    ($junk, $hpcc_rand_ring_latency) = split ("=", $rslt[0]);

     # RandomlyOrderedRingBandwidth_GBytes=0.004664
    @rslt = grep (/RandomlyOrderedRingBandwidth_GBytes=/, @in_data);
    ($junk, $hpcc_rand_ring_bandw) = split ("=", $rslt[0]);

     # NaturallyOrderedRingLatency_usec=40.3881
    @rslt = grep (/NaturallyOrderedRingLatency_usec=/, @in_data);
    ($junk, $hpcc_ordered_ring_latency) = split ("=", $rslt[0]);

     # NaturallyOrderedRingBandwidth_GBytes=0.004664
    @rslt = grep (/NaturallyOrderedRingBandwidth_GBytes=/, @in_data);
    ($junk, $hpcc_ordered_ring_bandw) = split ("=", $rslt[0]);

    ###############
    # TJN: Additional fields are added at end to avoid
    #      ordering mismatch w/ previously generated charts/sheets.
    ###############

     # HPL_time=22749.4
    @rslt = grep (/HPL_time=/, @in_data);
    ($junk, $hpcc_hpl_time) = split ("=", $rslt[0]);

     # PTRANS_residual=0
    @rslt = grep (/PTRANS_residual=/, @in_data);
    ($junk, $hpcc_ptrans_residual) = split ("=", $rslt[0]);

     # PTRANS_n=50000
    @rslt = grep (/PTRANS_n=/, @in_data);
    ($junk, $hpcc_ptrans_n) = split ("=", $rslt[0]);

     # PTRANS_nb=250
    @rslt = grep (/PTRANS_nb=/, @in_data);
    ($junk, $hpcc_ptrans_nb) = split ("=", $rslt[0]);

     # PTRANS_nprow=2
    @rslt = grep (/PTRANS_nprow=/, @in_data);
    ($junk, $hpcc_ptrans_nprow) = split ("=", $rslt[0]);

     # PTRANS_npcol=64
    @rslt = grep (/PTRANS_npcol=/, @in_data);
    ($junk, $hpcc_ptrans_npcol) = split ("=", $rslt[0]);

     # PTRANS_time=66.7208
    @rslt = grep (/PTRANS_time=/, @in_data);
    ($junk, $hpcc_ptrans_time) = split ("=", $rslt[0]);

     # PTRANS_GBs=0.283001
    @rslt = grep (/PTRANS_GBs=/, @in_data);
    ($junk, $hpcc_ptrans_bandw) = split ("=", $rslt[0]);

     # STREAM_VectorSize=26041666
    @rslt = grep (/STREAM_VectorSize=/, @in_data);
    ($junk, $hpcc_stream_vecsize) = split ("=", $rslt[0]);

     # STREAM_Threads=1
    @rslt = grep (/STREAM_Threads=/, @in_data);
    ($junk, $hpcc_stream_threads) = split ("=", $rslt[0]);

     # StarSTREAM_Copy=1.19222
    @rslt = grep (/StarSTREAM_Copy=/, @in_data);
    ($junk, $hpcc_stream_star_copy) = split ("=", $rslt[0]);

     # StarSTREAM_Scale=1.18974
    @rslt = grep (/StarSTREAM_Scale=/, @in_data);
    ($junk, $hpcc_stream_star_scale) = split ("=", $rslt[0]);

     # StarSTREAM_Add=1.27868
    @rslt = grep (/StarSTREAM_Add=/, @in_data);
    ($junk, $hpcc_stream_star_add) = split ("=", $rslt[0]);

     # StarSTREAM_Triad=1.2991
    @rslt = grep (/StarSTREAM_Triad=/, @in_data);
    ($junk, $hpcc_stream_star_triad) = split ("=", $rslt[0]);

    ###
     # SingleSTREAM_Copy=9.02779
    @rslt = grep (/SingleSTREAM_Copy=/, @in_data);
    ($junk, $hpcc_stream_single_copy) = split ("=", $rslt[0]);

     # SingleSTREAM_Scale=9.05797
    @rslt = grep (/SingleSTREAM_Scale=/, @in_data);
    ($junk, $hpcc_stream_single_scale) = split ("=", $rslt[0]);

     # SingleSTREAM_Add=9.67253
    @rslt = grep (/SingleSTREAM_Add=/, @in_data);
    ($junk, $hpcc_stream_single_add) = split ("=", $rslt[0]);

     # SingleSTREAM_Triad=9.58798
    @rslt = grep (/SingleSTREAM_Triad=/, @in_data);
    ($junk, $hpcc_stream_single_triad) = split ("=", $rslt[0]);

     # Success=1
    @rslt = grep (/Success=/, @in_data);
    ($junk, $hpcc_status) = split ("=", $rslt[0]);

    if ($hpcc_status != 1) {
        print "HPCC: Test FAILED\n";
    } else {
        #print "HPCC: Passed!\n";

        open(OUTFILE, ">$output_file") || die "Error: $! '$output_file'";

         #
         # TJN: Update $opt_show_fields print if update this list!
         #
        print OUTFILE "# HPL_N, HPL_NB, HPL_P, HPL_Q, HPL_Tflops, CommWorldProcs, MaxPingPongLatency_usec, MaxPingPongBandwidth_GBytes, MinPingPongLatency_usec, MinPingPongBandwidth_GBytes, AvgPingPongLatency_usec, AvgPingPongBandwidth_GBytes, RandomlyOrderedRingLatency_usec, RandomlyOrderedRingBandwidth_GBytes, NaturallyOrderedRingLatency_usec, NaturallyOrderedRingBandwidth_GBytes, HPL_time, PTRANS_residual, PTRANS_n, PTRANS_nb, PTRANS_nprow, PTRANS_npcol, PTRANS_time, PTRANS_GBs, STREAM_VectorSize, STREAM_Threads, StarSTREAM_Copy, StarSTREAM_Scale, StarSTREAM_Add, StarSTREAM_Triad, SingleSTREAM_Copy, SingleSTREAM_Scale, SingleSTREAM_Add, SingleSTREAM_Triad\n";
        print OUTFILE " $hpcc_hpl_n, $hpcc_hpl_nb, $hpcc_hpl_p, $hpcc_hpl_q, $hpcc_hpl_tflops, $hpcc_mpi_nprocs, $hpcc_max_pp_latency, $hpcc_max_pp_bandw, $hpcc_min_pp_latency, $hpcc_min_pp_bandw, $hpcc_avg_pp_latency, $hpcc_avg_pp_bandw, $hpcc_rand_ring_latency, $hpcc_rand_ring_bandw, $hpcc_ordered_ring_latency, $hpcc_ordered_ring_bandw, $hpcc_hpl_time, $hpcc_ptrans_residual, $hpcc_ptrans_n, $hpcc_ptrans_nb, $hpcc_ptrans_nprow, $hpcc_ptrans_npcol, $hpcc_ptrans_time, $hpcc_ptrans_bandw, $hpcc_stream_vecsize, $hpcc_stream_threads, $hpcc_stream_star_copy, $hpcc_stream_star_scale, $hpcc_stream_star_add, $hpcc_stream_star_triad, $hpcc_stream_single_copy, $hpcc_stream_single_scale, $hpcc_stream_single_add, $hpcc_stream_single_triad\n";

        close(OUTFILE);

    }

    return (0); #SUCCESS
}

# vim:tabstop=4:expandtab:shiftwidth=4 
