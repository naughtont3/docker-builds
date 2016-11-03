#!/bin/bash

username=naughtont3
imagename=bb-hellosleep

# TJN: Flag to run 'make' and 'make clean' for building
#      static binary outside the container.
#      YesRunMake (1), NoRunMake (0)
runmake=1


# End Configs
#####################################

die() {
    msg=$1
    echo "Error: $msg"
    exit 1
}

# Quick sanity check!
# Generally we have dirname & docker imagename the same.
# If they are mismatched, it may be a copy/paste error.
cwd=`pwd`
basename=`basename ${cwd}`
if [ "${basename}" != "${imagename}" ] ; then
    echo "Warning: Imagename not match directory name (copy/paste error?)"
    echo "    Imagename: (${imagename})   Directory name: (${basename})"
    read -p "Continue (y/n)?: " response
    if [ "${response}" != "y" ] ; then
        die "Imagename/Dirname mismatch - likely a copy/paste error"
    fi
fi

if [ 1 == $runmake ] ; then
    make clean > /dev/null
    make > /dev/null || die "Failed compilation with make"
fi

docker build -t="${username}/${imagename}" .  || die "Docker Build failed"
docker push ${username}/${imagename}          || die "Docker Push failed"

if [ 1 == $runmake ] ; then
    make clean > /dev/null || die "Failed cleanup with make"
fi

echo "*** Build/Push of ${username}/${imagename} Finished! ***"
exit 0
