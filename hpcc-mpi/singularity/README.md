Singularity Setup
-----------------

Steps for creating a Singularity image for the 'hpcc-mpi'
Docker image. (See also `sing-build.sh`)

 - Create a blank image file (using default size)

   ```
    sudo singularity create hpcc-mpi.img
   ```

 - Bootstrap the 'hpcc-mpi' image

   ```
    sudo singularity bootstrap hpcc-mpi.img hpcc-mpi.def
   ```

Alternate Versions
------------------

 1. You can also use the `sing-build-V2.sh` and associated
   `hpcc-mpi-V2.def` Singularity definition file to build
   things in a more direct manner (less imported from our Docker workflow).

   ```
    ./sing-build-V2.sh
   ```

 2. You can use the `singularity import` command to avoid having to
    install Docker locally, e.g., for the `naughtont3/hpcc-mpi` Docker image.

   ```
    sudo singularity create --size 768 test-hpcc.img
   ```

   ```
    sudo singularity import test-hpcc.img docker://naughtont3/hpcc-mpi:latest
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
                -w hpcc-mpi-V2TMP.img \
                make -C /benchmarks/src/HPCC arch=My_MPI_OpenBLAS
    ```

