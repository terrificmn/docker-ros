#!/bin/bash

## get password
source ./scripts/myuser/read_sr

cd ~/lib/std_cout
tar xvf std_cout_v1.2.3_debian11_arm64.tar.xz

cd std_cout_install

echo $password | sudo -S ./gether.sh install

echo "std_cout has been installed. (unless there is an error)"