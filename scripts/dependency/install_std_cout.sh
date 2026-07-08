#!/bin/bash

## get password
source ./scripts/myuser/read_sr

cd ~/lib/std_cout
tar xvf std_cout_v1.2.3_ubuntu20.tar.xz

cd ready-install

echo $password | sudo -S ./gether.sh install

echo "install std_cout finished if there is no error."