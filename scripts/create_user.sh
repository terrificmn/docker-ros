#!/bin/bash
source ./scripts/include/open_sr

echo $password

useradd -m $USER && \
    echo "$USER:$password" | chpasswd && \
    adduser $USER sudo && \
    cp /root/.bashrc $HOME