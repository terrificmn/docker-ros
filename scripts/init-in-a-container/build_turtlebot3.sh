#!/bin/bash
### 최초 build가 되고 compose up 이 된 후에 수동으로 실행해준다. 

tb_ws=${HOME}/docker_ros2_tb_ws
echo ${HOME}/turtlebot3

if [ -d ${HOME}/turtlebot3 ]; then
    mkdir -p ${tb_ws}/src
    mv ${HOME}/turtlebot3 ${tb_ws}/src
    echo "turtlebot3 moved to src"

    cd ${tb_ws}
    source /opt/ros/humble/setup.bash
    colcon build --symlink-install
else
    echo "turtlebot3 not found. It's not for the first time."
fi
