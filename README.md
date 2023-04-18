# docker로 ros 실행하기
docker로 ros 실행하기  
ROS2 humble 버전

## requirements 
docker, docker-compose, git 등이 필요 합니다.    
리눅스 배포판의 디스트로 종류에 따라 docker engine을 선택해서 설치 후 (공식 사이트 참고)  

[도커엔진 공식 사이트 - CentOS 기준](https://docs.docker.com/engine/install/centos/)  
- 리눅스 배포판에 따라서 왼쪽 메뉴에서 선택하면 됩니다.  
- docker-compose 도 해당 사이트 왼쪽 메뉴에서 찾을 수 있습니다

요새는 docker-compose도 plugin으로 처음부터 바로 설치가 가능한 듯 하다. (Nov 16 2022)

## HUMBLE ROS2
1. ROS2 - humble   
desktop 버전  osrf ros 정식 이미지 사용   

ros1과는 다르게 일단 ros 이미지를 사용해도 gui 프로그램 실행에 큰 문제는 발생하지 않는 듯 함   

현재 rviz2는 사용이 잘 됨  - nvidia/cudagl 이미지를 사용하지 않음  

> ROS1 Noetic 버전에서는 Nvidia 그래픽카드를 사용할 경우 xhost +x 해도 사용이 안되었는데  
ros-humble-desktop 버전에서는 xhost와 nvidia cudagl 이미지를 사용 안했는데도   
rviz2 등이 잘 사용이 됨; docker-compose에서  runtime: nvidia 를 사용해서 그럴 듯도 함   
runtime 파라미터를 생략하면 gazebo 등은 실행이 (검정화면) 안됨

어쨋든 **nvidia-docker2** 가 필요하다. (apt 로 설치)


## 깃 클론, docker-compose build

## 사용방법
1. 깃 클론을 해줍니다.
```
git clone -b humble https://github.com/terrificmn/docker-ros.git
```


> 현재 ROS 버전 별로 블랜치가 많이 생성되어 있으므로   
특정 브랜치 버전이 필요하면 -b 옵션을 넣고 브랜치명을 적어준다

이 후 해당 디렉토리로 이동 후   
```
cd docker-ros
```
이후 docker-compose build를 해주는데, 하기 전에 아래의 .env 설정 파일 참고  

2. docker-compose.yml 파일의 volumes 옵션의 catkin_ws 경로를 원하는 곳으로 수정가능  
.env_example 파일에서 .env 로 카피를 한 다음에 사용  
```
cp .env_example .env
```
복사 한 .env 파일에서 변경해줍니다. 그대로 사용해도 무방  
유저명이나, 유저 홈 디렉토리, catkin_ws 이름을 변경할 수 있음  

> 단, Dockerfile에는 ARG 를 이용해서 똑같이 설정해줘야하는 함정이 있음;;;;   
안타깝게도 .env파일의 환경변수가 Dockerfile에서는 적용이 안되므로   
그리고 ARG도 build할 때 RUN 키워드 명령어에서만 작동하므로 ENV랑은 또 호환이 안되므로    
새롭게 작동할 방법을 찾아 업데이트를 해야할 듯 하다
(브랜치마다, 조금씩 다를 수 있음-적용이 안되어 있는 것도 있음)

3. 실행방법 
현재 dr_ros2_ws 가 (기본 디렉토리명으로 되어 있음)   

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

## 빌드 및 디스플레이 공유 docker up
docker 빌드
```
docker-compose build
```

디스플레이 공유하기
```
xhost + local:docker
```
> nvidia-docker2 가 필요하고, xhost 명령은 안해도 상관은 없는 듯 하다.   

docker실행
```
docker-compose up
```

다른 터미널에 docker 컨테이너 실행하기
```
docker exec -it ros bash
```

##  Permission denied
워크스페이스 관련해서 디렉토리 Permission denied 발생하면  
```
sudo chown $USER:$USER dr_ros2_ws/
```
으로 root 소유에서 user소유로 바꿔준다 


