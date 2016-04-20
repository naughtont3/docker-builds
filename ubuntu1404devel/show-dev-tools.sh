#!/bin/bash

SHOWPATH=0

tool_list="m4 
           autoconf 
           automake
           libtool
           make
           cmake
           gcc
           g++
           git
           vim
           ctags 
           qemu-x86_64-system
           rsync
           strace 
           genisoimage"

if [ "--showpath" = "$1" ] || [ "--showpaths" = "$1" ] ; then
     # Show the actual paths too
    SHOWPATH=1
fi

if [ "$SHOWPATH" = "1" ] ; then

    echo "*********************"
    echo "*** Tool Paths    ***"
    echo "*********************"
    for tool in $tool_list ; do

        if [ $(which $tool) ]; then
            echo "   $(which $tool)"
        fi

    done

    # Add some vertical whitespace
    echo ""
fi

echo "*********************"
echo "*** Tool Versions ***"
echo "*********************"
for tool in $tool_list ; do

    if [ $(which $tool) ]; then

         # Print name of tool
        echo -n "$tool: " 

         # Test to see if '--version' works
        $tool --version  2>/dev/null 1>/dev/null
        rc=$?

        if [ "$rc" = "0" ] ; then
             # Great '--version' works!
            $tool --version | head -1
        else

             # Doh, no '--version', try '-V' 
             # Falling back, test to see if '-V' works
            $tool -V 2>/dev/null 1>/dev/null
            rc=$?

            if [ "$rc" = "0" ] ; then
                 # Great '-V' works!
                $tool -V | head -1

            else
                echo " failed to get version."
            fi
        
        fi
    fi

done

# Add some vertical whitespace
echo ""

exit 0
