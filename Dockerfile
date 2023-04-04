## nvidia 이미지 이용 ros melodic - rviz 실행 문제 없음
FROM nvidia/cudagl:11.3.1-devel-ubuntu20.04

# geegraphic area choice disable
ENV DEBIAN_FRONTEND noninteractive
# setup locale
ENV LANG en_US.UTF-8

RUN apt-get update && apt-get install -y curl && \ 
    sh -c "echo deb http://packages.ros.org/ros/ubuntu focal main" > /etc/apt/sources.list.d/ros-latest.list && \
    curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -

RUN apt-get update && apt-get install -y ros-noetic-desktop-full

RUN apt-get install --no-install-recommends -y \
    build-essential \
    python3-rosdep \
    python3-rosinstall \
    python3-rosinstall-generator \
    python3-wstool 

# rsodep 최초실행  init 및 update만 하면 sudo 로 하라는 에러발생
RUN rosdep init \
  && rosdep update --rosdistro noetic

RUN apt-get update && \
    apt-get install -y software-properties-common \ 
    python3-catkin-tools \
    vim \
    && rm -rf /var/lib/apt/lists/*

# env파일 호환 안됨. 같은 값으로 설정
ARG USER=docker_noetic
ARG HOME=/home/docker_noetic
ARG WORKSPACE=docker_ws

## Create user "docker_noetic"
RUN useradd -m $USER && \
    echo "$USER:password" | chpasswd && \
    adduser $USER sudo && \
    cp /root/.bashrc $HOME

######
USER docker_noetic
WORKDIR ${HOME}
###############

RUN echo 'source /opt/ros/noetic/setup.bash' >> ${HOME}/.bashrc && \
    echo "source ${HOME}/${WORKSPACE}/devel/setup.bash" >> ${HOME}/.bashrc

## COPY, ENTRYPOINT 주석 해제 시 ros_entrypoint.sh 에 roscore/ rosrun/ roslaunch 등을 설정해줘야한다(현재 모두 주석처리됨)
## 주석 해제시에는 docker 작동하므로 docker exec 으로 실행해서 접근한다 
COPY ./ros_entrypoint.sh ./
## shell script를 실행하려면 실행권한을 줘야하지만 현재 일반 유저로 되어 있어서 스킵 후 host com 쪽에서 권한 생성
ENTRYPOINT ["./ros_entrypoint.sh"]  

## 참고: docker-compose.yml 에서 roscore 안됨;; 
## 아마도 nvidia 이미지여서 ros전용 이미지가 아닌 nvidia 이미지여서 처음 기본적으로 생성되는  
## entrypoint관련 sh스크립트가 없는 것 때문에 그런 것 같다.(추정)
