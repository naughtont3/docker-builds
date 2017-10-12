UPDATE: 10oct2017 - minor tweak to run-hpcc script to remove OMPI params
        from MPIRUN, so things work with vanilla MPICH.

These are scripts I have been using when running the HPCC tests.  They are
slightly modified for each run, and generally the customized version is
kept with the HPCC data files (output) in the 'data/hpcc/' directories.

I am keeping a copy here, just in case I forget where to look or want
a copy to customize further, etc.

NOTE: The current versions were taken from an np=128 run.
NOTE: Copy the 'grok-hpcc.pl' script to /tmp, which is where GROKRUNS.sh
expects it to live.

ORDER of operations:
 1) create directory for test run (with these scripts)
 2) create same directory/path on all remote compute nodes
 3) create hostfile with all compute nodes and copy to compute node dir too
 4) edit scripts for MPI '--np' param, and other params like hostfile, etc.
 5) copy 'grok-hpcc.pl' to '/tmp/grok-hpcc.pl'
 ---
 6) Execute 'RUN.sh', which in turn executes 'run-hpcc.sh'
 ---
 7) When runs complete, execute 'GROKRUNS.sh' (generates "summary-ALL.txt")
 8) Clean out the 'hpcc' executable gathered with test results
    (for example something like this: "find ./ -name hpcc -exec rm {} \;")
 9) add results data to repo and spreadsheet.


--tjn 9may2017
