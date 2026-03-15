FROM osrf/ros:jazzy-desktop

# geographic area choice disable
ENV DEBIAN_FRONTEND noninteractive
# setup locale
ENV LANG en_US.UTF-8
ENV LC_ALL C.UTF-8
ENV ROS_DISTRO jazzy

# repository 등록/ ros-humble-desktop 설치 필요 없음 (이미지 자체로 사용)
## python3 setuptools 버전 낮추기
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl software-properties-common \
    ros-dev-tools \ 
    git vim sudo python3-pip \
    && rm -rf /var/lib/apt/lists/*

# build시 사용 // RUN에서
ARG USER=docker_jazzy
ARG HOME=/home/docker_jazzy
ARG WORKSPACE=docker_ros2_ws
ARG WORKSPACE_WEB=web_ws

## scripts 생성 후 복사
RUN mkdir -p ./scripts/myuser
## for create user
COPY ./scripts/myuser/* ./scripts/myuser/

WORKDIR /
## Create user 
RUN /bin/bash -c "./scripts/myuser/create_docker_user.sh"
## remove unused scripts (will be copied to HOME again)
RUN rm -rf ./scripts/myuser

# 추후 필요시 파일 mv 및 권한 설정해주기 (현재는 파일 삭제)
USER ${USER}
WORKDIR ${HOME}
## FYI: copy and run scripts under new user directory
RUN mkdir -p ./scripts/myuser ./scripts/dependency
## FYI: don't need a create_docker_user.sh anymore. and the last line of COPY is the target directory(to).
COPY --chown=1000:1000 ./scripts/myuser/.docker-sr ./scripts/myuser/read_sr \ 
    ./scripts/myuser/

RUN mkdir -p ./lib
COPY --chown=1000:1000 ./lib ./lib
COPY --chown=1000:1000 ./scripts/dependency/install_std_cout.sh ./scripts/dependency/install_std_cout.sh
RUN /bin/bash -c "./scripts/dependency/install_std_cout.sh"


## 셋업 bash 부분이 
# RUN echo "source /opt/ros/jazzy/setup.bash" >> ${HOME}/.bashrc
# RUN echo "source ${HOME}/${WORKSPACE}/install/setup.bash" >> ${HOME}/.bashrc
# RUN echo "source ${HOME}/${WORKSPACE_TB}/install/setup.bash" >> ${HOME}/.bashrc

## 추후 home에 스크립트 복사는 추후 update 하기
## ros2는 roscore 없으므로 따로 실행 없음 - 추후 런치파일 등록