# docker로 ros 실행하기
docker로 ros 실행하기

## main branch
현재 nvidia/cudag1의 ubuntu18.04를 사용하는 이미지를 사용 합니다.   
nvidia의 그래픽 카드를 사용할 경우에는 docker에서 rviz, gazebo등을 실행했을 시에  
잘 띄워줍니다. 

ROS는 *noetic* 버전. 

## requirements 
docker, docker-compose, git 등이 필요 합니다.    
리눅스 배포판의 디스트로 종류에 따라 docker engine을 선택해서 설치 후 (공식 사이트 참고)  

[도커엔진 공식 사이트 - CentOS 기준](https://docs.docker.com/engine/install/centos/)  
- 리눅스 배포판에 따라서 왼쪽 메뉴에서 선택하면 됩니다.  
- docker-compose 도 해당 사이트 왼쪽 메뉴에서 찾을 수 있습니다

요새는 docker-compose도 plugin으로 처음부터 바로 설치가 가능한 듯 하다. (Nov 16 2022)

## ros melodic 또는 noetic 버전 가능 (branch 별)
1. noetic 버전 ros 입니다

melodic에서 nvidia그래픽카드를 사용할 경우 호스트 컴퓨터의 자원을 제대로 사용하지 못하는 경우가 생겨서  
(nvidia 그래픽 드라이버를 사용 못하는 듯 함)   

nvidia/cudagl:11.3.1-devel-ubuntu18.04 이미지를 이용해서 build   
(ros이미지에서 변경함)  
rviz, gazebo 등 실행 잘 됨

2. ROS - noetic 버전 추가 되었습니다. noetic 버전을 받으려면 -b 옵션으로 클론하세요 
```
git clone -b noetic https://github.com/terrificmn/docker-ros.git
```
업데이트가 필요하지만 아직 초기 버전입니다. 해당 브랜치의 READMD.md 파일을 참고
nvidia가 아닌, amd 라데온 그래픽 호환(?) 버전 입니다.  
amd 라데온을 사용할 시에 그래픽 화면 잘 띄워줍니다.   
- noetic 버전에는 새로 root가 아닌 user를 추가했습니다. 자세한 사항은 아래를 참고


3. ROS - melodic 버전 | amd 라데온 버전 추가 되었습니다. 
```
git clone -b melodic-radeon https://github.com/terrificmn/docker-ros.git
```
amd 그래픽 사용할 경우 사용~   상위 버전 그래픽카드는 호환여부는 모르겠음  
rviz, gazebo등 잘 실행 됨   

4. 싱글보드컴퓨터 tinker board2 ROS noetic 버전 추가 되었습니다.
깃 클론
```
git clone -b tinker-noetic https://github.com/terrificmn/docker-ros.git
```

팅커보드2 에서 ROS noetic 버전 사용 가능!  그래픽 화면 호환 잘 됨



## 깃 클론, docker-compose build

## 사용방법
1. 깃 클론을 해줍니다.
```
git clone https://github.com/terrificmn/docker-ros.git
```

> 여기에서 특정 브랜치 버전이 필요하면 -b 옵션을 넣고 브랜치명을 적어준다

이 후 해당 디렉토리로 이동 후   
```
cd docker-ros
```
이후 docker-compose build를 해주는데, 하기 전에 아래의 .env 설정 파일 참고  

2. docker-compose.yml 파일의 volumes 옵션의 catkin_ws 경로를 원하는 곳으로 수정가능  
env_example 파일에서 .env 로 카피를 한 다음에 사용  
```
cp env_example .env
```
복사 한 .env 파일에서 변경해줍니다. 그대로 사용해도 무방  
유저명이나, 유저 홈 디렉토리, catkin_ws 이름을 변경할 수 있음  

> 단, Dockerfile에는 ARG 를 이용해서 똑같이 설정해줘야하는 함정이 있음;;;;   
안타깝게도 .env파일의 환경변수가 Dockerfile에서는 적용이 안되므로   
그리고 ARG도 build할 때 RUN 키워드 명령어에서만 작동하므로 ENV랑은 또 호환이 안되므로    
새롭게 작동할 방법을 찾아 업데이트를 해야할 듯 하다
(브랜치마다, 조금씩 다를 수 있음-적용이 안되어 있는 것도 있음)

3. 실행방법 (Melodic)  
현재 docker_ws 가 (catkin_ws로 기본 디렉토리명으로 되어 있음)   

그래서 만약 유저명, ws디렉토리명을 바꿨다면 (.env파일에서)

Dockerfile 의 아래부분을 같은 내용으로 변경해주세요   
``` 
ARG USER=newuser
ARG HOME=/home/newuser
... 생략...

USER newuser
WORKDIR /home/newuser
```

[(*noetic 버전은 아래 실행 방법을 참고 하세요)](#noetic-실행방법)

만약 다른 경로에 만들었다면 docker-compose.yml 파일의 volumes 옵션부분을 바꿔줘야함  
예:
```xml
volumes:
      - /home/ubun22/catkin_ws:/root/catkin_ws 
```

4. noetic 실행방법
실행방법 (Noetic)   
브랜치는 -b noetic   
현재는 docker_ws로 디렉토리가 연결되어 있습니다.   
디렉토리로 이동 (깃허브 클론 받은 곳으로 이동)
```
cd ~/docker-ros
mkdir docker_ws
```
이제 docker_ws 디렉토리에서는 ros의 catkin_ws 처럼 사용을 하면 됩니다.  
docker 컨테이너로 (복사) 내용이 그대로 사용됨  


## 빌드 및 디스플레이 공유 docker up
docker 빌드
```
docker-compose build
```

nvidia용 runtime 파람을 사용하기 위해서 nvidia-docker2가 필요   
없으면 rutime 을 docker에서 인식하지 못함   
```
sudo apt update
sudo apt install -y nvidia-docker2
```
패키지를 못 찾을 시에는 
```
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
      && curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
      && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
            sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
            sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
```
키 셋팅 후 다시 update 시도 후 install 한다 

docker-compose 파일 중에.. 설정 후 사용해야 한다 
```yaml
      runtime: nvidia   
```

디스플레이 공유하기
```
xhost + local:docker
```

> xhost를 안 할 경우 GUI가 필요한 경우에 no protocal 이라면서 실행을 할 수 없게 된다 (예: rviz, gazebo등)   


docker실행
```
docker-compose up
```

다른 터미널에 docker 컨테이너 실행하기
```
docker exec -it ros bash
```

## roscore, rosluanch, rosrun 실행
편하게 docker-compose의 command 명령을 사용한다. 모든 것은 다 되어 있고   
실행할 패키지와, 런치파일만 있으면 된다   
.env 파일에서 pkg_name, launch_file 이름만 설정해서 사용하면 된다   

Dockerfile 의 ENTRYPOINT를 사용하려면   
> 이 방법도 위의 docker-comopose의 기능이 잘 안되서(잘 몰라서 ㅋ) 했던 방법...  
sh스크립트를 사용하는 방식으로 실행은 잘 되지만,   
단점은 쉘 스크립트 내용이 바뀌면 `docker compose build`를 다시해야하는 문제가 있다


Dockerfile의 ENTRYPOINT 부분을 주석해제
```
## COPY, ENTRYPOINT 주석 해제 시 ros_entrypoint.sh 에 roscore/ rosrun/ roslaunch 등을 설정해줘야한다(현재 모두 주석처리됨)
COPY ./ros_entrypoint.sh ./
## shell script를 실행하려면 실행권한을 줘야하지만 현재 일반 유저로 되어 있어서 스킵 후 host com 쪽에서 권한 생성
ENTRYPOINT ["./ros_entrypoint.sh"]  
```

ros_entrypoint.sh 파일에는 setup.bash 등을 source 하는 부분만 되어 있기 때문에  
원하는 런치파일을 적어줘야 실행이 된다. 또는 roscore || rosrun 등을 실행해도 된다 

> 현재는 ros_entrypoint.sh에 따로 런치파일이 입력되어 있지 않음.   
새로 런치파일을 입력해주고 실행 하려면 후 다시 `docker compose build`를 해준다   

> ENTRYPOINT를 사용하지만 ros_entrypoint.sh 에 별다른 명령이 없을 경우에는 docker는 바로 exit하게 됨

> ENTRYPOINT를 사용 안하고 주석 처리할 경우에는 docker 컨테이너가 작동하므로 docker exec 명령어로 수행


[도커 ros 관련 블로그 보기](http://54.180.113.157/tag/docker%20ros%20%ED%8A%9C%ED%86%A0%EB%A6%AC%EC%96%BC)

## master 설정
따로 master가 있어서 연결할 경우에는    
- `network_mode: host` 주석 해제 후 사용
- environment의 ROS_MASTER_URI,ROS_IP 주석 해제하고, .env파일에 ip 설정 후 사용   

**싱글로 단독 master**로 사용할 경우에는 위의 파라미터들이 주석해제된 상태로 사용한다   

>  네트워크 host 모드이면 roscore 시 연결을 하지 못한다. 

## nvidia 버전에서는 roscore
docker-compose.yml 에서 command로  roscore가 단독으로 지정이 안됨   
(공식 osrf/ros 이미지에서는 가능)   

docker exec 를 통해서 roscore을 실행하거나, ros_entrypoint.sh 파일에 roscore를 주석해제 후 Dockerfile에서  COPY, ENTRYPOINT등을 주석해제 하고 사용 - 각각 주석 설명 참고


