HPCC: Multi-host MPI 
--------------------

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
    docker network create --attachable -d overlay tjn-netw1
```

Deploy our "hpcc" service (sleep infinity) on the swarm nodes

```
   docker service create \
            --name hpcc \
            --network tjn-netw1 \
            --replicas 4 \
            naughtont3/hpcc-mpi \
            sleep infinity
   docker service ls
```

Show service "hpcc" running on all the nodes

```
    or-c49:$ docker service ls
    ID            NAME  MODE        REPLICAS  IMAGE
    g4sy6nmn1v10  hpcc  replicated  4/4       naughtont3/hpcc-mpi:latest
    or-c49:$ docker service ps hpcc
    ID            NAME    IMAGE                       NODE    DESIRED STATE  CURRENT STATE           ERROR  PORTS
    v02k4eyyx6hy  hpcc.1  naughtont3/hpcc-mpi:latest  or-c50  Running        Running 28 seconds ago         
    smunank7hy15  hpcc.2  naughtont3/hpcc-mpi:latest  or-c52  Running        Running 31 seconds ago         
    m88b7dcuyukv  hpcc.3  naughtont3/hpcc-mpi:latest  or-c51  Running        Running 49 seconds ago         
    mhvsjtylzeda  hpcc.4  naughtont3/hpcc-mpi:latest  or-c49  Running        Running 6 seconds ago 
```

Get the IP address for the service on our local node (or-c49):

```
    # Get the name of the Service instance running on localhost (or-c49)
    or-c49:$ docker service ps --filter node=or-c49 hpcc
    ID            NAME    IMAGE                       NODE    DESIRED STATE  CURRENT STATE               ERROR  PORTS
    mhvsjtylzeda  hpcc.4  naughtont3/hpcc-mpi:latest  or-c49  Running        Running about a minute ago
```

```
  #####
  # BUT CAN ACTUALLY JUST GET THE SINGLE LOCAL CONTAINER INSTANCE TOO
  #####

     # Get the name of our local container within the Service
    or-c49:$ docker ps --filter name=hpcc --format "{{.Names}}"
    hpcc.4.mhvsjtylzedauw1hngjrh8bew
```

Then get the actual IP address (see: [scripts/showIPs.sh](scripts/showIPs.sh))

```
    or-c49:$ docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' hpcc.4.mhvsjtylzedauw1hngjrh8bew
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
    or-c49:$ docker ps --filter name=hpcc --format "{{.Names}}"
    hpcc.4.mhvsjtylzedauw1hngjrh8bew

    or-c49:$ docker exec -ti hpcc.4.mhvsjtylzedauw1hngjrh8bew bash
    mpiuser@c38fe7ae1f62:/$
```

Extra Setup
-----------
I now have to setup/start the SSHD to allow us to connect between the 
containers spanning hosts (connected via the docker network).
 - See also: [scripts/startSSHDs_v2.sh](scripts/startSSHDs_v2.sh)

Lot of manual stuff...

 - Add the SSHKEY from my "headnode" container to each container
 - Start SSHD on port 2222 in each container

    ```
        or-c49:$ ./startSSHDs_v2.sh 
        or-c49:$ cpush startSSHDs_v2.sh /tmp
        or-c49:$ cexec /tmp/startSSHDs_v2.sh
        ************************* uc4 *************************
        --------- or-c50---------
        CMD: docker exec --user=root hpcc.1.v02k4eyyx6hysb7yfd6jxi29y /usr/sbin/sshd -p 2222
        --------- or-c51---------
        CMD: docker exec --user=root hpcc.3.m88b7dcuyukv85ckpzgt95aln /usr/sbin/sshd -p 2222
        --------- or-c52---------
        CMD: docker exec --user=root hpcc.2.smunank7hy15e06n31ksu7k99 /usr/sbin/sshd -p 2222
    ```

 - Add the `$HOME/.ssh/config` file with alternate `Port 2222` for our containers

    ```
        or-c49:$ docker exec -ti hpcc.4.mhvsjtylzedauw1hngjrh8bew bash
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
        mpiuser@c38fe7ae1f62:/$ echo "10.0.0.6" >> /benchmarks/runs/hosts
        mpiuser@c38fe7ae1f62:/$ echo "10.0.0.3" >> /benchmarks/runs/hosts
        mpiuser@c38fe7ae1f62:/$ echo "10.0.0.5" >> /benchmarks/runs/hosts
        mpiuser@c38fe7ae1f62:/$ echo "10.0.0.4" >> /benchmarks/runs/hosts
        mpiuser@c38fe7ae1f62:/$ cat /benchmarks/runs/hosts 
        10.0.0.6
        10.0.0.3
        10.0.0.5
        10.0.0.4
        mpiuser@c38fe7ae1f62:/$ 
    ```

 - Run MPI command using this hostfile

    ```
        mpiuser@c38fe7ae1f62:/$ mpirun --hostfile /benchmarks/runs/hosts \
                                    --map-by node -np 4 hostname
        c38fe7ae1f62
        0714007d069f
        27fe9375452b
        ec2f6e2a41db
    ```

Shutdown HPCC Service
---------------------

And then when we are done we can remove the service (shutdown/kill containers)

   ```
        or-c49:$ docker service ls
        ID            NAME  MODE        REPLICAS  IMAGE
        g4sy6nmn1v10  hpcc  replicated  4/4       naughtont3/hpcc-mpi:latest
   ```

   ```
        or-c49:$ docker service rm hpcc
        hpcc
   ```

   ```
        or-c49:$ docker service ls
        ID  NAME  MODE  REPLICAS  IMAGE
        or-c49:$
   ```

