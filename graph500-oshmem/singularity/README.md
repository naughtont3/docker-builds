Singularity for graph500-oshmem
---------------------------

Steps for creating a Singularity image from the 'graph500-oshmem'
Docker image.   There a a few different setup methods, see examples 
below.

- Note: Starting with Singularity v2.3 `singularity create` and `singularity
  import` no longer need `sudo`.  If you are using a version of Singularity
  older than v2.3, you may need to prefix your commands with `sudo`.


Setup-Method: Bootstrap 
-----------------------

 - TODO: NEED TO COMPLETE THE DEFINITION FILE FOR THIS EXAMPLE.

 - Create a blank image file (using default size)

   ```
    singularity create graph500-oshmem.img
   ```

 - Bootstrap the 'graph500-oshmem' image

   ```
    singularity bootstrap graph500-oshmem.img graph500-oshmem.def
   ```

Setup-Method: Import from DockerHub
------------------------------------

 - Create a blank image file (using default size)

   ```
    singularity create graph500-oshmem.img
   ```

 - Import the 'graph500-oshmem' image from DockerHub

   ```
    singularity import graph500-oshmem.img docker://naughtont3/graph500-oshmem:latest
   ```

Setup-Method: Import from File (tarball)
----------------------------------------

 - NOTE: Assuming locally built image, but not pushed to DockerHub 
   (e.g., private source/binaries), export to tarball then import file.


 - Export local only 'graph500-oshmem' docker image to tarball

    ```
     docker run --rm --name testve1 -dP naughtont3/graph500-oshmem:latest sleep infinity
     docker export testve1 -o graph500-oshmem.tar
     docker stop testve1
    ```

 - Create a blank image file (using default size)

   ```
    singularity create graph500-oshmem.img
   ```

 - Import the 'graph500-oshmem' image from tarball file

   ```
    singularity import graph500-oshmem.img file://./graph500-oshmem.tar
   ```

Setup-Method: Import from Singularity-Hub
-----------------------------------------

 - TODO: Add this example

Cray Edits
----------
 - For Cray machines, we have a few manual edits
    1. Create some expected paths in the container, see `cray/TITAN_HACKS.sh`
    2. Update the `/environment` file in container, see `cray/environment.titan`
       (which will likely not be needed in Singularity-2.3)

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
                -w hpcc-mpi-V2.img \
                make -C /benchmarks/src/HPCC arch=My_MPI_OpenBLAS
    ```

Another example has to do with the shifting of UID when entering the 
container context depending on whether or not you will be writing to the
container image file.  When writing to the image file, you often will be
using the `sudo` command and therefore will take on a different UID and the
standard user UID/GID is not inserted into the isolated `/etc/passwd` entry.
The following command illustrate the scenario:

   ```
    $ singularity exec hpcc-mpi-V2.img ls -l /benchmarks
    total 8
    drwxr-xr-x. 3 root root 4096 Feb  2 14:27 runs
    drwxr-xr-x. 5 root root 4096 Feb  2 14:27 src
   ```

   ```
    $ singularity exec hpcc-mpi-V2.img tail /etc/passwd
    $ singularity exec hpcc-mpi-V2.img tail /etc/passwd | grep tjn
    tjn:x:12345:1000:Thomas Naughton:/home/tjn:/bin/bash
   ```

   ```
    $ sudo singularity exec hpcc-mpi-V2.img chown -R tjn.users /benchmarks
    chown: invalid user: 'tjn.users'
   ```

   ```
    $ sudo singularity exec hpcc-mpi-V2.img tail /etc/passwd | grep tjn
    # NOTHING IS FOUND
   ```

   ```
    $ id
    uid=12345(tjn) gid=1000(users)
   ```

   ```
    $ sudo singularity exec hpcc-mpi-V2.img chown -R 12345.1000 /benchmarks
   ```

   ```
    $ singularity exec hpcc-mpi-V2.img ls -l /benchmarks
    total 8
    drwxr-xr-x 2 tjn users 4096 Mar 14 22:17 runs
    drwxr-xr-x 5 tjn users 4096 Mar 14 22:17 src
   ```

