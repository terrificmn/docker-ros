#!/bin/bash
## .bashrc 파일이 만들어졌지만 setup.bash를 다시 읽어야 roslaunch 명령어 인식함
source "/opt/ros/noetic/setup.bash"
source "/home/docker_noetic/docker_ws/devel/setup.bash"
##########################
### roscore || rosrun pkg_name node_name || roslaunch pkg_name launchfile_name 중에 선택
### ros_entrypoint.sh 런치파일 변경 시에는 docker compose build를 다시 해야함
### roslaunch 실행이 없다면 도커 up하면 바로 exit하게 됨 
##########################
roscore