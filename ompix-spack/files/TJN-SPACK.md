TJN Spack Notes
---------------

 - Setup Environment

   ```
    . spack/share/spack/setup-env.sh
   ```

 -  Initial concretizer run

   ```
     # 1st time to run concretizer
    time spack spec zlib

     # 2nd time will be much faster
     # NOTE: Also shows the arch info
    time spack spec zlib
   ```

 - Setup compilers (use local gcc)

   ```
    spack compiler find --scope=site

    spack compiler list
   ```

 - Build openmpi (specifically w/ gcc-9.3.0)

   ```
      spack install openmpi%gcc@9.3.0
   ```

 - Build *only dependencies* of openmpi (w/ gcc-9.3.0)

   ```
      spack install --only dependencies openmpi%gcc@9.3.0
   ```

 - Build *only package* openmpi(w/ gcc-9.3.0)

   ```
      spack install --only package openmpi%gcc@9.3.0
   ```


