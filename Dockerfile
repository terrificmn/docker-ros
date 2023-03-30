FROM ros:noetic-ros-base-focal
ENV DEBIAN_FRONTEND=noninteractive

## mirror matching
RUN sed -i 's/htt[p|ps]:\/\/archive.ubuntu.com\/ubuntu\//mirror:\/\/mirrors.ubuntu.com\/mirrors.txt/g' /etc/apt/sources.list
# desktop-full 설치
RUN apt-get update && apt-get install -y \
    ros-noetic-desktop-full

# bootstrap tools 설치
RUN apt-get install --no-install-recommends -y \
    build-essential \
    python3-rosdep \
    python3-rosinstall \
    python3-rosinstall-generator \
    python3-wstool 

# rsodep 최초실행  init 및 update만 하면 sudo 로 하라는 에러발생
RUN rosdep init \
  && rosdep update --rosdistro $ROS_DISTRO

RUN apt-get update && \
    apt-get install -y software-properties-common \ 
    python3-catkin-tools \
    vim \
    && rm -rf /var/lib/apt/lists/*

## env파일 호환 안됨. 같은 값으로 설정
ARG USER=docker_noetic
ARG HOME=/home/docker_noetic
ARG WORKSPACE=catkin_ws

## Create user "docker_noetic"
RUN useradd -m $USER && \
    echo $USER:password | chpasswd && \
    adduser $USER sudo && \
    cp /root/.bashrc $HOME

######
USER docker_noetic
WORKDIR ${HOME}
###############

## windows 에서 x-server가 리스닝 0.0 / 중요 windows에서 실행시 XLaunch 프로그램 실행
ENV DISPLAY=host.docker.internal:0.0  

RUN echo 'source /opt/ros/noetic/setup.bash' >> ${HOME}/.bashrc && \
    echo "source ${HOME}/${WORKSPACE}/devel/setup.bash" >> ${HOME}/.bashrc


