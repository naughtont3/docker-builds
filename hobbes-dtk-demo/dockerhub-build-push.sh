#!/bin/bash

cat "./MOVED.md"
echo "THIS MOVED!"
exit 1

username=naughtont3
imagename=hobbes-dtk-demo

# Skip final "docker push" 1=skip, 0=push
#skip_push=0
skip_push=1

# Github token file
# Note: We read it from a file to avoid hardcoding
#       the private contents into a script.  It is
#       then passed to Docker via a '--build-arg'.
# See: https://help.github.com/articles/creating-an-access-token-for-command-line-use/
token_file=mytoken

# Start with empty build_args string
docker_build_args=

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

if [ -f "${token_file}" ] ; then
    mytoken=`cat ${token_file}`
    docker_build_args="--build-arg=GITHUB_TOKEN=${mytoken} "
fi

docker build ${docker_build_args} -t="${username}/${imagename}" .  || die "Docker Build failed"

if [ ${skip_push} == 0 ] ; then 
    docker push ${username}/${imagename}          || die "Docker Push failed"
else
    echo "SKIPPING 'docker push'"
fi

echo "*** Build/Push of ${username}/${imagename} Finished! ***"
exit 0
