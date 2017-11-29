ornl-oshmem
================

ORNL-OpenSHMEM container

 - NOTE: Using Private Github repository, see notes for
         generating a 'Personal Access Tokens'.

 - NOTE: DO **NOT** PUSH THIS IMAGE TO DockerHub
         (OSHMEM source is currently private).

 - NOTE: All dependencies are build in the base layer `ornl-oshmem-base`,
         also that creates the `oshuser`.

 - NOTE: All source is in `/usr/local/src`

 - NOTE: Source this file `/usr/local/src/env_oshmem-develop.sh` to setup
         environment (if not already setup).

Getting Started
---------------

- Run image (start container): 

    ```
        docker run -ti naughtont3/ornl-oshmem bash
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
    docker run -d -P --name <NAME> naughtont3/ornl-oshmem /bin/sleep infinity
  ```

- Run image (start container) in ''daemon'' mode with bind-mounted host dir:

  ```
    docker run -d -P --name mydemo \
           -v /home/data:/data  naughtont3/ornl-oshmem /bin/sleep infinity
  ```

- Attach to the running container (assuming name ''mydemo''):

  ```
    docker exec -ti mydemo  /bin/bash
  ```

- (Alternate) Run image (start container) directly (non-daemon mode):

  ```
    docker exec -ti naughtont3/ornl-oshmem /bin/bash
  ```

- Removing the container (and their volumes to avoid dangling volumes!)

  ```
    docker rm -v mydemo
  ```

- Build/Upload image:

  ```
    docker build -t="naughtont3/ornl-oshmem" .
    docker push naughtont3/ornl-oshmem
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


Building 'ornl-oshmem' Docker Image
---------------------------------------
- Download the 'docker-build' repo with docker build files and support material
  (TODO: FIXME - use proper URL for the docker files)

  ```
    git clone https://github.com/naughtont3/docker-builds.git
  ```

- Change to the 'ornl-oshmem' area

  ```
    cd docker-builds/ornl-oshmem/
  ```

- (Option-1) Run the `dockerhub-build-push.sh` script.

- (Option-2) Run `docker build` directly
   - Note: pass a Github token via 'mytoken' file for a
           fully automated checkout/build. 
           (See 'Personal Access Tokens' below for more details.)

  ```
    docker build \
        --build-arg=GITHUB_TOKEN=$(cat mytoken) \
       -t="naughtont3/ornl-oshmem" .
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
    docker build --build-arg=GITHUB_TOKEN=$(cat mytoken) -t="naughtont3/ornl-oshmem" .
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

