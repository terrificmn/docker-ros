#!/bin/bash
#### Free Fleet installation
mkdir -p ${HOME}/dr_ros2_ws/src
cd  ${HOME}/dr_ros2_ws/src
git clone https://github.com/open-rmf/free_fleet -b main
git clone https://github.com/open-rmf/rmf_internal_msgs -b main
cd ${HOME}/dr_ros2_ws
rosdep update
sudo apt update
rosdep install --from-paths src --ignore-src --rosdistro humble -yr
source /opt/ros/humble/setup.bash
colcon build --packages-up-to \
    free_fleet ff_examples_ros2 free_fleet_server_ros2 free_fleet_client_ros2
echo "Free Fleet installation finished"