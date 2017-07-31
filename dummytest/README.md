dummytest
=========

Dummy "test" container.



Example Commands
----------------
- Quick test: 

    ```
     docker run --rm -ti  naughtont3/dummytest lsb_release -a

    ```

- Build/Upload image:

    ```
    docker build -t="naughtont3/dummytest" .
    docker push naughtont3/dummytest 
    ```


Building 'dummytest' Docker Image
---------------------------------------
- Run the [dockerhub-build-push.sh](dockerhub-build-push.sh) script




Personal Access Tokens
----------------------

When using private Git repositories you need some way to pass authentication
information, which is used in the Dockerfiles for 'git clone' commands. 
To avoid embedding username/passwords, Github supports the generation of
"Personal access tokens" that can be passed to Git for authentication.

  https://help.github.com/articles/creating-an-access-token-for-command-line-use

In the current Dockerfile the ```GITHUB_TOKEN``` argument is used to clone
the private repositories.

- Step-1) Generate the Personal Access Token at Github
    - https://help.github.com/articles/creating-an-access-token-for-command-line-use

- Step-2) Save the token as a file (one line only), e.g., "mytoken"

    ```
    vi mytoken

    wc -l mytoken 
    1 mytoken
    ```

- Step-3) Run Docker build, passing the  ```--build-arg``` (reading token from file):

    ```
    docker build --build-arg=GITHUB_TOKEN=$(cat mytoken) -t="naughtont3/dummytest-mpi" .
    ```

- ***NOTE*** DO NOT SAVE YOUR TOKEN TO REPOSITORY OR GIVE TO OTHER USERS!

- Note: If using the  'dockerhub-build-push.sh', it recognized a file named
    ```mytoken``` in current working directory and will pass that seamlessly.



NOTES
-----
- Started as test related to test for Python2.7 ascii/utf-8 encoding.

