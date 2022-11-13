FROM ros:noetic-ros-base-focal
ENV DEBIAN_FRONTEND=noninteractive
# desktop-full 설치
RUN apt-get update && apt-get install -y \
    ros-noetic-desktop-full

# bootstrap tools 설치
RUN apt-get install --no-install-recommends -y \
    build-essential \
    python3-rosdep \
    python3-rosinstall \
    python3-vcstools \
    python3-wstool \
    && rm -rf /var/lib/apt/lists/*

# Mesa libraries 설치 (AMD용) // amd 없이 시도해보기
# RUN apt-get update && \
#   apt-get -y install libgl1-mesa-glx libgl1-mesa-dri mesa-utils \
#   vim gedit && \
#   rm -rf /var/lib/apt/lists/*

# rsodep 최초실행  init 및 update만 하면 sudo 로 하라는 에러발생
# 최초 빌드 실패했을 경우에는 주석처리
RUN rosdep init \
  && rosdep update --rosdistro $ROS_DISTRO

RUN apt-get update && \
  apt-get install -y software-properties-common \ 
  && rm -rf /var/lib/apt/lists/*

## build (RUN 컨맨드에서 사용. .env는 안됨)
ARG USER=docker_noetic
ARG HOME=/home/docker_noetic

## user 만드는 것이랑 HOME 및 USER 지정
## HOME 지정은 env에서
## Create user "docker_noetic"
RUN useradd -m $USER && \
    ## password
    echo "$USER:pass" | chpasswd && \
    ## root privileges
    adduser $USER sudo && \
    cp /root/.bashrc $HOME

## .env와 호환 안될 수도 있음. 안되면 아래것 실행
USER $USER
WORKDIR $USERHOME

## set user, not compitable with ARG
# USER docker_noetic
# WORKDIR /home/docker_noetic

RUN echo 'source /opt/ros/$ROS_DISTRO/setup.bash' >> /home/docker_noetic/.bashrc
  # echo "source ${HOME}/docker_ws/devel/setup.bash" >> /root/.bashrc
