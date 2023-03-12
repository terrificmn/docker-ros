# docker로 ros 실행하기
docker로 ros 실행하기

## ros noetic (docker)
1. noetic 버전 ros 입니다
- noetic 버전에 .env_example 추가: .env 로 카피를 한 다음에 사용 (유저 변경등..비번변경)  
```
cp .env_example .env
```

2. Dockerfile 내의 Mesa libraries 설치는 환경에 따라 삭제 가능 (현재 AMD용으로 작성되었습니다)

3. noetic 버전에는 root가 아닌 user를 추가했습니다. 자세한 사항은 아래를 참고

4. docker-compose.yml 파일의 volumes 옵션의 catkin_ws 경로를 원하는 곳으로 수정가능  
.env 파일의 WORKSPACE를 변경. 단, Dockerfile에서는 .env의 환경변수를 사용할 수 없으므로    
**ARG로 변수 선언을 해주고, 같은 값으로 변경해준다** (또는 그냥 사용해도 무방)
예  Dockerfile에서
```
ARG USER=docker_myuser
ARG HOME=/home/docker_myuser
ARG WORKSPACE=/catkin_ws
```

5. docker, docker-compose 가 설치되어 있어야 합니다.  
[도커엔진 공식 사이트 - CentOS 기준](https://docs.docker.com/engine/install/centos/)  
- 리눅스 배포판에 따라서 왼쪽 메뉴에서 선택하면 됩니다.  
- docker-compose 도 해당 사이트 왼쪽 메뉴에서 찾을 수 있습니다

6. 실행방법 
먼저 클론을 받은 후에 catkin_ws를 생성하는데 원하는 위치에 만들어 주면 됩니다.  
현재 클론 받은 디렉토리 안에다가 만든다고 하면 아래 처럼 사용 가능   
```
cd ~/docker-ros
mkdir docker_ws
```

> Workspace를 다른 곳으로 하려면 .env파일의 WORKSPACE를 변경   
Dockerfile의 ARG의 WORKSPACE를 동일하게 변경하면 된다 


## noetic 실행방법
실행방법 (Noetic)  
현재는 docker_ws로 디렉토리가 연결되어 있습니다.   
디렉토리로 이동 (깃허브 클론 받은 곳으로 이동)

> 디렉토리 이동 후 바로 docker compose build도 가능함  
단, docker_ws가 만들어 진 후에 root 권한으로 되어 있으므로 chown로 자신의 user로 바꿔준다   

또는 직접 만들고 빌드한다 
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
> Dockerfile이 있는 디렉토리에서 실행해야함

디스플레이 공유하기
```
xhost + local:docker
```

docker실행
```
docker-compose up
```

## 다른 터미널에서 docker 컨테이너 실행하기. catkin 빌드하기
```
docker exec -it ros bash
```
docker exec는 터미널 디렉토리 위치 상관없이 사용이 가능하고 컨테이너가 up이 된 상태에서 사용할 수가 있다  

해당 컨테이너에 로그인(?)이 되면 보통 ros를 다루듯이 rosrun, roslaunch. 등이 가능하다   
특히 컨테이너에 실행에서 **ros패키지 빌드가 가능**하다 catkin build 또는 catkin_make 를 사용

docker-compose build와는 별개로 catkin 패키지를 구성할 수가 있다.   
`docker-compose build`를 해서 다시 리빌드를 하면 바뀐 내용이 있다면 빌드시에 초기화가 될 수가 있는데  

ros관련 패키지를 catkin build등으로 빌드하면 ros패키지는 그대로 남아 있다.   
이유는 host컴퓨터의 자원을 공유해서 사용하기 때문이다.  

그래서 짬뽕으로 vscode등을 이용해서 패키지 소스파일을 수정하고 
(단, 그냥 사용하면 ros등의 헤더파일은 못 찾는다, 실제 ros는 컨테이너에 설치되어 있으므로 ㅋㅋ)

> vscode의 extensions 중에 Remote Development를 사용하면 실행 중인 도커 컨테이너에 붙여서 사용할 수 있어 편함      
header파일등 (ros/ros.h 같은 파일을 읽을 수가 있다)


## Dockerfile의 ENTRYPOINT 사용해서 roslaunch 실행하기
매번 docker 컨테이너를 실행을 (docker exec)하면서 할 수도 있지만,   
도커를 실행하면서 roslaunch 파일이나 rosrun을 실행시킬 수 있다.  

> Dockerfile을 사용해서 빌드를 하거나 docker-comopse.yml파일을 수정해서 사용  
원하는 방법 사용. docker-compose를 수정하려면 아래 참고


Dockerfile의 마지막 줄 주석해제 후 사용
```
COPY ./entrypoint_roslaunch.sh ./
ENTRYPOINT ["./entrypoint_roslaunch.sh"]
```
build를 하기전에 entrypoint_roslaunch.sh 파일을  컨테이너에 복사한 후 docker가 실행될 때 sh스크립트가 실행되게 됨  

만약 entrypoint_roslaunch.sh 파일이 권한이 +x가 되어 있지 않다면  
```
sudo chmod +x entrypoint_roslaunch.sh
```
를 해준다 

> docker의 COPY 키워드는 권한까지 똑같이 복사해준다

대신 build를 다시 해줘야함
```
docker-compose build
```

## docker-compose.yml의 command 사용
**Dockerfile의 ENTRYPOINT 대신에 docker-compose를 사용할 수가 있다**   

현재는 docker-compose.yml 파일에 roslaunch가 실행되게 되어 있으므로  
다른 것은 수정할 필요가 없고 .env-example을 복사해서 사용하는 .env 파일을 수정해준다

.env파일의 ROS_PACKAGE, ROS_LAUNCH_FILE 변수에 실행패키지를 직접 입력해준다.

예
```
ROS_PACKAGE=camera_pub_pkg
ROS_LAUNCH_FILE=camera_pub_launch.launch
```

빌드 없이 바로 `docker-compose up` 해주면 실행된다 

실행할 런치 파일이 정해져 있다면 위의 Dockerfile의 ENTRYPOINT만 사용해도 되지만  
단점이 sh스크립트의 실행할 파일등이 바뀔 경우에는 다시 build를 해줘야한다   

그래서 docker-compose 파일을 사용하게 되면  
빌드 없이 수정이 가능하기 때문에 좀 더 편하다   

대신에 ros의 자신의 워크 스페이스 setup.bash 파일이 로드가 안 되어 있기 때문에  
실행이 바로 안 됨에 주의.  

그래서 command에 setup.bash 파일을 source 시켜준다음에 roslaunch나 rosrun을 해주면 된다.  

```
command:
      ["bash", "-c", "source ${USERHOME}/${WORKSPACE}/devel/setup.bash && roslaunch ${ROS_PACKAGE} ${ROS_LAUNCH_FILE}"]
```
해당 변수들은 .env파일의 정의되어 있다. 


[도커 ros 관련 블로그 보기](http://54.180.113.157/tag/docker%20ros%20%ED%8A%9C%ED%86%A0%EB%A6%AC%EC%96%BC)

