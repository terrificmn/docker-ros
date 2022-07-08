FROM nvidia/cudagl:11.3.1-devel-ubuntu18.04

# geegraphic area choice disable
ENV DEBIAN_FRONTEND noninteractive
# setup locale
ENV LANG en_US.UTF-8

# FROM ros:melodic-ros-core-bionic
# 또는 아예 desktop풀이미지 FROM osrf/ros:melodic-desktop-full 도 가능하나 현재 rviz를 띄우기 위해서 nvidia 이미지 사용 도전 중

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
  ## sudo는 비번 관련 ubuntu용

# build시 사용 // RUN에서
ARG USER=docker_melodic
ARG HOME=/home/docker_melodic


# user 만드는 것이랑 HOME 및 USER 지정
## HOME 지정은 env에서
## Create user "docker_noetic"
#RUN useradd -m docker_melodic && \
RUN useradd -m $USER && \
    ## add sudo support (so installed sudo above)
    echo "$USER:$USER" | chpasswd && adduser $USER sudo && \
    #echo "docker_melodic:docker_melodic" | chpasswd && adduser ${USER} sudo && \
    chown -R --from=root $USER $HOME
    #권한 살펴보기
    ## cp /root/.bashrc ${HOME} && \  ## bashrc 생기는 지 확인 필요
    ## mkdir ${HOME}/catkin_ws && \ ##docker-compose 에서 volumns연결시 만듬
    #chown -R ${USER}:${USER} ${USERHOME}

## set 유저, 시작 위치 ## ARG랑 호환 안됨
USER docker_melodic
WORKDIR /home/docker_melodic

# setup entrypoint
#COPY ./entrypoint.sh /home/docker_melodic/
#CMD ["chown" "--from=root" "docker_melodic" "/entrypoint.sh"]
#ENTRYPOINT ["/home/docker_melodic/entrypoint.sh"]
## permision 에러 해결해야함

#RUN echo 'source /opt/ros/melodic/setup.bash' >> /home/docker_melodic/.bashrc
#CMD ["echo" "source /opt/ros/$ROS_DISTRO/setup.bash" ">>" "/home/docker_melodic/.bashrc"]

# 빌드까지는 완료
