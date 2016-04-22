#!/bin/bash

username=naughtont3
imagename=ubuntu1404devel

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

docker build -t="${username}/${imagename}" .  || die "Docker Build failed"
docker push ${username}/${imagename}          || die "Docker Push failed"

echo "*** Build/Push of ${username}/${imagename} Finished! ***"
exit 0
