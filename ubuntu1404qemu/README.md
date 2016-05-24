ubuntu1404qemu
--------------

A "QEMU" virtual environment based on Ubuntu 14.04 (Trusty).

This is a container for running tests with QEMU/KVM constrained within
a container.

See also Docker Hub repo
https://hub.docker.com/r/naughtont3/ubuntu1404qemu/


Useful Docker Commands
----------------------
- Run image (start container) in ''daemon'' mode:
```
 docker run -d -P --name <NAME> naughtont3/ubuntu1404qemu /bin/sleep infinity
```

- Run image (start container) in ''daemon'' mode with bind-mounted host dir:
```
  docker run -d -P --name devel_ve \
           -v /home/data:/data  naughtont3/ubuntu1404qemu /bin/sleep infinity
```

- Attach to the running container (assuming name ''devel_ve''):
```
  docker exec -ti devel_ve  /bin/bash
```

- (Alternate) Run image (start container) directly (non-daemon mode):
```
  docker exec -ti naughtont3/ubuntu1404qemu /bin/bash
```

- Removing the container (and their volumes to avoid dangling volumes!)
```
  docker rm -v devel_ve
```

- Build/Upload image:
```
    docker build -t="naughtont3/ubuntu1404qemu" .
    docker push naughtont3/ubuntu1404qemu 
```

Misc. Notes
-----------
- Show version of tools using ```show-dev-tools.sh```
```
  docker exec -ti devel_ve  /bin/bash

   # Run script from within container
  /usr/local/bin/show-dev-tools.sh
```

