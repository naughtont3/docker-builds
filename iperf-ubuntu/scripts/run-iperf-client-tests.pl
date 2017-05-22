#!/usr/bin/perl
# 
# Script to automate a pile-o-iperf runs (TCP and UDP).
# The idea is to edit path to IPERF_BIN and few other specific
# vars at the top of this file and then you can just let this
# run for a while.    
# (See the 'XXX: EDIT' marks)
#
# ***NOTE*** 
#   Assumes you have already started server at $SERVER_IPADDR
# ********** 
#
#

# XXX: EDIT
my $IPERF_BIN = "/benchmarks/src/local/bin/iperf3";
#my $IPERF_BIN = "/sw/TJN/iperf/bin/iperf3";

# XXX: EDIT
# IP Address where IPERF server runs
my $SERVER_IPADDR = "10.0.2.3";
#my $SERVER_IPADDR = "10.255.1.149";

# XXX: EDIT
# Prefix used on filenames
my $DATE_PREFIX = "2017.05.04";

# XXX: EDIT
# Added in the filename (e.g., 'host', 'sing', 'docker-overlay')
my $TEST_LABEL = "docker-overlay";
#my $TEST_LABEL = "sing";
#my $TEST_LABEL = "host";

my $IFCONFIG_BIN = "/sbin/ifconfig";
my $TIME_CMD = "time -p ";

# Positive integer
my $NUM_LOOPS = 10;

# Time to sleep between loops
my $SLEEPTIME = 1;

# Time to sleep between job loops 
# e.g., testA_1..NUM_LOOPS, INTER_JOB_SLEEPTIME, testB_1..NUM_LOOPS, etc.
my $INTER_JOB_SLEEPTIME = 30;

# Set false (0) to run command and sleeps (DEFAULT)
# Set true (1) to avoid running commands and sleeps,
#my $DEBUG = 0;
my $DEBUG = 1;

#=================================================

# List of test options and log-filename
@LoH1 = (
        #--TCP--
        {
                logfile => "/tmp/$DATE_PREFIX-$TEST_LABEL-iperf-client-10G-tcp.log",
                options => " -A 0 -fg -n 10G ",
        },
        {
                logfile => "/tmp/$DATE_PREFIX-$TEST_LABEL-iperf-client-100G-tcp.log",
                options => " -A 0 -fg -n 100G ",
        },
        {
                logfile => "/tmp/$DATE_PREFIX-$TEST_LABEL-iperf-client-10G-tcp-P2.log",
                options => " -A 0 -fg -n 10G -P 2",
        },
        {
                logfile => "/tmp/$DATE_PREFIX-$TEST_LABEL-iperf-client-10G-tcp-P4.log",
                options => " -A 0 -fg -n 10G -P 4",
        },
        {
                logfile => "/tmp/$DATE_PREFIX-$TEST_LABEL-iperf-client-100G-tcp-P2.log",
                options => " -A 0 -fg -n 100G -P 2",
        },
        {
                logfile => "/tmp/$DATE_PREFIX-$TEST_LABEL-iperf-client-100G-tcp-P4.log",
                options => " -A 0 -fg -n 100G -P 4",
        },
        #--UDP--
        {
                logfile => "/tmp/$DATE_PREFIX-$TEST_LABEL-iperf-client-10G-udp-b0.log",
                options => " -A 0 -fg -n 10G -u -b0",
        },
        {
                logfile => "/tmp/$DATE_PREFIX-$TEST_LABEL-iperf-client-100G-udp-b0.log",
                options => " -A 0 -fg -n 100G -u -b0",
        },
        {
                logfile => "/tmp/$DATE_PREFIX-$TEST_LABEL-iperf-client-10G-udp-b0-P2.log",
                options => " -A 0 -fg -n 10G -u -b0 -P 2",
        },
        {
                logfile => "/tmp/$DATE_PREFIX-$TEST_LABEL-iperf-client-10G-udp-b0-P4.log",
                options => " -A 0 -fg -n 10G -u -b0 -P 4",
        },
        {
                logfile => "/tmp/$DATE_PREFIX-$TEST_LABEL-iperf-client-100G-udp-b0-P2.log",
                options => " -A 0 -fg -n 100G -u -b0 -P 2",
        },
        {
                logfile => "/tmp/$DATE_PREFIX-$TEST_LABEL-iperf-client-100G-udp-b0-P4.log",
                options => " -A 0 -fg -n 100G -u -b0 -P 4",
        },
);


#-------


print "# BEGIN: " . `date` . "\n";
if ($DEBUG) {
    print "\n***RUNNING-IN-DEBUG-MODE***\n\n"; 
    sleep 1;
}

# Show interfaces
if ( -x $IFCONFIG_BIN ) {
    print "# INFO: === Network Interfaces ===\n";
    system("$IFCONFIG_BIN -a ");
    print "# INFO: ==========================\n";
}

for my $idx (0..$#LoH1) {

    #print "job[$idx]->{logfile}: " . $LoH1[$idx]{"logfile"} . "\n";
    #print "job[$idx]->{options}: " . $LoH1[$idx]{"options"} . "\n";

    print "\n#- - - - - - - - - - - - - - - - - - - - - - - - - - -\n";
    print "# START JOB $idx TESTS\n";
    print "#- - - - - - - - - - - - - - - - - - - - - - - - - - -\n\n";

    my $command  = $TIME_CMD . " ";
    $command     .= $IPERF_BIN; 
    $command     .= " " . $LoH1[$idx]{"options"};
    $command     .= " --logfile " . $LoH1[$idx]{"logfile"};
    $command     .= " -c $SERVER_IPADDR";

	for my $cnt (1..$NUM_LOOPS) {

        my $this_command = $command . " -T $cnt ";

		print "# INFO: === $cnt ===\n";

        print "#####################################\n";
        print "# COMMAND: $this_command\n";
        print "#####################################\n";
        system("$this_command") unless($DEBUG);

        print "# INFO: === Sleep $SLEEPTIME ===\n";
        sleep $SLEEPTIME unless($DEBUG);

	}

    print "\n#- - - - - - - - - - - - - - - - - - - - - - - - - - -\n";
    print "# FINISH JOB $idx TESTS\n";
    print "#- - - - - - - - - - - - - - - - - - - - - - - - - - -\n\n";

    print "# INFO: === Sleep $INTER_JOB_SLEEPTIME ===\n";
    sleep $INTER_JOB_SLEEPTIME unless($DEBUG);

}

print "# END: " . `date` . "\n";
print "DONE.\n";
