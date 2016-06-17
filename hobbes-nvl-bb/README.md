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

