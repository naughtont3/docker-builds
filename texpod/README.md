texpod - LaTeX Container
------------------------

This is the `texpod` container image.

The examples below use my example LaTeX doc,
replace that with your LaTeX doc.


Example Usage
-------------

 1. Got to parent location of LaTeX source

    ```
       cd ~/tex/
    ```

 2. Launch persistent `texdev` container with host directory
    containing sources (`$PWD`) as shared directory via bind mount.
    (Note: Default user has `/home/texuser/sharedir` in $HOME directory.)

    ```
       docker \
         run \
         -d \
         --rm \
         --name texdev \
         -v $PWD:/home/texuser/sharedir \
         naughtont3/texpod \
         /usr/bin/sleep infinity
    ```

  3. From host, move to LaTeX source to edit/build
      - Note: The `make` command runs within the container using
        the bind mounted source dir shared between host/container.
        So, pathing is as it would be inside the container.)

  ```
     cd doc1/

      # Make edits to document
     vi report.tex

       # Runs make inside container
     docker exec texdev \
       make -C /home/texuser/sharedir/doc1

       # Resulting PDF available on host for easy viewing
     open report.pdf
  ```

  4. From host, when all done working with doc, stop the persistent container

  ```
     docker stop texdev
  ```


docbuild.sh script
---------------------

Useful script for step 3, helpful to add as a `Makefile` target.

Possibly need to customize the following script variables:
 - `DOCDIR` to proper path for LaTeX source dir to build
   (pathing is as it would be from inside container)

 - `MYNAME` to name of container (if not `texdev`)

  ```
        #!/bin/bash
        # Brief: Checkout the doc to build in $DOCDIR,
        #        which will be the bind mounted shared dir between
        #        host and container passed at container launch time
        #        (e.g., docker run -d -v hostdir:guestdir ...)

        # Base bind mount dir inside the container
        GUESTDIR=/home/texuser/sharedir

        # Path to document checkout in shared dir
        DOCDIR=$GUESTDIR/doc1

        MYNAME=texdev

        docker \
            exec \
            $MYNAME \
            make -C $DOCDIR
  ```


Notes
-----
 - Starts as user 'texuser'.
 - There is a directory called 'sharedir' in user's $HOME.

