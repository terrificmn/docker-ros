## nvidia 이미지 이용 ros melodic - rviz 실행 문제 없음
FROM nvidia/cudagl:11.3.1-devel-ubuntu18.04

# geegraphic area choice disable
ENV DEBIAN_FRONTEND noninteractive
# setup locale
ENV LANG en_US.UTF-8

RUN echo "deb http://packages.ros.org/ros/ubuntu bionic main" > /etc/apt/sources.list.d/ros-latest.list && \
    # setup keys
    apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

RUN apt-get update && apt-get install -y ros-melodic-desktop-full

# 일반적인 melodic 설치위한 과정
RUN apt-get install --no-install-recommends -y \
    build-essential \
    python-rosdep \
    python-rosinstall \
    python-vcstools \
    python-rosinstall-generator \
    python-wstool \
    && rm -rf /var/lib/apt/lists/*

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

## 셋업 bash 부분이 
RUN echo 'source /opt/ros/melodic/setup.bash' >> /home/docker_melodic/.bashrc
RUN echo 'source /home/docker_melodic/docker_ws/devel/setup.bash' >> /home/docker_melodic/.bashrc

COPY ./ros_entrypoint.sh ./
## shell script를 실행하려면 실행권한을 줘야하지만 현재 일반 유저로 되어 있어서 스킵 후 host com 쪽에서 권한 생성
ENTRYPOINT ["./ros_entrypoint.sh"]  

# 잘 되지만- roscore 안됨;; // noetic에서는 가능하나, melodic에서는 compose의 커맨드가 잘 안되는 듯
