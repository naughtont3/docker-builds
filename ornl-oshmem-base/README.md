NOTICE
======

 - **THIS REPO HAS [MOVED](./MOVED.md)**

ornl-oshmem-base
================

Base image layer with software dependencies for ORNL-OpenSHMEM.

 - NOTE: If using Private Github repository, see notes for
         generating a 'Personal Access Tokens'.

 - NOTE: Currently using 'naughtont3' for DockerHub account,
         but ultimately this should be changed.

 - NOTE: This builds Libevent/PMIX/OMPI/UCX to provide a base layer.
         Then the OSHMEM is built in another image layer that uses
         this base image.

 - NOTE: This creates the user 'oshuser' to allow running as non-root user.


Getting Started
---------------

- NOTE: Generally you will just use the 'ornl-oshmem' image, but it
        may be useful to use this 'ornl-oshmem-base' layer directly
        for testing/development.  Therefore, we give example for a "daemon"
        style usage mode where the container remains running in background.

- Run image (start container) in ''daemon'' mode:

    ```
        docker run -d -P  \
                --name mydemo \
                naughtont3/ornl-oshmem-base /bin/sleep infinity
    ```

- Attach to the running container:

    ```
        docker exec -ti mydemo /bin/bash
    ```

- Finish setup/build OSHMEM (skipping already built steps):

    ```
		root@ed2ebcb10457:/# /usr/local/src/
		root@ed2ebcb10457:/# ./build_ornloshm-develop.sh -L -P -O -U
		SKIP LIBEVENT
		SKIP PMIX
		SKIP OMPI
		SKIP UCX
		SKIP ORNLOSHMEM
		BUILD ORNL-OpenSHMEM
               ...
		   ...<snip>...
               ...
		##################################################################
		  Source dir: /usr/local/src/
		 Install dir: /usr/local/

		  Start time: Wed Nov 29 10:18:16 EST 2017
		 Finish time: Wed Nov 29 10:18:16 EST 2017
		##################################################################
		root@ed2ebcb10457:/# source /usr/local/src/env_oshmem-develop.sh
		root@ed2ebcb10457:/# which orterun
		/usr/local/bin/orterun
		root@ed2ebcb10457:/# which oshcc
		/usr/local/bin/oshcc
    ```


- Another method is to start container in ''daemon'' mode
  with debugger (ptrace) capabilties:

    ```
        docker run -d -P \
                --cap-add=SYS_PTRACE \
                --name mydemo  \
                naughtont3/ornl-oshmem-base /bin/sleep infinity
    ```

  And then connect to the running container:

    ```
        docker exec -ti mydemo bash
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

 - Using a debugger (gdb) for process attach with Docker containers requires
   access to the `SYS_PTRACE` capability.  You can start the container with
   this capability as follows:

    ```
    docker run \
        --cap-add=SYS_PTRACE \
        -ti --name mydemo \
        naughtont3/ornl-oshmem bash
    ```

   Then from another instance (e.g., `docker exec -ti mydemo bash`) you
   could attach to the running process for debugging, e.g., assuming `PID=57`.

    ```
    docker exec mydemo bash
    oshuser@e7f3daf24a2a:$ gdb --pid=57 ./hello_oshmem_c
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

