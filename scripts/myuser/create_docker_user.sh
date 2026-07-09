#!/bin/bash
source ./scripts/myuser/read_sr

# echo $password
### FYI: ros2 jazzy desktop image has a user named ubuntu already unlike ros2 humble desktop 
## redirect output (silent)
if id "ubuntu" &>/dev/null; then
    echo "User ubuntu exists. Now change the username"
    ### to check out the log (due to the fast build-process)
    sleep 3s
    usermod -l $USER ubuntu && groupmod -n $USER ubuntu && \
        usermod -d /home/$USER -m $USER \
        && echo "$USER:$password" | chpasswd
else
    echo "User ubuntu does not exist. Now create a new user."
    sleep 3s
    useradd -m $USER && \
    echo "$USER:$password" | chpasswd && \
    adduser $USER sudo && \
    cp /root/.bashrc $HOME
fi

### sudo 및 no password (아직 test 안해봄)
# usermod -aG sudo $USER \
#     && echo "$USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USER
