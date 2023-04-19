#!/bin/bash
## free fleet 설치하기 위한 준비.. script 파일 카피
# 현재 scripts 디렉토리에 있는 파일을 dr_ros2_ws로 복사 후 실행
# (docker 컨테이너에 공유된 디렉토리는 dr_ros2_ws이므로 복사)
cp ${HOME}/Workspace/docker-ros/scripts/ff_install_start.sh \
    ${HOME}/Workspace/docker-ros/dr_ros2_ws/ff_install_start.sh
echo "script file copied... done!"
echo "now you can enter the container using the exec command...";
echo "Prompt will be changed"
docker exec -it ros2 bash