hobbes-dtk-demo
---------------

A "Hobbes DTK Container Demo" based on Ubuntu,
with a Hobbes "process-based" DTK Demo build. 
(Note, does *not* include BusyBox Guest VM.)

Note, since we are using private Github repositories,
you should generate a "Personal access token" at Github
and pass it via a ```--build-arg``` to the ```GITHUB_TOKEN```
that is used in the Dockerfile.

  - *NOTE* The 'dockerhub-build-push.sh' script supports
     saving the generated token as a file (e.g., mytoken)
     and then it will be passed as Docker --build-arg.

  - See 'Personal Access Tokens' details below.

See also Docker Hub repo
https://hub.docker.com/r/naughtont3/hobbes-dtk-demo/

Getting Docker
--------------
- Most distributions include Docker, but the version may be old.  For
  instructions on installing a recent version of Docker on Linux, 
  see: https://docs.docker.com/linux/step_one/

- Note: For convience, there is also a note with most of the steps for
  gettting Docker on Linux in this repository: [GET-DOCKER.md](../GET-DOCKER.md)


(Generic) Useful Docker Commands
--------------------------------
- Run image (start container) in ''daemon'' mode:

  ```
 docker run -d -P --name <NAME> naughtont3/hobbes-dtk-demo /bin/sleep infinity
  ```

- Run image (start container) in ''daemon'' mode with bind-mounted host dir:

  ```
  docker run -d -P --name hobbes_demo \
           -v /home/data:/data  naughtont3/hobbes-dtk-demo /bin/sleep infinity
  ```

- Attach to the running container (assuming name ''hobbes_demo''):

  ```
  docker exec -ti hobbes_demo  /bin/bash
  ```

- (Alternate) Run image (start container) directly (non-daemon mode):

  ```
  docker exec -ti naughtont3/hobbes-dtk-demo /bin/bash
  ```

- Removing the container (and their volumes to avoid dangling volumes!)

  ```
  docker rm -v hobbes_demo
  ```

- Build/Upload image:

    ```
    docker build -t="naughtont3/hobbes-dtk-demo" .
    docker push naughtont3/hobbes-dtk-demo 
    ```

Personal Access Tokens
----------------------

