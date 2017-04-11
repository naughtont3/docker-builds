IPERF: Multi-host Docker
------------------------

Start swarm with all nodes

```
    docker swarm init

     ###
     # RUN COMMAND SHOWN IN OUTPUT ON OTHER NODES
     # EXAMPLE:
     #  node2:$  docker swarm join --token xxxxxx 172.23.85.149:2377
     ###
```


Create the overlay network

```
    docker network create --attachable -d overlay tjn-10G-netw
```

Deploy our "iperf" service (sleep infinity) on the swarm nodes

```
   docker service create \
            --name iperf \
            --network tjn-10G-netw \
            --replicas 2 \
            naughtont3/iperf-ubuntu \
            sleep infinity
   docker service ls
```

Show service "iperf" running on all the nodes

```
    or-c49:$ docker service ls
    ID            NAME  MODE        REPLICAS  IMAGE
    g4sy6nmn1v10  iperf replicated  2/2       naughtont3/iperf-ubuntu:latest
    or-c49:$ docker service ps iperf
    ID            NAME    IMAGE                       NODE    DESIRED STATE  CURRENT STATE           ERROR  PORTS
    v02k4eyyx6hy  iperf.1  naughtont3/iperf-ubuntu:latest  or-c50  Running        Running 28 seconds ago         
    mhvsjtylzeda  iperf.2  naughtont3/iperf-ubuntu:latest  or-c49  Running        Running 6 seconds ago 
```

Get the IP address for the service on our local node (or-c49):

```
    # Get the name of the Service instance running on localhost (or-c49)
    or-c49:$ docker service ps --filter node=or-c49 iperf
    ID            NAME    IMAGE                       NODE    DESIRED STATE  CURRENT STATE               ERROR  PORTS
    mhvsjtylzeda  iperf.2  naughtont3/iperf-ubuntu:latest  or-c49  Running        Running about a minute ago
```

```
  #####
  # BUT CAN ACTUALLY JUST GET THE SINGLE LOCAL CONTAINER INSTANCE TOO
  #####

     # Get the name of our local container within the Service
    or-c49:$ docker ps --filter name=iperf --format "{{.Names}}"
    iperf.2.mhvsjtylzedauw1hngjrh8bew
```

Then get the actual IP address (see: [scripts/showIPs.sh](scripts/showIPs.sh))

```
    or-c49:$ docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' iperf.2.mhvsjtylzedauw1hngjrh8bew
    10.0.0.6
```

Using the 'showIPs.sh' script we get IP of all 4 instances for this service

```
    or-c49:$ ./showIPs.sh 
    10.0.0.6
    or-c49:$ cpush showIPs.sh /tmp/
    or-c49:$ cexec -p /tmp/showIPs.sh
    uc4 or-c50: 10.0.0.3
    uc4 or-c51: 10.0.0.5
    uc4 or-c52: 10.0.0.4
```


Get a shell in local container

```
     # Get our local container name
    or-c49:$ docker ps --filter name=iperf --format "{{.Names}}"
    iperf.2.mhvsjtylzedauw1hngjrh8bew

    or-c49:$ docker exec -ti iperf.2.mhvsjtylzedauw1hngjrh8bew bash
    mpiuser@c38fe7ae1f62:/$
```

Extra Setup
-----------
I now have to setup/start the SSHD to allow us to connect between the 
containers spanning hosts (connected via the docker network).
 - See also: [scripts/startSSHDs_v2.sh](scripts/startSSHDs_v2.sh)

Install C3 tools to help with parallel commands/scripts, etc. 
 - See 'Setup C3 Tools' below

