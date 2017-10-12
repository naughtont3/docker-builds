#!/bin/bash

grok_hpcc=/tmp/grok-hpcc.pl

for dir in `ls -1d *.run.*` ; do 

    file=`find $dir | grep hpccoutf`
    num=`echo "$file" | awk -F. '{print $1}'`

    #echo "DBG: file='$file'  num='$num'"

    $grok_hpcc --input $file  --output $num.summary.txt

     # Keep all of first file (so have the comment field description)
     if [ $num -eq 1 ] ; then
         cat $num.summary.txt > summary-ALL.txt 
     else
         grep -v \# $num.summary.txt >> summary-ALL.txt 
     fi

   #  # Just add all of the contents to "ALL" summary (includes extra comment lines)
   # cat $num.summary.txt >> summary-ALL.txt 

    rm $num.summary.txt

done

