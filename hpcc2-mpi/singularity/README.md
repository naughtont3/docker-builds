Singularity Setup
-----------------

Steps for creating a Singularity image for the 'hpcc2-mpi'
Docker image. (See also `sing-build.sh`)

 - Create a blank image file (using default size)

   ```
    sudo singularity create hpcc2-mpi.img
   ```

 - Bootstrap the 'hpcc2-mpi' image

   ```
    sudo singularity bootstrap hpcc2-mpi.img hpcc2-mpi.def
   ```

Alternate Versions
------------------

 1. You can also use the `sing-build-V2.sh` and associated
   `hpcc2-mpi-V2.def` Singularity definition file to build
   things in a more direct manner (less imported from our Docker workflow).

   ```
    ./sing-build-V2.sh
   ```

 2. You can use the `singularity import` command to avoid having to
    install Docker locally, e.g., for the `naughtont3/hpcc2-mpi` Docker image.

   ```
    sudo singularity create --size 768 test-hpcc.img
   ```

   ```
    sudo singularity import test-hpcc.img docker://naughtont3/hpcc2-mpi:latest
   ```


Misc
----

Occasionally, some "command line gymnastics" are required, and
this was an example of such an instance.

  - Context: Our `mpirun`, `mpicc` and `singularity` executables are 
    installed in a non-standard location (`/sw/TJN/FRESHTEST/`).

    ```
    $ which mpicc
    /sw/TJN/FRESHTEST/bin/mpicc
    $ which singularity
    /sw/TJN/FRESHTEST/bin/singularity
    ```

  - After setting up the container source tree, we want to use
    the `mpicc` (and later `mpirun`) from the host to build things.
    Notice that to write to the Image file we need `sudo`.  To maintain our
    PATH we need to use `sudo -E` but for `PATH` we also had to explicitly
    set that to avoid some clobbering along the way.
    The `-B /sw:/sw` bind mounts our `/sw` tree into the container (we must
    create `/sw` in container filesystem for that to work).

    ```
    $ sudo -E PATH=$PATH /sw/TJN/FRESHTEST/bin/singularity exec \
                -B /sw:/sw \
                -w hpcc2-mpi-V2.img \
                make -C /benchmarks/src/HPCC arch=My_MPI_OpenBLAS
    ```

Another example has to do with the shifting of UID when entering the 
container context depending on whether or not you will be writing to the
container image file.  When writing to the image file, you often will be
using the `sudo` command and therefore will take on a different UID and the
standard user UID/GID is not inserted into the isolated `/etc/passwd` entry.
The following command illustrate the scenario:

   ```
    $ singularity exec hpcc2-mpi-V2.img ls -l /benchmarks
    total 8
    drwxr-xr-x. 3 root root 4096 Feb  2 14:27 runs
    drwxr-xr-x. 5 root root 4096 Feb  2 14:27 src
   ```

   ```
    $ singularity exec hpcc2-mpi-V2.img tail /etc/passwd
    $ singularity exec hpcc2-mpi-V2.img tail /etc/passwd | grep tjn
    tjn:x:12345:1000:Thomas Naughton:/home/tjn:/bin/bash
   ```

   ```
    $ sudo singularity exec hpcc2-mpi-V2.img chown -R tjn.users /benchmarks
    chown: invalid user: 'tjn.users'
   ```

   ```
    $ sudo singularity exec hpcc2-mpi-V2.img tail /etc/passwd | grep tjn
    # NOTHING IS FOUND
   ```

   ```
    $ id
    uid=12345(tjn) gid=1000(users)
   ```

   ```
    $ sudo singularity exec hpcc2-mpi-V2.img chown -R 12345.1000 /benchmarks
   ```

   ```
    $ singularity exec hpcc2-mpi-V2.img ls -l /benchmarks
    total 8
    drwxr-xr-x 2 tjn users 4096 Mar 14 22:17 runs
    drwxr-xr-x 5 tjn users 4096 Mar 14 22:17 src
   ```

