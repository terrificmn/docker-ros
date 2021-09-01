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
  apt-get install -y software-properties-common

RUN echo 'source /opt/ros/$ROS_DISTRO/setup.bash' >> /root/.bashrc && \
  echo "source /root/catkin_ws/devel/setup.bash" >> /root/.bashrc
