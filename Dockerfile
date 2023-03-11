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
# 주석처리하고 사용 (특히 Tinker Board2 )
# RUN rosdep init \
#   && rosdep update --rosdistro $ROS_DISTRO

RUN apt-get update && \
  apt-get install -y software-properties-common \ 
  python3-catkin-tools \
  ros-noetic-rosbridge-server \ 
  ros-noetic-web-video-server \
  && rm -rf /var/lib/apt/lists/*

## build (RUN 컨맨드에서 사용. .env는 사용 못하므로 ARG로..)
ARG USER=docker_noetic
ARG HOME=/home/docker_noetic

## user 만드는 것이랑 HOME 및 USER 지정
## Create user "docker_noetic"  
## pass워드는 ARG/ENV로 설정해도 안 됨-비번이틀리게됨 - 하드코딩은 됨;;(Nov17 2022) 
## ARG에 직접 값을 넣어도 안됨;;-- 패스워드 바꾸려면 컨테이너에 직접 docker exec로 실행해서 바꾸기;;;
RUN useradd -m $USER && \
    ## password :이하가 password
    echo $USER:pass | chpasswd && \
    ## root privileges
    adduser $USER sudo && \
    cp /root/.bashrc $HOME

## GPIO lib install
ARG GPIO_FILE=gpio_lib_c.tar.xz
WORKDIR ${HOME}
COPY ./lib_tar/${GPIO_FILE} ./
RUN mv ./${GPIO_FILE} /usr/local/share/ 
WORKDIR /usr/local/share
RUN tar -xvf ${GPIO_FILE}
WORKDIR /usr/local/share/gpio_lib_c_rk3399
RUN ./build

## .env와는 호환이 안됨. 위의 ARG 변수 그대로 사용
USER $USER
WORKDIR $HOME

RUN echo "source /opt/ros/noetic/setup.bash" >> ${HOME}/.bashrc
RUN echo "source ${HOME}/docker_ws/devel/setup.bash" >> ${HOME}/.bashrc

## dev일 경우에는 docker-comopse의 command 사용해서 roscore가 편함
## 단, roslaunch 는 COPY ENTRYPOINT 사용할 것
COPY ./entrypoint_roslaunch.sh ./
# ## host컴의 파일 그대로 사용 (권한도 +x 해줄것: COPY가 권한까지도 복사)
ENTRYPOINT ["./entrypoint_roslaunch.sh"]