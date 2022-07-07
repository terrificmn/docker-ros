#FROM nvidia/cuda:10.0-devel-ubuntu18.04
FROM nvidia/cudagl:11.3.1-devel-ubuntu18.04

# setup locale
ENV LANG en_US.UTF-8
#######3 https://github.com/jacknlliu/ros-docker-images/blob/master/ros/indigo/indigo-desktop-full/amd-intel-graphics/gazebo7/Dockerfile
#참고해서 수정해보기
#랭귀지 설정에서 막힘

#FROM ros:melodic-ros-core-bionic

# 또는 아예 desktop풀이미지 FROM osrf/ros:melodic-desktop-full 로 받기

# ENV USER=${USER}
# ENV USERHOME=${USERHOME}
# ENV PASSWORD=${PASSWORD}

RUN echo "deb http://packages.ros.org/ros/ubuntu bionic main" > /etc/apt/sources.list.d/ros-latest.list && \
    # setup keys
    apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

# RUN apt-get update && apt-get install -y curl && \  

RUN apt-get install -y ros-melodic-desktop-full

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
# RUN apt-get update && \
#   apt-get -y install libgl1-mesa-glx libgl1-mesa-dri mesa-utils \
#   vim gedit && \
#   rm -rf /var/lib/apt/lists/*

# rsodep 최초실행  init 및 update만 하면 sudo 로 하라는 에러발생
RUN rosdep init \
  && rosdep update \
  && rosdep fix-permissions

RUN apt-get update && \
  apt-get install -y software-properties-common sudo   
  ## sudo는 비번 관련 ubuntu용

# user 만드는 것이랑 HOME 및 USER 지정
## HOME 지정은 env에서
## Create user "docker_noetic"
RUN useradd -m docker_melodic && \
    echo "docker_melodic:docker_melodic" | chpasswd && adduser docker_melodic sudo && \
    ## adduser {비번} sudo 임
    ## cp /root/.bashrc ${HOME} && \  ## bashrc 생기는 지 확인 필요
    ## mkdir ${HOME}/catkin_ws && \ ##docker-compose 에서 volumns연결시 만듬
    chown -R --from=root docker_melodic /home/docker_melodic

    #echo "${USER}:${PASSWORD}" | chpasswd && adduser ${USER} sudo && \
    ## 환경 변수가 안 먹힘 - 테스트 해보야 할 듯
    ## add sudo support (so installed sudo above)
    #echo ${USER} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USER} && \
    #chmod 0440 /etc/sudoers.d/${USER} && \
    #권한 살펴보기
    ## cp /root/.bashrc ${HOME} && \  ## bashrc 생기는 지 확인 필요
    ## mkdir ${HOME}/catkin_ws && \ ##docker-compose 에서 volumns연결시 만듬
    #chown -R ${USER}:${USER} ${USERHOME}

## set 유저, 시작 위치 
USER docker_melodic
WORKDIR /home/docker_melodic
# 환경변수가 먹통 이유 찾아야함
# USER ${USER}
# WORKDIR ${USERHOME}

#RUN echo 'source /opt/ros/$ROS_DISTRO/setup.bash' >> /home/docker_melodic/.bashrc && \
#  echo "source ${USERHOME}/docker_ws/devel/setup.bash" >> /home/docker_melodic/docker_ws/.bashrc
