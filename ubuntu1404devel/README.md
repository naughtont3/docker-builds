ubuntu1404devel
---------------

A "developer container".

This is a container with the standard packages that we use for development,
i.e., compilers, qemu, etc.

See also Docker Hub repo
https://hub.docker.com/r/naughtont3/ubuntu1404devel/


Useful Docker Commands
----------------------
- Run image (start container) in ''daemon'' mode:
```
 docker run -d -P --name <NAME> naughtont3/ubuntu1404devel /bin/sleep infinity
```

- Run image (start container) in ''daemon'' mode with bind-mounted host dir:
```
  docker run -d -P --name devel_ve \
           -v /home/data:/data  naughtont3/ubuntu1404devel /bin/sleep infinity
```

- Attach to the running container (assuming name ''devel_ve''):
```
  docker exec -ti devel_ve  /bin/bash
```

- (Alternate) Run image (start container) directly (non-daemon mode):
```
  docker exec -ti naughtont3/ubuntu1404devel /bin/bash
```

- Removing the container (and their volumes to avoid dangling volumes!)
```
  docker rm -v devel_ve
```

- Build/Upload image:
```
    docker build -t="naughtont3/ubuntu1404devel" .
    docker push naughtont3/ubuntu1404devel 
```

Misc. Notes
-----------
- Show version of tools using ```show-dev-tools.sh```
```
  docker exec -ti devel_ve  /bin/bash

   # Run script from within container
  /projects/show-dev-tools.sh
```

