ornl-oshmem-base
================

Base image layer with software dependencies for ORNL-OpenSHMEM.

 - NOTE: If using Private Github repository, see notes for
         generating a 'Personal Access Tokens'.

 - NOTE: Currently using 'naughtont3' for DockerHUB but account,
         but ultimately this should be changed.

 - NOTE: This just builds Libevent/PMIX/OMPI.  Need to run `finish_build.sh`
         from within container to build XPMEM/UCX/OSHMEM.
         (This is primarily due to the XPMEM kernel dependency, so we need
          the linux-headers and module from the target machine, 
          `/usr/src` and `/lib/modules`.)

         Example commands:

         ```
             # Start in daemon mode
            docker run -d -P --name mydemo \
                -v /usr/src:/usr/src \
                -v /lib/modules:/lib/modules \
                naughtont3/ornl-oshmem-base /bin/sleep infinity
            docker exec -ti mydemo /bin/bash
            /usr/local/src/finish_build.sh
        ```

Getting Started
---------------

- Run image (start container) in ''daemon'' mode with bind-mounted host kernel dir:

    ```
        docker run -d -P  \
                --name mydemo \
                -v /usr/src:/usr/src \
                -v /lib/modules:/lib/modules \
                naughtont3/ornl-oshmem-base /bin/sleep infinity
    ```

- Attach to the running container: 

    ```
        docker exec -ti mydemo /bin/bash
    ```

- NOTE:  If want fully-automated `finish_build.sh` set `GITHUB_TOKEN` env
         var or create file with token (`/usr/local/src/mytoken`), *before*
         running `finish_build.sh`.  
         Otherwise, will be prompted for Github username/password for 
         oshmem git checkout.
         (See 'Personal Access Tokens' below for more details.)

    ```
		root@ed2ebcb10457:/# vi /usr/local/src/mytoken
    ```

- Finish setup/build  (xpmem, ucx, oshmem):

    ```
		root@ed2ebcb10457:/# /usr/local/src/finish_build.sh
				...			
            ...<snip>...
				...			
		##################################################################
		  Source dir: /usr/local/src/
		 Install dir: /usr/local/
		  Start time: Tue Nov 28 16:10:39 UTC 2017
		 Finish time: Tue Nov 28 16:13:16 UTC 2017
		##################################################################
		root@ed2ebcb10457:/# source /usr/local/src/env_oshmem-develop.sh 
		root@ed2ebcb10457:/# which orterun
		/usr/local/bin/orterun
		root@ed2ebcb10457:/# which oshcc  
		/usr/local/bin/oshcc
    ```

Getting Docker
--------------
- Most distributions include Docker, but the version may be old.  For
  instructions on installing a recent version of Docker on Linux,
  see: https://docs.docker.com/engine/installation/

  - Note: For convenience, there is also a note with most of the steps for
    getting Docker on Linux in this repository: [GET-DOCKER](GET-DOCKER)



(Generic) Useful Docker Commands
--------------------------------
- Run image (start container) in ''daemon'' mode:

  ```
 docker run -d -P --name <NAME> naughtont3/ornl-oshmem-base /bin/sleep infinity
  ```

- Run image (start container) in ''daemon'' mode with bind-mounted host dir:

  ```
  docker run -d -P --name mydemo \
           -v /home/data:/data  naughtont3/ornl-oshmem-base /bin/sleep infinity
  ```

- Attach to the running container (assuming name ''mydemo''):

  ```
  docker exec -ti mydemo  /bin/bash
  ```

- (Alternate) Run image (start container) directly (non-daemon mode):

  ```
  docker exec -ti naughtont3/ornl-oshmem-base /bin/bash
  ```

- Removing the container (and their volumes to avoid dangling volumes!)

  ```
  docker rm -v mydemo
  ```

- Build/Upload image:

    ```
    docker build -t="naughtont3/ornl-oshmem-base" .
    docker push naughtont3/ornl-oshmem-base
    ```


Building 'ornl-oshmem-base' Docker Image
---------------------------------------
- Download the 'docker-build' repo with docker build files and support material
  (TODO: FIXME - use proper URL for the docker files)

  ```
    git clone https://github.com/naughtont3/docker-builds.git
  ```

- Change to the 'ornl-oshmem-base' area

  ```
    cd docker-builds/ornl-oshmem-base/
  ```

- (Option-1) Run the `dockerhub-build-push.sh` script.

- (Option-2) Run `docker build` directly
   - Note: In some case may need to pass a Github token
     via 'mytoken' file  (See 'Personal Access Tokens'
     below for more details.)

  ```
    docker build \
        --build-arg=GITHUB_TOKEN=$(cat mytoken) \
       -t="naughtont3/ornl-oshmem-base" .
  ```

- See also the Docker build/push helper script [dockerhub-build-push.sh](dockerhub-build-push.sh)


Personal Access Tokens
----------------------

When using private Git repositories you need some way to pass authentication
information, which is used in the Dockerfiles for 'git clone' commands.
To avoid embedding username/passwords, Github supports the generation of
"Personal access tokens" that can be passed to Git for authentication.

  https://help.github.com/articles/creating-an-access-token-for-command-line-use