When using private Git repositories you need some way to pass authentication
inforation, which is used in the Dockerfiles for 'git clone' commands. 
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
    docker build --build-arg=GITHUB_TOKEN=$(cat mytoken) -t="naughtont3/hobbes-dtk-demo" .
    ```

- ***NOTE*** DO NOT SAVE YOUR TOKEN TO REPOSITORY OR GIVE TO OTHER USERS!

- Note: If using the  'dockerhub-build-push.sh', it recognized a file named
    ```mytoken``` in current working directory and will pass that seamlessly.



Running Hobbes Demo-v1.0
------------------------
- The following assumes you are running all three pieces of demo_v1.0
  within containers, i.e., driver, appA, and appB within Docker containers.
  They can be seperate containers.  

- **NOTE*** Container Usage Model: 
  - In the examples we employ a "system container" usage model, where a
    containers is started in the background and is treated like a
    light-weight VM.  An "application container" usage model, where each
    application executable is started in its own container, is also valid
    and should work just fine too.

- Step-0: Load the 'xpmem' kernel module in the host (See also: "Host XPMEM")

- Step-1: Start the "system" container for Hobbes Demo_v1.0 instances
   ***NOTE***: We pass the XPMEM device file via ```--device /dev/xpmem```.

    ```
          # (REQUIRED ONCE) Start the "system" container
        docker run -d -P \
            --name hobbes_demo \
            --device /dev/xpmem \
            -v /home/3t4/docker/docker_share:/data \
            naughtont3/hobbes-dtk-demo \
            /bin/sleep infinity"
    ```

- Step-2: Start the Hobbes Demo_v1.0 'driver' instance 

    ```
        # [INTERACTIVE] Run the 'driver' (e.g., in Container) 
        #  Note: First start shell (bash) and then run 'driver'.
     docker exec -ti hobbes_demo bash

     cd /hobbes/src/hobbes_demo/demo_v1.0/config_demo_1.0/DataTransferKit/packages/Adapters/POD_C/test/

     ./DataTransferKitC_API_driver.exe
    ```

- Step-3: Start the Hobbes Demo_v1.0 'appA' instance 

    ```
       # [NON-INTERACTIVE] Run the 'appA' (e.g., in Container)
       #  Note: Just run 'appA' in container context.
     docker exec hobbes_demo \
           /hobbes/src/hobbes_demo/demo_v1.0/config_demo_1.0/DataTransferKit/packages/Adapters/POD_C/test/DataTransferKitC_API_appA.exe
    ```

- Step-4: Start the Hobbes Demo_v1.0 'appB' instance 

    ```
        # [INTERACTIVE] Run the 'appB' (e.g., in Container) 
        #  Note: First start shell (bash) and then run 'appB'.
     docker exec -ti hobbes_demo bash

     cd /hobbes/src/ornl-hobbes_demo/demo_v1.0/config_demo_1.0/DataTransferKit/packages/Adapters/POD_C/test/

     ./DataTransferKitC_API_appB.exe
    ```


Host XPMEM
----------
- We generally will load the XPMEM kernel module in the host, as there is 
  no reason to build and install it from a container.   

- To build and load in the host, you will run the following.  
  
    ```
      # Install kernel headers if not already installed
    sudo apt-get install linux-headers-$(uname -r)
    ls -l /usr/src/linux-headers-$(uname -r)
    ```

    ```
      # Download and build XPMEM kernel module
    git clone http://github.com/ORNL/xpmem.git
    cd xpmem/mod/
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
   installed manually at runtime in container, or (preferrably) 
   passed via bind-mounts from the host. 

  ***NOTE***: To ```insmod``` a module within container, you must pass 
    the ```--privileged``` option when starting the Docker container.
    Otherwise, if only building the kernel module in container, you can 
    avoid passing ```privileged``` and only pass bind-mounts.
  
    ```
      # Install kernel headers if not already installed
    sudo apt-get install linux-headers-$(uname -r)
    ls -l /usr/src/linux-headers-$(uname -r)
    ```

   For example, to bind-mount kernel headers/source from host into container,
   (note: we use a "system container" model here):
  
    ```
     # Start "system container" (fully privledged!) with Kernel src/modules
    docker run -ti \
        --privileged \
        -v /usr/src:/usr/src \
        -v /lib/modules:/lib/modules \
        --name hobbes_demo \
        naughtont3/hobbes-dtk-demo \
        /bin/sleep infinity
    ```

    ```
      # Connect to container and follow normal steps for kernel module build
      # and use ```insmod```', etc. as expected.  
    docker exec -ti  hobbes_demo bash
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
     # Start "system container" (fully privledged!)
    docker run -d -P --name hobbes_demo \
            --privileged \
            -v /home/3t4/docker/docker_share:/data \
            -v /usr/src:/usr/src \
            -v /lib/modules:/lib/modules \
            naughtont3/hobbes-dtk-demo  \
            /bin/sleep infinity

     # Connect to "system container"
    docker exec -ti hobbes_demo  bash
   ```

- Another example: Running a Hobbes demo container with access to 
  the '/dev/xpmem' device (xpmem assumed to be loaded by host, otherwise 
  need more privledges to 'insmod' in container).

   ```
     # Start "system container" (with access to /dev/xpmem device)
    docker run -d -P --name hobbes_demo \
            --device /dev/xpmem \
            -v /home/3t4/docker/docker_share:/data \
            naughtont3/hobbes-dtk-demo  \
            /bin/sleep infinity

     # Connect to "system container" (with access to /dev/xpmem device)
    docker exec -ti hobbes_demo  bash
   ```

NOTES
-----
- (24jun2016) Initial version, tested on SAL9000 node at ORNL with
  Docker-v1.11 and Ubuntu-14.04

