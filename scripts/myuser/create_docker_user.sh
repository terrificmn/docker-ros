#!/bin/bash
source ./scripts/myuser/read_sr

# echo $password

useradd -m $USER && \
    echo "$USER:$password" | chpasswd && \
    adduser $USER sudo && \
    cp /root/.bashrc $HOME