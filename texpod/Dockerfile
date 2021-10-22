###########################################################################
#
# To rebuild image:
#   docker build -t="naughtont3/<IMAGENAME>" .
#   docker push naughtont3/<IMAGENAME>
#
# To rebuild image (with private git repos):
#   # See: https://help.github.com/articles/creating-an-access-token-for-command-line-use/
#   docker build --build-arg=GITHUB_TOKEN=$(cat mytoken) -t="naughtont3/<IMAGENAME>" .
#
# To run image (start container):
#   docker run -d -P --name <NAME> naughtont3/<IMAGENAME> /bin/sleep infinity
#
# To run image (start container) with bind-mounted host dir:
#   docker run -d -P --name <NAME> \
#           -v /home/data:/data  naughtont3/<IMAGENAME> /bin/sleep infinity
#
# To attach to the running container:
#   docker exec -ti <NAME> /bin/bash
#
# Examples:
#   docker build -t="naughtont3/texpod" .
#   docker push naughtont3/texpod
#   docker run -d -P --name texdev naughtont3/texpod /bin/sleep infinity
#   docker exec -ti texdev /bin/bash
#
###########################################################################
#
# NOTES:
# - 21oct2021: Initial creation
#
###########################################################################


FROM ubuntu:20.04
MAINTAINER Thomas Naugthon <naughtont@ornl.gov>

##################################################################
#
# Build Arguments to Customize Image Settings
#

ENV MY_USER="texuser"

##################################################################

# This will prevent questions from being asked during the install
ENV DEBIAN_FRONTEND noninteractive

ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone

# Install various useful/prereq packages
#
# - Install SSH client
#    o Note: We use 'ssh-keygen' from openssh-client in add 'feduser' step.)
# - Get ca-certs so HTTPS requests (e.g., git clone) work
RUN apt-get -y update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        libssl-dev \
        make \
        openssh-client \
        patchutils \
        perl \
        pkg-config \
        python3-minimal \
        python3-venv \
        rsyslog \
        tar \
        texlive-fonts-recommended \
        texlive-latex-extra \
        texlive-plain-generic \
        texlive-bibtex-extra \
        vim \
        wget \
        zlib1g-dev \
    && apt-get clean

# TJN: Note ssh-keygen of /etc/ssh/ssh_host_ecdsa_key may exist, so just ';' not '&&' cmds
RUN useradd -c "LaTex User" -m -p 'dabears' -s /bin/bash $MY_USER \
    && su -c "echo 'export PATH=\$HOME/bin:\$PATH' >> ~/.bashrc" $MY_USER \
    && su -c "/usr/bin/ssh-keygen -t ecdsa -f ~/.ssh/id_ecdsa -q -N ''" $MY_USER \
    && su -c "cat ~/.ssh/id_ecdsa.pub  >> ~/.ssh/authorized_keys" $MY_USER \
    && ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -q -N "" \
     ; su -c "echo -n '* ' > ~/.ssh/known_hosts \
       && cat /etc/ssh/ssh_host_ecdsa_key.pub >> ~/.ssh/known_hosts" $MY_USER \
    && su -c "echo '[alias]'                 >> ~/.gitconfig" $MY_USER \
    && su -c "echo '    st = status'      >> ~/.gitconfig" $MY_USER \
    && su -c "echo '    ci = commit -s'   >> ~/.gitconfig" $MY_USER \
    && su -c "echo '    br = branch'      >> ~/.gitconfig" $MY_USER \
    && su -c "echo '    co = checkout'    >> ~/.gitconfig" $MY_USER \
    && su -c "echo '    ls = ls-files'    >> ~/.gitconfig" $MY_USER \
    && su -c "mkdir /home/$MY_USER/sharedir" $MY_USER \
    && echo "LaTeX User ($MY_USER) created"

# Default to running as our user
USER $MY_USER

CMD ["/bin/bash"]
