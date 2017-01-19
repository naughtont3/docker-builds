Ubuntu (14.04) OpenMPI + OpenSHMEM 
==================================

This container uses Ubuntu and OpenMPI's implementation of OpenSHMEM.

 - NOTE: Currently using 'naughtont3' for DockerHUB but account,
         but ultimately this should be changed.


Running 
-------
- Quick test using interactive shell:

    ```
    docker run --rm -ti naughtont3/ubuntu1404-ompi-oshmem  bash
    ```

  - Within this container we can run OpenMPI examples like this:

     ```
	  root:# cd /usr/local/src/openmpi-2.0.1/examples/
	  root:# make

		...<snip>...

	  root:# mpirun --allow-run-as-root --mca plm isolated -np 1 ./hello_c
     ```

     - NOTE: The `--allow-run-as-root` is needed b/c we did not create a user in Container
     - NOTE: The `--mca plm isolated`  is needed b/c we do not setup any external access or use SSH

    

- **NOTE** on Container Usage Model: 

  - In the examples we employ a "system container" usage model, where a
    containers is started in the background and is treated like a
    light-weight VM.  An "application container" usage model, where each
    application executable is started in its own container, is also valid
    and should work just fine too.


- Step-1: Start the "system" container instance

    ```
          # (REQUIRED ONCE) Start the "system" container
        docker run -d -P \
            --name ompi_test \
            -v /home/data:/data \ 
            naughtont3/ubuntu1404-ompi-oshmem \
            /bin/sleep infinity"
    ```

- Step-2: Start a shell in instance

    ```
        # [INTERACTIVE] Run shell (in Container)
     docker exec -ti ompi_test bash

     cd /benchmarks/...

     oshrun -np 1 ./my_benchmark_here
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
 docker run -d -P --name <NAME> naughtont3/ubuntu1404-ompi-oshmem /bin/sleep infinity
  ```

- Run image (start container) in ''daemon'' mode with bind-mounted host dir:

  ```
  docker run -d -P --name ompi_test \
           -v /home/data:/data  naughtont3/ubuntu1404-ompi-oshmem /bin/sleep infinity
  ```

- Attach to the running container (assuming name ''ompi_test''):

  ```
  docker exec -ti ompi_test  /bin/bash
  ```

- (Alternate) Run image (start container) directly (non-daemon mode):

  ```
  docker exec -ti naughtont3/ubuntu1404-ompi-oshmem /bin/bash
  ```

- Removing the container (and their volumes to avoid dangling volumes!)

  ```
  docker rm -v ompi_test
  ```

- Build/Upload image:

    ```
    docker build -t="naughtont3/ubuntu1404-ompi-oshmem" .
    docker push naughtont3/ubuntu1404-ompi-oshmem 
    ```


Building 'ubuntu1404-ompi-oshmem' Docker Image
----------------------------------------------
- Download the repo with docker build files and support material
  (TODO: FIXME - use proper URL for the docker files)

  ```
    git clone ...URL_HERE...
  ```

- Change to the docker area for 'ubuntu1404-ompi-oshmem'

  ```
    cd ubuntu1404-ompi-oshmem/
  ```

- Run ```docker build``` (passing a Github token via 'mytoken' file)
  (NOTE: 'Personal Access Tokens' below for more details.)

  ```
    docker build \
        --build-arg=GITHUB_TOKEN=$(cat mytoken) \
       -t="naughtont3/ubuntu1404-ompi-oshmem" .
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
    docker build --build-arg=GITHUB_TOKEN=$(cat mytoken) -t="naughtont3/ubuntu1404-ompi-oshmem" .
    ```

- ***NOTE*** DO NOT SAVE YOUR TOKEN TO REPOSITORY OR GIVE TO OTHER USERS!

- Note: If using the  'dockerhub-build-push.sh', it recognized a file named
    ```mytoken``` in current working directory and will pass that seamlessly.



NOTES
-----
- Note, since the OSB repo is a private Github repository,
  you should generate a "Personal access token" at Github
  and pass it via a ```--build-arg``` to the ```GITHUB_TOKEN```
  that is used in the Dockerfile.

  *NOTE* The 'dockerhub-build-push.sh' script supports
  saving the generated token as a file (e.g., mytoken)
  and then it will be passed as Docker --build-arg.

  See 'Personal Access Tokens' above for more details.

- See also the Docker build/push helper script [dockerhub-build-push.sh](dockerhub-build-push.sh)
