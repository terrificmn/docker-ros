FROM ros:melodic-ros-core-bionic

# 또는 아예 desktop풀이미지 FROM osrf/ros:melodic-desktop-full 로 받기
# 해보지는 않음 (아래의 RUN으로 ros-melodic-desktop-full 버전이 다 설치되어 있는지는 모르겠음)

RUN apt-get update && apt-get install -y \
    ros-melodic-desktop-full

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
RUN apt-get update && \
  apt-get -y install libgl1-mesa-glx libgl1-mesa-dri mesa-utils \
  vim gedit && \
  rm -rf /var/lib/apt/lists/*

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
RUN useradd -m ${USER} && \
    #echo "docker_melodic:docker_melodic" | chpasswd && adduser docker_melodic sudo && \
    echo "${USER}:${PASSWORD}" | chpasswd -e && \
    # add sudo support (so installed sudo above)
    echo ${USER} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USER} && \
    && chmod 0440 /etc/sudoers.d/${USER} && \
    #권한 살펴보기
    ## cp /root/.bashrc ${HOME} && \  ## bashrc 생기는 지 확인 필요
    ## mkdir ${HOME}/catkin_ws && \ ##docker-compose 에서 volumns연결시 만듬
    chown -R ${USER}:${USER} ${USERHOME}

## set 유저, 시작 위치 
USER ${USER}
WORKDIR ${USERHOME}

RUN echo 'source /opt/ros/$ROS_DISTRO/setup.bash' >> ${USERHOME}/.bashrc && \
  echo "source ${USERHOME}/docker_ws/devel/setup.bash" >> ${USERHOME}/.bashrc
