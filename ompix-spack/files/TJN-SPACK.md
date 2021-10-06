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


