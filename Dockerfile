## ROS melodic (amd radeon 문제 없음)
FROM ros:melodic-ros-core-bionic

RUN apt-get update && apt-get install -y \
    ros-melodic-desktop-full

# 일반적인 melodic 설치위한 과정
RUN apt-get install --no-install-recommends -y \
    build-essential \
    python-rosdep \
    python-rosinstall \
    python-vcstools \
    python-rosinstall-generator \
    python-wstool \
    && rm -rf /var/lib/apt/lists/*

# Mesa libraries 설치 (AMD용)
RUN apt-get update && \
  apt-get -y install libgl1-mesa-glx libgl1-mesa-dri mesa-utils \
  vim gedit && \
  rm -rf /var/lib/apt/lists/*

# rsodep 최초실행  init 및 update만 하면 sudo 로 하라는 에러발생
RUN rosdep init \
  && rosdep update \
  && rosdep fix-permissions

RUN apt-get update && \
  apt-get install -y software-properties-common sudo   

# build시 사용 // RUN에서
ARG USER=docker_melodic
ARG HOME=/home/docker_melodic

## Create user "docker_melodic"
RUN useradd -m $USER  && \
    ## password
    echo "$USER:pass" | chpasswd && \
    ## root privileges, (sudo install필요)
    adduser $USER sudo && \
    cp /root/.bashrc $HOME

## set 유저, 시작 위치 ## ARG랑 호환 안됨
USER docker_melodic
WORKDIR /home/docker_melodic

RUN echo 'source /opt/ros/melodic/setup.bash' >> /home/docker_melodic/.bashrc