Lot of manual stuff...

 - Add the SSHKEY from my "headnode" container to each container
 - Start SSHD on port 2222 in each container

    ```
        or-c49:$ ./startSSHDs_v2.sh 
        or-c49:$ cpush startSSHDs_v2.sh /tmp
        or-c49:$ cexec /tmp/startSSHDs_v2.sh
        ************************* uc4 *************************
        --------- or-c50---------
        CMD: docker exec --user=root iperf.1.v02k4eyyx6hysb7yfd6jxi29y /usr/sbin/sshd -p 2222
    ```

 - Add the `$HOME/.ssh/config` file with alternate `Port 2222` for our containers (on all hosts where we run MPI)

    ```
        or-c49:$ docker exec -ti iperf.2.mhvsjtylzedauw1hngjrh8bew bash
        mpiuser@c38fe7ae1f62:/$
        mpiuser@c38fe7ae1f62:~$ echo "Host 10.0.0.*" >> $HOME/.ssh/config
        mpiuser@c38fe7ae1f62:~$ echo "    Port 2222" >> $HOME/.ssh/config
        mpiuser@c38fe7ae1f62:/$ cat $HOME/.ssh/config
        Host 10.0.0.*
            Port 2222
        mpiuser@c38fe7ae1f62:/$ 
    ```

 - Create our MPI hostfile (see above showIPs.sh script/output)

    ```
        mpiuser@c38fe7ae1f62:/$ echo "10.0.0.5" >> /benchmarks/runs/hosts
        mpiuser@c38fe7ae1f62:/$ echo "10.0.0.4" >> /benchmarks/runs/hosts
        mpiuser@c38fe7ae1f62:/$ cat /benchmarks/runs/hosts 
        10.0.0.5
        10.0.0.4
        mpiuser@c38fe7ae1f62:/$ 
    ```


Setup C3 Tools
--------------

Install C3 tools to help with parallel commands/scripts, etc.

 
 ```
     # Login as 'root' on "headnode" for Docker nodes
    or-c49:$ docker exec -ti --user root iperf.4.mhvsjtylzedauw1hngjrh8bew bash
    root@c38fe7ae1f62:/# wget http://www.csm.ornl.gov/torc/C3/Software/5.1.3/deb/c3_5.1.3-1_all.deb

     # Instal C3 and any unmet dependencies (-f)
    root@c38fe7ae1f62:/# apt-get install -f -y 
 ```

Note: In some cases I also had to explicitly add the `rsync` and `python` 
packages for C3.

 ```
    root@c38fe7ae1f62:/# apt-get install -y rsync python
 ```

Create the `/etc/c3.conf` file with IPs for all hosts (see showIPs.sh).

Assumming a hosts file like the following: 

 ```
        root#@c38fe7ae1f62:/# cat /tmp/hosts 
        10.0.0.5
        10.0.0.4
 ```

Create the `/etc/c3.conf` as follows:

 ```
        root#@c38fe7ae1f62:/# vi /etc/c3.conf
        root#@c38fe7ae1f62:/# cat /etc/c3.conf
         cluster my_docker_cluster {
             10.0.0.4
             dead remove_for_0-indexing
             10.0.0.5
         }
        root#@c38fe7ae1f62:/# 
 ```

***NOTE***: In some cases, the `USER` envvar is not set when running shells under Docker.  If you see an error about `KeyError: 'USER'`, then define this envvar and things should work properly.

  ```
    mpiuser:$ cexec hostname
    Traceback (most recent call last):
      File "/usr/bin/cexec", line 145, in <module>
        defusername = os.environ[ 'USER' ]
      File "/usr/lib/python2.7/UserDict.py", line 40, in __getitem__
        raise KeyError(key)
    KeyError: 'USER'
  ```
 
  ```
    mpiuser:$ export USER=mpiuser
    mpiuser:$ cexec hostname
    ************************* dkr *************************
    --------- 10.0.0.5---------
    d4f73cbb8393
    mpiuser:$ cexec hostname
  ```


Shutdown IPERF Service
----------------------

And then when we are done we can remove the service (shutdown/kill containers)

   ```
        or-c49:$ docker service ls
        ID            NAME  MODE        REPLICAS  IMAGE
        g4sy6nmn1v10  iperf replicated  2/2       naughtont3/iperf-ubuntu:latest
   ```

   ```
        or-c49:$ docker service rm iperf
        iperf
   ```

   ```
        or-c49:$ docker service ls
        ID  NAME  MODE  REPLICAS  IMAGE
        or-c49:$
   ```

