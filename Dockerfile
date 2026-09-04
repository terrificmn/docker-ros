FROM arm64v8/ros:jazzy-ros-base

# geographic area choice disable
ENV DEBIAN_FRONTEND noninteractive
# setup locale
ENV LANG en_US.UTF-8
ENV LC_ALL C.UTF-8
ENV ROS_DISTRO jazzy

## FYI: 이전 버전과 달리 python 관련 패키지 설치를 좀 더 까다롭게 확인함. virtual environment를 만들거나 python3-venv 를 설치한 후 
## system level 에서 사용할 수 있게 --system-site-packages 옵션 및 환경 변수를 예) ## ENV PATH="/opt/ros_venv/bin:$PATH" 설정,

## FYI: 또는 그냥 system-wide 로 사용할 수 있게 간단하게 env 설정 후 사용
# Tell pip it is okay to install system-wide inside this container
ENV PIP_BREAK_SYSTEM_PACKAGES=1
### setuptools for jazzy (fully supported with Python 3.12)

RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-jazzy-desktop-full \
    curl software-properties-common \
    ros-dev-tools \
    git vim sudo python3-pip \
    net-tools inetutils-ping \
    ros-jazzy-rosbridge-server \
    ros-jazzy-rosbridge-suite \
    ros-jazzy-image-transport-plugins && \
    python3 -m pip install setuptools==68.1.2 \ 
    && rm -rf /var/lib/apt/lists/*

# build시 사용 // RUN에서
ARG USER=docker_jazzy
ARG HOME=/home/docker_jazzy
ARG UID=1000
ARG GID=1000
ARG WORKSPACE=docker_ws
ARG WORKSPACE_WEB=web_ws

## scripts 생성 후 복사
RUN mkdir -p ./scripts/myuser
## for create user
COPY ./scripts/myuser/* ./scripts/myuser/

WORKDIR /
## Create user 
RUN /bin/bash -c "./scripts/myuser/create_docker_user.sh"
## remove unused scripts (will be copied to HOME again)
RUN rm -rf ./scripts/myuser

# 추후 필요시 파일 mv 및 권한 설정해주기 (현재는 파일 삭제)
USER ${USER}
WORKDIR ${HOME}
## FYI: copy and run scripts under new user directory
RUN mkdir -p ./scripts/myuser ./scripts/dependency
## FYI: don't need a create_docker_user.sh anymore. and the last line of COPY is the target directory(to).
COPY --chown=1000:1000 ./scripts/myuser/.docker-sr ./scripts/myuser/read_sr \ 
    ./scripts/myuser/

RUN mkdir -p ./lib/gpio ./lib/std_cout
### FYI: --chown, it is recursive by default
COPY --chown=1000:1000 ./lib/gpio ./lib/gpio
COPY --chown=1000:1000 ./scripts/dependency/install_gpio.sh ./scripts/dependency/install_gpio.sh
RUN /bin/bash -c "./scripts/dependency/install_gpio.sh"

COPY --chown=1000:1000 ./lib/std_cout ./lib/std_cout
COPY --chown=1000:1000 ./scripts/dependency/install_std_cout.sh ./scripts/dependency/install_std_cout.sh
RUN /bin/bash -c "./scripts/dependency/install_std_cout.sh"

COPY --chown=${UID}:${GID} ./scripts/entry/ros_entrypoint.sh ./ros_entrypoint.sh

## 셋업 bash 부분이 
RUN echo "source /opt/ros/jazzy/setup.bash" >> ${HOME}/.bashrc
RUN echo "source ${HOME}/${WORKSPACE}/install/setup.bash" >> ${HOME}/.bashrc
# RUN echo "source ${HOME}/${WORKSPACE_TB}/install/setup.bash" >> ${HOME}/.bashrc

ENTRYPOINT [ "./ros_entrypoint.sh" ]
## 추후 home에 스크립트 복사는 추후 update 하기
## ros2는 roscore 없으므로 따로 실행 없음 - 추후 런치파일 등록
