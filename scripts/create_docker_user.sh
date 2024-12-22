#!/bin/bash
source ./scripts/include/read_sr

echo $password

useradd -m $USER && \
    echo "$USER:$password" | chpasswd && \
    adduser $USER sudo && \
    cp /root/.bashrc $HOME