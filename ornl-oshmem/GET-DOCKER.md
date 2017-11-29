Get Docker
----------

Summary of steps to get the latest release of Docker, without using the
Linux distribution version.

See the appropriate "Getting Started" page at docker.com, I will focus
on the Linux page (see also: Mac OSX and Windows options).

Install Docker: Linux 
---------------------

Steps taken from https://docs.docker.com/v1.11/linux/step_one
(See also: https://docs.docker.com/engine/installation/)

 - *NOTE* Ensure Docker is not installed already (and if so check version)

   ```
     $ sudo docker info
     [sudo] password for 3t4: 
     sudo: docker: command not found
     $ 
   ```

 - Install ```curl``` if not already installed:

   ```
     sudo apt-get update
     sudo apt-get install curl
   ```

 - Get Docker repo key

   ```
     curl -fsSL https://get.docker.com/gpg | sudo apt-key add -
   ```

 - Get Docker package

   ```
     curl -fsSL https://get.docker.com/ | sh
   ```

 - Add the ```docker``` group to user that will use Docker (without sudo)
   (Remember that user will have to log out and back in for this to take effect!)
      
   ```
      # Example: Add 'docker' group to user '3t4'
     sudo usermod -aG docker 3t4
   ```

 - Verify ```docker``` is installed correctly

   ```
     docker run hello-world
   ```

