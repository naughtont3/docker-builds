hobbes-dtk-demo
---------------

***NOTE*** This is ``in progress'' / incomplete.

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


Useful Docker Commands
----------------------
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

  https://help.github.com/articles/creating-an-access-token-for-command-line-use/

In the current Dockerfile the ```GITHUB_TOKEN``` argument is used to clone
the private repositories.

- Step-1) Generate the Personal Access Token at Github
    - https://help.github.com/articles/creating-an-access-token-for-command-line-use/

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
- (MOVE ELSEHWERE) NOTE ON RUNNING Hobbes demo_v1.0 in container environment
  on sal9k-node40.  

-  ***NOTE*** THIS IS OLD VERSION USING DIFFERENT PATHS, NEEDS TO BE UPDATED
     TO PATHS USED HERE, i.e.,g /hobbes/src/ ...

    ```
          # (REQUIRED ONCE) Start the "system" container
        docker run -d -P \
            --name hobbes_demo \
            --device /dev/xpmem \
            -v /home/3t4/docker/docker_share:/data \
            naughtont3/hobbes-dtk-demo \
            /bin/sleep infinity"
    ```

    ```
          # Run the 'driver' (e.g., in Host)
          #  Note: First chdir is to share dir between host/guest
        cd /home/3t4/docker/docker_share/
        cd src/ornl-hobbes_demo/demo_v1.0/config_demo_1.0/DataTransferKit/packages/Adapters/POD_C/test/
        sudo ./DataTransferKitC_API_driver.exe 
    ```

    ```
          # [NON-INTERACTIVE] Run the 'appA' (e.g., in Container)
          #  Note: Just run 'appA' in container context.
        docker exec hobbes_demo \
            /data/src/ornl-hobbes_demo/demo_v1.0/config_demo_1.0/DataTransferKit/packages/Adapters/POD_C/test/DataTransferKitC_API_appA.exe
    ```

    ```
          # [INTERACTIVE] Run the 'appB' (e.g., in Container) 
          #  Note: First start shell (bash) and then run 'appB'.
        docker exec -ti hobbes_demo bash
        cd /data/src/ornl-hobbes_demo/demo_v1.0/config_demo_1.0/DataTransferKit/packages/Adapters/POD_C/test/
        ./DataTransferKitC_API_appB.exe
    ```


Misc. Notes
-----------
- Kernel Source/Headers - kernel headers/source should be installed manually
  at runtime, or passed via bind-mounts from the host.
  For example, to bind-mount kernel headers/source from host into a container:
  (*NOTE* To ```insmod``` a module within container, you must pass
  ```--privileged``` when starting container.)

  ```
    docker run -ti \
        -v /usr/src:/usr/src \
        -v /lib/modules:/lib/modules
        naughtont3/hobbes-dtk-demo /bin/bash
  ```

  Alternate version that starts using a  "system container" model:

  ```
    docker run -d -P --name hobbes_demo \
        -v /usr/src:/usr/src \
        -v /lib/modules:/lib/modules \
        naughtont3/hobbes-dtk-demo  \
        /bin/sleep infinity 
  ```

  Here is TJN's example used to have a shared scratch (e.g., source code)
  between host/guest, share host kernel source/modules, and startup using
  a "system container" model.  The guest can ```insmod``` modules because
  we pass the ```--privileged``` Docker option.


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

- Running a Hobbes demo container with access to the '/dev/xpmem' device
  (assumed to be loaded by host, otherwise need more privledges to insmod in
  container).

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


