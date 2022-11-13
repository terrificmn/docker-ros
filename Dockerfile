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
    python3-rosinstall-generator \
    python3-wstool \
    && rm -rf /var/lib/apt/lists/*

# rsodep 최초실행  init 및 update만 하면 sudo 로 하라는 에러발생
# 메뉴얼에도 처음에는 init을 해주라고 되어 있는데 뭔가 업데이트 되었는지 init을 하면 에러발생
# 주석처리하고 사용
# RUN rosdep init \
#   && rosdep update --rosdistro $ROS_DISTRO

RUN apt-get update && \
  apt-get install -y software-properties-common \ 
  && rm -rf /var/lib/apt/lists/*

## build (RUN 컨맨드에서 사용. .env는 안됨)
ARG USER=docker_noetic
ARG HOME=/home/docker_noetic

## user 만드는 것이랑 HOME 및 USER 지정
## Create user "docker_noetic"
RUN useradd -m $USER && \
    ## password :이하가 password
    echo "$USER:pass" | chpasswd && \
    ## root privileges
    adduser $USER sudo && \
    cp /root/.bashrc $HOME

## .env와는 호환이 안됨. 위의 ARG 변수 그대로 사용
USER $USER
WORKDIR $HOME

RUN echo 'source /opt/ros/$ROS_DISTRO/setup.bash' >> /home/docker_noetic/.bashrc
# echo "source ${HOME}/docker_ws/devel/setup.bash" >> /root/.bashrc
