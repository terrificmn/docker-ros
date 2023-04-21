FROM osrf/ros:humble-desktop

# geographic area choice disable
ENV DEBIAN_FRONTEND noninteractive
# setup locale
ENV LANG en_US.UTF-8
ENV LC_ALL C.UTF-8
ENV ROS_DISTRO humble

# repository 등록/ ros-humble-desktop 설치 필요 없음 (이미지 자체로 사용)
## python3 setuptools 버전 낮추기
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl software-properties-common \
    ros-dev-tools \ 
    git vim sudo python3-pip && \
    python3 -m pip install setuptools==58.2.0 \ 
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
RUN echo "source /opt/ros/humble/setup.bash" >> ${HOME}/.bashrc
RUN echo "source /usr/share/gazebo/setup.bash" >> ${HOME}/.bashrc
RUN echo "source ${HOME}/${WORKSPACE}/install/setup.bash" >> ${HOME}/.bashrc

## ros2는 roscore 없으므로 따로 실행 없음 - 추후 런치파일 등록
