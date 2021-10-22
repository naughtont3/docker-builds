texpod - LaTeX Container
------------------------

This is the `texpod` container image.

The examples below use my example LaTeX doc,
replace that with your LaTeX doc.


Suggested Usage
---------------

 1. Checkout the document to build that will be our host share dir

    ```
        mkdir hostshare/
        cd hostshare/
         # Git clone my latex doc here
         # e.g., git clone https://code.ornl.gov/tjn3/example-doc1.git
    ```

 2. Start persistent container called `texdev` with host share directory
    as bind mount.
    (Note: Default user has `/home/texuser/sharedir` in $HOME directory.)

  ```
     docker run \
        -d \
        --rm \
        --name texdev \
        -v hostshare:/home/texuser/sharedir \
        naughtont3/texpod
        /usr/bin/sleep infinity
  ```

  3. From host, move to source and build using the container sharedir
     (Note: The docker 'make' command runs inside container so pathing
      is as it would be inside the container.)

  ```
     cd hostshare/example-doc1/tex/ornl-TM-report-foo1/

       # Runs make inside container
     docker exec texdev \
       make -C /home/texuser/sharedir/example-doc1/tex/ornl-TM-report-foo1/

       # Resulting PDF available on host for easy viewing
     open report.pdf
  ```

  4. From host, when all done working with doc, stop the persistent container

  ```
     docker stop texdev
  ```


docbuild.sh script
---------------------

Useful script for step 3

  ```
        #!/bin/bash
        # Brief: Checkout the doc to build in $DOCDIR,
        #        which will be the bind mounted shared dir between
        #        host and container passed at container launch time
        #        (e.g., docker run -d -v hostdir:guestdir ...)

        # Base bind mount dir inside the container
        GUESTDIR=/home/texuser/sharedir

        # Path to document checkout in shared dir
        DOCDIR=$GUESTDIR/example-doc1/tex/ornl-TM-report-foo1

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