In the current Dockerfile the ```GITHUB_TOKEN``` argument is used to clone
the private repositories.

- Step-1) Generate the Personal Access Token at Github
    - https://help.github.com/articles/creating-an-access-token-for-command-line-use

- Step-2) Save the token as a file (one line only), e.g., "mytoken"

    ```
    vi mytoken

    wc -l mytoken
    1 mytoken
    ```

- Step-3) Run Docker build, passing the  ```--build-arg``` (reading token from file):

    ```
    docker build --build-arg=GITHUB_TOKEN=$(cat mytoken) -t="naughtont3/ornl-oshmem-base" .
    ```

- ***NOTE*** DO NOT SAVE YOUR TOKEN TO REPOSITORY OR GIVE TO OTHER USERS!

- Note: If using the  'dockerhub-build-push.sh', it recognized a file named
    ```mytoken``` in current working directory and will pass that seamlessly.


Host XPMEM
----------
- We generally will load the XPMEM kernel module in the host, but
  when building this software stack in a container we will also build
  XPMEM inside for source/headers/etc.  With proper permissions, we can
  load the `xpmem.ko` from the container if we choose.

- To build and load kernel module in the host, you will run the following.

    ```
      # Install kernel headers if not already installed
    sudo apt-get install linux-headers-$(uname -r)
    ls -l /usr/src/linux-headers-$(uname -r)
    ```

    ```
      # Download and build XPMEM kernel module
    git clone https://github.com/hjelmn/xpmem.git
    cd kernel/
    make
    ```

    ```
      # Load xpmem kernel module (from xpmem/mod/ directory)
    sudo insmod ./xpmem.ko
    ```

- If you do want to build/load the XPMEM kernel module from a container,
  you need to follow the steps in 'Kernel Modules in Containers'.
  ***NOTE***: To ```insmod``` a module within container, you must pass the
  ```--privileged``` option when starting the Docker container.



Kernel Modules in Containers
----------------------------
- Kernel Source/Headers - kernel headers/source should be
   installed manually at runtime in container, or (preferably)
   passed via bind-mounts from the host.

  ***NOTE***: To ```insmod``` a module within container, you must pass
    the ```--privileged``` option when starting the Docker container.
    Otherwise, if only building the kernel module in container, you can
    avoid passing ```privileged``` and only pass bind-mounts.

  - Option-1: Bind-mount kernel headers/source from host into container,
    (note: we use a "system container" model here)

    ```
     # Start "system container" (fully privileged!) with Kernel src/modules
    docker run -ti \
        --privileged \
        -v /usr/src:/usr/src \
        -v /lib/modules:/lib/modules \
        --name mydemo \
        naughtont3/ornl-oshmem-base \
        /bin/sleep infinity
    ```

    ```
      # Connect to container and follow normal steps for kernel module build
      # and use ```insmod```', etc. as expected.
    docker exec -ti  mydemo bash
    ```

  - Option-2: Install host kernel headers in container:

    ```
      # Install kernel headers if not already installed
    sudo apt-get install linux-headers-$(uname -r)
    ls -l /usr/src/linux-headers-$(uname -r)
    ```


- Note: The kernel module will persist in host after container exits,
  so make sure to cleanup/unload any loaded kernel modules.

- Another example: Here is an example I use to have a shared scratch
  (e.g., source code) between host/guest, share host kernel source/modules,
  and startup using a "system container" model.  The guest can ```insmod```
  modules because we pass the ```--privileged``` Docker option.
  However, since the kernel module is accessible in host or container via
  shared scratch directory, you can also easily load it in the host.

   ```
     # Start "system container" (fully privileged!)
    docker run -d -P --name mydemo \
            --privileged \
            -v /home/3t4/docker/docker_share:/data \
            -v /usr/src:/usr/src \
            -v /lib/modules:/lib/modules \
            naughtont3/ornl-oshmem-base \
            /bin/sleep infinity

     # Connect to "system container"
    docker exec -ti mydemo bash
   ```

- Another example: Running a demo container with access to
  the '/dev/xpmem' device (xpmem assumed to be loaded by host, otherwise
  need more privileges to 'insmod' in container).

   ```
     # Start "system container" (with access to /dev/xpmem device)
    docker run -d -P --name mydemo \
            --device /dev/xpmem \
            -v /home/3t4/docker/docker_share:/data \
            naughtont3/ornl-oshmem-base \
            /bin/sleep infinity

     # Connect to "system container" (with access to /dev/xpmem device)
    docker exec -ti mydemo  bash
   ```


NOTES
-----
- Note, if the repo is a private Github repository,
  you should generate a "Personal access token" at Github
  and pass it via a ```--build-arg``` to the ```GITHUB_TOKEN```
  that is used in the Dockerfile.

  *NOTE* The 'dockerhub-build-push.sh' script supports
  saving the generated token as a file (e.g., mytoken)
  and then it will be passed as Docker --build-arg.

  See 'Personal Access Tokens' above for more details.

