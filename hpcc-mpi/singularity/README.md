Singularity Setup
-----------------

Steps for creating a Singularity image for the 'hpcc-mpi'
Docker image.

 - Create a blank image file (using default size)

   ```
    sudo singularity create hpcc-mpi.img
   ```

 - Bootstrap the 'hpcc-mpi' image

   ```
    sudo singularity bootstrap hpcc-mpi.img hpcc-mpi.def
   ```

