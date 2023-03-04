## ROS noetic (amd radeon 문제 없음)
FROM ros:noetic-ros-base-focal
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    ros-noetic-desktop-full

RUN echo 'source /opt/ros/$ROS_DISTRO/setup.bash'

RUN apt-get install --no-install-recommends -y \
    build-essential \
    python3-rosdep \
    python3-rosinstall \
    python3-rosinstall-generator \
    python3-wstool \
    && rm -rf /var/lib/apt/lists/*

# Mesa libraries 설치 (AMD용)
RUN apt-get update && \
  apt-get -y install libgl1-mesa-glx libgl1-mesa-dri mesa-utils \
  vim gedit && \
  rm -rf /var/lib/apt/lists/*

# rsodep 최초실행  , 아마 거의 처음 빌드할 때 실패할 듯..아예 스킵해도 될 듯 하기도 함
# RUN rosdep init \
#   && rosdep update \
#   && rosdep fix-permissions

RUN apt-get update && \
  apt-get install -y software-properties-common sudo \
  python3-catkin-tools \
  ros-noetic-rosbridge-server \ 
  ros-noetic-web-video-server \
  && rm -rf /var/lib/apt/lists/*

## build (RUN 컨맨드에서 사용. .env는 사용 못하므로 ARG로..)
ARG USER=docker_noetic
ARG HOME=/home/docker_noetic
ENV USER=${USER}
ENV HOME=${HOME}

## Create user "docker_melodic"
RUN useradd -m $USER  && \
    ## password
    echo "$USER:pass" | chpasswd && \
    ## root privileges, (sudo install필요)
    adduser $USER sudo && \
    cp /root/.bashrc $HOME

## .env와는 호환이 안됨. 위의 ARG 변수 그대로 사용
USER $USER
WORKDIR $HOME

RUN echo 'source /opt/ros/$ROS_DISTRO/setup.bash' >> ${HOME}/.bashrc
RUN echo "source ${HOME}/docker_ws/devel/setup.bash" >> ${HOME}/.bashrc

# 사용하려면 주석해제
# COPY ./entrypoint_roslaunch.sh ./
# ## host컴의 파일 그대로 사용 (권한도 +x 해줄것)
# ENTRYPOINT ["./entrypoint_roslaunch.sh"]