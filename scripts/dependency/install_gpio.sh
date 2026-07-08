#!/bin/bash

## get password
source ./scripts/myuser/read_sr

GPIO_FILE=gpio_lib_c.tar.xz
echo $password | sudo -S cp -r ~/lib/gpio/$GPIO_FILE /usr/local/share/
cd /usr/local/share
echo $password | sudo -S tar xvf $GPIO_FILE
cd /usr/local/share/gpio_lib_c_rk3399
sudo $password | sudo -S ./build
