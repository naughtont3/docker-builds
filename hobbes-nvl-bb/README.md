hobbes-nvl-bb
---------------

***NOTE*** This is ``in progress'' / incomplete.

STATUS UPDATES:
 - 12may2016: Still having problems with downloads/build that stops
              full container build.  So for now, I'm just downloading
              the full source and installing dependencies.
              Then you can run the 'build-hacked.pl' or 'BUILDIT.sh' script 
              from within the container (see comments for possible edits).
              Note, BUILDIT.sh is just a wrapper on the 'build-hacked.pl' 
              script.  The 'build-hacked.pl' script has updates/work-arounds 
              that I've found helpful, e.g., can build guest image if didn't 
              compile Pisces or Palacios, adds customized passwd file to 
              guest image.

    ```
    TJN: STOPPING EARLY - WILL NEED TO RUN BUILD-HACKED.PL MANUALLY
    TJN: SEE BUILDIT.sh wrapper script for example.
    TJN: SEE /hobbes/nvl/src/guests/simple_busybox
    ```


A "Hobbes developer container" based on Ubuntu,
with a full Hobbes Developer environment, to include
a BusyBox Guest VM image containing MPI.

See also Docker Hub repo
https://hub.docker.com/r/naughtont3/hobbes-nvl-bb/


Useful Docker Commands
----------------------
- Run image (start container) in ''daemon'' mode:

  ```
 docker run -d -P --name <NAME> naughtont3/hobbes-nvl-bb /bin/sleep infinity
  ```

- Run image (start container) in ''daemon'' mode with bind-mounted host dir:

  ```
  docker run -d -P --name hobbes_bb \
           -v /home/data:/data  naughtont3/hobbes-nvl-bb /bin/sleep infinity
  ```

- Attach to the running container (assuming name ''hobbes_bb''):

  ```
  docker exec -ti hobbes_bb  /bin/bash
  ```

- (Alternate) Run image (start container) directly (non-daemon mode):

  ```
  docker exec -ti naughtont3/hobbes-nvl-bb /bin/bash
  ```

- Removing the container (and their volumes to avoid dangling volumes!)

  ```
  docker rm -v hobbes_bb
  ```

- Build/Upload image:

    ```
    docker build -t="naughtont3/hobbes-nvl-bb" .
    docker push naughtont3/hobbes-nvl-bb 
    ```

Useful Hobbes Commands
----------------------
- Running the guest VM (image.iso) in qemu (within container)

  ```
  host:$ docker exec -ti naughtont3/hobbes-nvl-bb /bin/bash
  container:# cd /hobbes/nvl/src/guests/simple_busybox/
  container:# qemu-system-x86_64 -cdrom ./image.iso -m 2048 -smp 4 -serial stdio
  ```


Additional Packages for Trilinos/DTK 
------------------------------------
- Note, often when doing testing for the Hobbes demo we will build
  Trilinos/DTK.  The following may need to be installed manually
  for Trilinos/DTK builds:

  Install Boost, BLAS and LAPACK in guest/VE:

    ```
        apt-get install \
            libboost-all-dev  \
            libblas3 libblas-dev \
            liblapack3 liblapack-dev
    ```

- Build/Install OpenMPI from source in guest/VE (see /data/src/ompi/build-ompi.sh)

    ```
        cd /data/src/ompi/
        tar -jxf openmpi-<VER>.tar.bz2
        cd openmpi-<VER>/
        ln -s ../build-ompi.sh
        ./build-ompi.sh
    ```

- (MOVE ELSEHWERE) NOTE ON RUNNING Hobbes demo_v1.0 in container environment
  on sal9k-node40

    ```
          # (REQUIRED ONCE) Start the "system" container
        docker run -d -P \
            --name hobbes_bb \
            --device /dev/xpmem \
            -v /home/3t4/docker/docker_share:/data \
            naughtont3/hobbes-nvl-bb \
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
        docker exec hobbes_bb \
            /data/src/ornl-hobbes_demo/demo_v1.0/config_demo_1.0/DataTransferKit/packages/Adapters/POD_C/test/DataTransferKitC_API_appA.exe
    ```

    ```
          # [INTERACTIVE] Run the 'appB' (e.g., in Container) 
          #  Note: First start shell (bash) and then run 'appB'.
        docker exec -ti hobbes_bb bash
        cd /data/src/ornl-hobbes_demo/demo_v1.0/config_demo_1.0/DataTransferKit/packages/Adapters/POD_C/test/
        ./DataTransferKitC_API_appB.exe
    ```


Misc. Notes
-----------
- Show version of tools using ```show-dev-tools.sh```

  ```
  docker exec -ti hobbes_bb  /bin/bash

   # Run script from within container
  /usr/local/bin/show-dev-tools.sh
  ```

- Kernel Source/Headers - kernel headers/source should be installed manually 
  at runtime, or passed via bind-mounts from the host.
  For example, to bind-mount kernel headers/source from host into a container:
  (*NOTE* To ```insmod``` a module within container, you must pass
  ```privileged``` when starting container.)

  ```
    docker run -ti \
        -v /usr/src:/usr/src \
        -v /lib/modules:/lib/modules
        naughtont3/hobbes-nvl-bb /bin/bash
  ```

  Alternate version that starts using a  "system container" model:

  ```
    docker run -d -P --name hobbes_bb \
        -v /usr/src:/usr/src \
        -v /lib/modules:/lib/modules \
        naughtont3/hobbes-nvl-bb  \
        /bin/sleep infinity 
  ```

  Here is TJN's example used to have a shared scratch (e.g., source code)
  between host/guest, share host kernel source/modules, and startup using
  a "system container" model.  The guest can ```insmod``` modules because
  we pass the ```--privileged``` Docker option.


   ```
     # Start "system container" (fully privledged!)
    docker run -d -P --name hobbes_bb \
            --privileged \
            -v /home/3t4/docker/docker_share:/data \
            -v /usr/src:/usr/src \
            -v /lib/modules:/lib/modules \
            naughtont3/hobbes-nvl-bb  \
            /bin/sleep infinity

     # Connect to "system container"
    docker exec -ti hobbes_bb  bash
   ```

- Running a Hobbes demo container with access to the '/dev/xpmem' device
  (assumed to be loaded by host, otherwise need more privledges to insmod in
  container).

   ```
     # Start "system container" (with access to /dev/xpmem device)
    docker run -d -P --name hobbes_bb \
            --device /dev/xpmem \
            -v /home/3t4/docker/docker_share:/data \
            naughtont3/hobbes-nvl-bb  \
            /bin/sleep infinity

     # Connect to "system container" (with access to /dev/xpmem device)
    docker exec -ti hobbes_bb  bash
   ```

    
