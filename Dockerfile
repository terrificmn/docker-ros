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


# rsodep 최초실행  init 및 update만 하면 sudo 로 하라는 에러발생
# RUN rosdep init \
#   && rosdep update --rosdistro $ROS_DISTRO

RUN apt-get update && \
  apt-get install -y software-properties-common \ 
  python3-catkin-tools \
  ros-noetic-rosbridge-server \ 
  ros-noetic-web-video-server \
  && rm -rf /var/lib/apt/lists/*

ARG USER=docker_noetic
ARG USERHOME=/home/docker_noetic
## user 만드는 것이랑 HOME 및 USER 지정
## HOME 지정은 env에서
## Create user "docker_noetic"
RUN useradd -m $USER && \
    ## password :이하가 password
    echo $USER:pass | chpasswd && \
    ## root privileges
    adduser $USER sudo && \
    cp /root/.bashrc $USERHOME
######
USER ${USER}
WORKDIR ${USERHOME}
###############

RUN echo 'source /opt/ros/$ROS_DISTRO/setup.bash' >> ${USERHOME}/.bashrc && \
    echo "source ${HOME}/docker_ws/devel/setup.bash" >> ${USERHOME}/.bashrc
