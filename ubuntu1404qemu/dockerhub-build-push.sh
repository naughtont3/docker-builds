#!/bin/bash

username=naughtont3
imagename=ubuntu1404qemu

# Skip final "docker push" 1=skip, 0=push
skip_push=0
#skip_push=1

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

if [ 0 == ${skip_push} ] ; then
    docker push ${username}/${imagename}      || die "Docker Push failed"
else
    echo "SKIPPING 'docker push'"
fi


echo "*** Build/Push of ${username}/${imagename} Finished! ***"
exit 0
