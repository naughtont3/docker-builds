THIS MOVED
----------

- [MOVED](./MOVED.md)


SAL9000 Starter Info. for Hobbes Demo-v1.0 with Docker
------------------------------------------------------

SAL9000: Install/Setup Docker 
-----------------------------

1. Get Docker on the node if not already there (e.g., docker-v1.11)
    - [Getting Docker](../GET-DOCKER.md)

   Alternate/See also:
    - https://docs.docker.com/v1.11/linux/step_one/
    - https://docs.docker.com/engine/installation/
   

2. Group add on SAL9000 cluster...

  - NOTE: On the SAL9000 cluster, you will want to run the 'docker' group
    addition from the headnode.  This is so you are part of the ```docker```
    group and can run docker w/o ```sudo```.

    ```
      # Add userID to 'docker' group
    3t4@sal9000:~$ sudo usermod -aG docker 3t4
    [sudo] password for 3t4: 
    3t4@sal9000:~$ groups 3t4
    3t4 : 3t4 adm cdrom sudo dip plugdev lpadmin sambashare osudoers xvirt docker
    ```
 
    ```
    # Push changes to SI node image 
    3t4@sal9000:~$ sudo cp /etc/passwd /etc/passwd- /etc/group /etc/group- \
        /etc/shadow /etc/shadow- "/var/lib/systemimager/images/oscarimage/etc/"
    ```

    ```
    # Push changes to compute nodes 
    3t4@sal9000:~$ sudo cpush /etc/passwd /etc/passwd- /etc/group /etc/group- \
        /etc/shadow /etc/shadow- /etc/
    ```


3. Sanity test of new Docker install
   (See also: https://docs.docker.com/v1.11/linux/step_one/)

    ```
    3t4@sal9000:~$ docker run hello-world
    ```



Build Hobbes XPMEM Kernel Module
--------------------------------

1. Build Host XPMEM
    - [README.md#host-xpmem](./README.md#host-xpmem)
    - URL:https://github.com/naughtont3/docker-builds/tree/master/hobbes-dtk-demo/README.md#host-xpmem



Run Hobbes DTK Demo-v1.0 Container
----------------------------------

1. Run Docker command to start 'naughtont3/hobbes-dtk-demo' container
   NOTE: The first time, it will have to download the image (~10GB) from Dockerhub.

    ```
     # (Useful/Optional) Create shared host/guest scratch dir
     # If do not use scratch dir, remove "-v $HOME/docker_share..." in below cmd
    mkdir $HOME/docker_share/

    docker run -d -P   \
        --name hobbes_demo \
        --device /dev/xpmem \
        -v $HOME/docker_share:/data  \
       naughtont3/hobbes-dtk-demo \
       /bin/sleep infinity
    ```

2. Confirm the ```hobbes-dtk-demo``` (named: 'hobbes_demo') container is running with ```docker ps```

    ```
    docker ps | grep hobbes-dtk-demo
    ```


3. Now you can attach to the container and run the DTK demo_v1.0.
   Start 3 shells so you can see output easily for driver/appA/appB. 
      
    ```
     # Term-1 (Driver) 
    sal9k:$ docker exec -ti hobbes_demo bash 
    root# export PS1="DRIVER# "
    DRIVER# cd /hobbes/src/hobbes_demo/demo_v1.0/config_demo_1.0/DataTransferKit/packages/Adapters/POD_C/test/
    DRIVER# ./DataTransferKitC_API_driver.exe
    ```

    ```
     # Term-2 (appA) 
    sal9k:$ docker exec -ti hobbes_demo bash 
    root# export PS1="APP-A# "
    APP-A# cd /hobbes/src/hobbes_demo/demo_v1.0/config_demo_1.0/DataTransferKit/packages/Adapters/POD_C/test/
    APP-A# ./DataTransferKitC_API_appA.exe
    ```

    ```
     # Term-3 (appB) 
    sal9k:$ docker exec -ti hobbes_demo bash 
    root# export PS1="APP-B# "
    APP-B# cd /hobbes/src/hobbes_demo/demo_v1.0/config_demo_1.0/DataTransferKit/packages/Adapters/POD_C/test/
    APP-B# ./DataTransferKitC_API_appB.exe
    ```

Docker Shutdown/Cleanup
-----------------------
- Follow the normal shutdown and cleanup for Docker.  For completeness,
  we show an example here as well.

1. Exit the three shells for Driver, appA, and appB,  which will stop those
   three containers.

    ```
    DRIVER# exit
    ```

    ```
    APP-A# exit
    ```

    ```
    APP-B# exit
    ```

2. Stop and Delete the primary "system" container running ```sleep infinity```.

    ```
    docker stop hobbes_demo
    docker rm -v hobbes_demo
    ```

    ```
      # Show ALL docker processes to ensure hobbes_demo bits are gone
    docker ps -a | grep hobbes_demo
    ```


