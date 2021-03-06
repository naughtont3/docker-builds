centos7-hellosleep
------------------

A simple example "hello sleep" executable based on Centos.

The target "application" is a simple program that prints
a message to standard output and then sleeps.  It repeats
this in a loop until the user provide amount of time has 
passed.  

For example: Run for 21 seconds.

    pokey:$ ./hellosleep 21
    [31237] INFO: PID = 31237
    [31237] INFO: SLEEP 10  (loopcount: 1, total: 21)
    [31237] INFO: SLEEP 10  (loopcount: 2, total: 21)
    [31237] INFO: SLEEP 1  (loopcount: 3, total: 21)
    pokey:$ 

Usage: hellosleep SECONDS
   SECONDS -- Number of seconds to sleep
   (Must be positive non-zero integer)


See also Docker Hub repo
https://hub.docker.com/r/naughtont3/centos7-hellosleep


Useful Docker Commands
----------------------
- Run executable directly (and auto-cleanup after done):
```
  docker run --rm naughtont3/centos7-hellosleep hellosleep 30
```

- Run executable directly (non-daemon mode):
```
  docker run -ti naughtont3/centos7-hellosleep hellosleep 30
```

- Run image (start container) in ''daemon'' mode:
```
 docker run -d -P --name <NAME> naughtont3/centos7-hellosleep /bin/sleep infinity
```

- Run image (start container) in ''daemon'' mode with bind-mounted host dir:
```
  docker run -d -P --name hisleep \
           -v /home/data:/data  naughtont3/centos7-hellosleep /bin/sleep infinity
```

- Attach to the running container (assuming name ''hisleep''):
```
  docker exec -ti hisleep  /bin/bash
```

- (Alternate) Run image (start container) directly (non-daemon mode):
```
  docker exec -ti naughtont3/centos7-hellosleep /bin/bash
```

- Removing the container (and their volumes to avoid dangling volumes!)
```
  docker rm -v hisleep
```

- Build/Upload image:
```
    docker build -t="naughtont3/centos7-hellosleep" .
    docker push naughtont3/centos7-hellosleep 
```

Misc. Notes
-----------
- none.

