#!/bin/bash
## .bashrc 파일이 만들어졌지만 setup.bash를 다시 읽어야 roslaunch 명령어 인식함
source "/opt/ros/melodic/setup.bash"
source "/home/docker_melodic/docker_ws/devel/setup.bash"
# export TURTLEBOT3_MODEL=waffle  ## turtlebot3 example
# roslaunch turtlebot3_teleop turtlebot3_teleop_key.launch ## 런치파일 자체는 실행되는 것 확인
# roslaunch turtlebot3_gazebo turtlebot3_house.launch ## rosdep 문제 발생하지만 일단 roslaunch까지는 실행됨
