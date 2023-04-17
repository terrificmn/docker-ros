### nvidia 이미지 이용할 시 nvidia-docker2 설치 필요
# FROM atinfinity/cudagl:11.8.0-cudnn8-devel-ubuntu22.04
FROM osrf/ros:humble-desktop-jammy
FROM nvidia/cudagl:11.3.0-devel
# geegraphic area choice disable
ENV DEBIAN_FRONTEND noninteractive
# setup locale
ENV LANG en_US.UTF-8
ENV LC_ALL C.UTF-8
ENV ROS_DISTRO humble

# RUN apt-get update && apt-get install -y curl && \
#     curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg \
#     sh -c "echo deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null

RUN apt-get update && sudo apt install -y --no-install-recommends \
    ros-humble-desktop \
    ros-dev-tools \ 
    git vim sudo \
    && rm -rf /var/lib/apt/lists/*

# build시 사용 // RUN에서
ARG USER=docker_humble
ARG HOME=/home/docker_humble
ARG WORKSPACE=dr_ros2_ws

## scripts 생성 후 복사
RUN mkdir -p ./scripts/include  
## for create user
COPY ./scripts/create_user.sh ./scripts/
COPY ./scripts/include/.sr ./scripts/include/open_sr \ 
    ./scripts/include/
# WORKDIR /
## Create user 
RUN /bin/bash -c "./scripts/create_user.sh"
## remove unused scripts 
RUN rm -rf ./scripts

# 추후 필요시 파일 mv 및 권한 설정해주기 (현재는 파일 삭제)
USER ${USER}
WORKDIR ${HOME}

## 셋업 bash 부분이 
RUN echo "source /opt/ros/humble/setup.bash" >> ${HOME}.bashrc
RUN echo "source ${HOME}/${WORKSPACE}/install/setup.bash" >> ${HOME}.bashrc

## ENTRYPOINT의 script 실행 대신 docker-compose.yml 의 command 사용


# ## user로 실행해주기 위함 (roscore, 퍼미션 에러 등 방지) ##!!! .passwd 파일 만들고 실행!
## copy 위치가 /에서 HOME으로 바뀜 (유저)
RUN mkdir -p ./scripts/include
COPY ./scripts/installation_carto_abseil.sh ./scripts/
COPY ./scripts/include/.docker-sr ./scripts/include/docker_common \
    ./scripts/include/pkg_name_var ./scripts/include/read_sr \
    ./scripts/include/
