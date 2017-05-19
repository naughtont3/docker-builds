graph500-oshmem
=========

Graph500 is a graph/data-analytics benchmark.
This version of Graph500 has been extended to use OpenSHMEM.
([https://code.ornl.gov/e6d/graph500_openshmem])

This container-ized version of Graph500 uses Ubuntu and OpenMPI's
implementation of OpenSHMEM.

 - NOTE: If using Private Github repository, see notes for
         generating a 'Personal Access Tokens'.

 - NOTE: Currently using 'naughtont3' for DockerHUB but account,
         but ultimately this should be changed.


Running Graph500 Demo
---------------------
- Quick test: 

    ```
     docker run --rm -ti  naughtont3/graph500-oshmem /runit-graph500.sh
    ```

  - This just runs `TODO XXX_EXENAME` and shows output file for 1 instance.
     ```
      cat runit-graph500.sh 
      #!/bin/bash

      cd /tmp
      oshrun --allow-run-as-root --mca plm isolated  -np 1 XXX_EXENAME
     ```

- **NOTE** on Container Usage Model: 

  - In the examples we employ a "system container" usage model, where a
    containers is started in the background and is treated like a
    light-weight VM.  An "application container" usage model, where each
    application executable is started in its own container, is also valid
    and should work just fine too.


- Step-1: Start the "system" container for Graph500 Demo instances

    ```
          # (REQUIRED ONCE) Start the "system" container
        docker run -d -P \
            --name graph500_demo \
            -v /home/data:/data \ 
            naughtont3/graph500-oshmem \
            /bin/sleep infinity"
    ```

- Step-2: Start the Graph500 Demo instance

    ```
        # [INTERACTIVE] Run the benchmark (i.e., in Container) 
        #  Note: First start shell (bash) and then run 'XXX_EXENAME'.
     docker exec -ti graph500_demo bash

     oshrun -np 1 XXX_EXENAME
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
 docker run -d -P --name <NAME> naughtont3/graph500-oshmem /bin/sleep infinity
  ```

- Run image (start container) in ''daemon'' mode with bind-mounted host dir:

  ```
  docker run -d -P --name graph500_demo \
           -v /home/data:/data  naughtont3/graph500-oshmem /bin/sleep infinity
  ```

- Attach to the running container (assuming name ''graph500_demo''):

  ```
  docker exec -ti graph500_demo  /bin/bash
  ```

- (Alternate) Run image (start container) directly (non-daemon mode):

  ```
  docker exec -ti naughtont3/graph500-oshmem /bin/bash
  ```

- Removing the container (and their volumes to avoid dangling volumes!)

  ```
  docker rm -v graph500_demo
  ```

- Build/Upload image:

    ```
    docker build -t="naughtont3/graph500-oshmem" .
    docker push naughtont3/graph500-oshmem 
    ```


Building 'graph500-oshmem' Docker Image
---------------------------------------
- Download the 'docker-build' repo with docker build files and support material
  (TODO: FIXME - use proper URL for the docker files)

  ```
    git clone https://github.com/naughtont3/docker-builds.git
  ```

- Change to the 'graph500-oshmem' area 

  ```
    cd docker-builds/graph500-oshmem/
  ```

- (Option-1) Run the `dockerhub-build-push.sh` script.

- (Option-2) Run `docker build` directly
   - Note: In some case may need to pass a Github token 
     via 'mytoken' file  (See 'Personal Access Tokens' 
     below for more details.)

  ```
    docker build \
        --build-arg=GITHUB_TOKEN=$(cat mytoken) \
       -t="naughtont3/graph500-oshmem" .
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
    docker build --build-arg=GITHUB_TOKEN=$(cat mytoken) -t="naughtont3/graph500-oshmem" .
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

