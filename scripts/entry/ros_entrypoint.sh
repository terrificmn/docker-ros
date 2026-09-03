#!/bin/bash

set -e ##If any command fails, stop 

source /opt/ros/jazzy/setup.bash
source /home/docker_jazzy/docker_ws/install/setup.bash

## FYI: it becomes docker-compose's command. and exec enables that PID 1 is a ros2 launch not a bash
exec "$@" ## all arguments passed to this script 