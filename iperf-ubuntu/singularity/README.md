Singularity Setup
-----------------

Steps for creating a Singularity image for the 'iperf-ubuntu'
Docker image. (See also `sing-build.sh`)

 - Create a blank image file (using default size)

   ```
    sudo singularity create iperf-ubuntu.img
   ```

 - Bootstrap the 'iperf-ubuntu' image

   ```
    sudo singularity bootstrap iperf-ubuntu.img iperf-ubuntu.def
   ```

Alternate Versions
------------------

 1. You can also use the `sing-build-V2.sh` and associated
   `iperf-ubuntu-V2.def` Singularity definition file to build
   things in a more direct manner (less imported from our Docker workflow).

   ```
    ./sing-build-V2.sh
   ```

 2. You can use the `singularity import` command to avoid having to
    install Docker locally, e.g., for the `naughtont3/iperf-ubuntu` Docker image.

   ```
    sudo singularity create --size 768 test-iperf.img
   ```

   ```
    sudo singularity import test-iperf.img docker://naughtont3/iperf-ubuntu:latest
   ```


Misc
----

Occasionally, some "command line gymnastics" are required, and
this was an example of such an instance.

  - Context: Our `mpirun`, `mpicc` and `singularity` executables are 
    installed in a non-standard location (`/sw/TJN/FRESHTEST/`).

    ```
    $ which singularity
    /sw/TJN/FRESHTEST/bin/singularity
    ```

Another example has to do with the shifting of UID when entering the 
container context depending on whether or not you will be writing to the
container image file.  When writing to the image file, you often will be
using the `sudo` command and therefore will take on a different UID and the
standard user UID/GID is not inserted into the isolated `/etc/passwd` entry.
The following command illustrate the scenario:

   ```
    $ singularity exec iperf-ubuntu-V2.img ls -l /benchmarks
    total 8
    drwxr-xr-x. 3 root root 4096 Feb  2 14:27 runs
    drwxr-xr-x. 5 root root 4096 Feb  2 14:27 src
   ```

   ```
    $ singularity exec iperf-ubuntu-V2.img tail /etc/passwd
    $ singularity exec iperf-ubuntu-V2.img tail /etc/passwd | grep tjn
    tjn:x:12345:1000:Thomas Naughton:/home/tjn:/bin/bash
   ```

   ```
    $ sudo singularity exec iperf-ubuntu-V2.img chown -R tjn.users /benchmarks
    chown: invalid user: 'tjn.users'
   ```

   ```
    $ sudo singularity exec iperf-ubuntu-V2.img tail /etc/passwd | grep tjn
    # NOTHING IS FOUND
   ```

   ```
    $ id
    uid=12345(tjn) gid=1000(users)
   ```

   ```
    $ sudo singularity exec iperf-ubuntu-V2.img chown -R 12345.1000 /benchmarks
   ```

   ```
    $ singularity exec iperf-ubuntu-V2.img ls -l /benchmarks
    total 8
    drwxr-xr-x 2 tjn users 4096 Mar 14 22:17 runs
    drwxr-xr-x 5 tjn users 4096 Mar 14 22:17 src
   ```

