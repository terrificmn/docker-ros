# ROS Noetic
1. Noetic 버전 ros 입니다. Tinker board2 Debian buster 10에 설치.   
> Dockerfile의 rosdep init은 실행 안함. 하지만 다른 부분은 tinker board2 라고  
특별하게 변경 된 것은 없다. Tinker Board2에서는 실행 잘 됨.   
(다른 리눅스에서도 noetic 버전으로 사용 가능 할 듯 함 -테스트는 안함)

2. docker, docker-compose 가 설치되어 있어야 합니다.  
[도커엔진 공식 사이트 - CentOS 기준](https://docs.docker.com/engine/install/centos/)  
- 리눅스 배포판에 따라서 왼쪽 메뉴에서 선택하면 됩니다.  
- ~~docker-compose 도 해당 사이트 왼쪽 메뉴에서 찾을 수 있습니다~~  
- docker-compose 도 plugin 으로 설치가 됨 (Tinker Board2 -Debain buster 10 기준)

3. 일반 유저로 로그인, (docker) docker_noetic 로 되어 있음   
Dockerfile의 user 비빌번호는 :이후가 패스워드 임, 즉, 기본값은 pass  
비밀번호는 pass 부분을 변경하면 됨
```
echo "$USER:pass" | chpasswd && \
```
최초 .env_example을 .env 파일로 복사 사용 해야한다. 유저, 홈 등..변경 가능함      

> .env파일은 .gitignore에 추가되어 있어서 git에서 추적하지 않음  

만약 유저, 홈, workspace를 변경할 경우에는 ARG를 변경해준다   
Dockerfile에서는 .env의 변수를 사용할 수 없기 때문에 해당 변수를 사용하려면    
**ARG로 변수를 만들고, 같은 값으로 변경**해준다 (또는 그냥 사용해도 무방)   
예..  
```
ARG USER=docker_myuser
ARG HOME=/home/docker_myuser
ARG WORKSPACE=/catkin_ws
```

4. docker-compose.yml 파일의 volumes 옵션의 catkin_ws 경로를 원하는 곳으로 수정가능  
실제 host 컴퓨터에서도 접근 가능하므로 catkin workspace를 만들고 src 디렉토리에   
원하는 ros 패키지를 넣어서 공유가능. (catkin_make, catkit build는 컨테이너 안에서 빌드 실행)  
> 현재 기본값은 docker_ws로 되어 있음  
바꿀 경우 .env와 Dockerfile의 ARG를 각각 변경해준다 

5. 실행방법  
먼저 클론을 받은 후에 디렉토리 이동
```
git clone https://github.com/terrificmn/docker-ros.git -b tinker-noetic
cd ~/docker-ros
```

최초 .env 파일 만들기
```
cp .env_example .env
```


### 빌드 전에 위치 등을 변경하려면   
그냥 사용하려면 여기는 **skip** 한다!

docker 컨테이너에서 사용할 유저 관련은 위를 참고  
catkin_ws를 다른 위치에 만들거나, 이름 변경은 docker-compose.yml 파일의 volumes 옵션부분을 바꿔줘야하는데   

해당 내용은 이렇게 되는데, 현재 경로인 ./docker_ws 에서 컨테이너 유저인 /home/docker-noetic/docker_ws 로 연결해 주게 됨
```
  volumes:
      - ./${WORKSPACE}:${USERHOME}/${WORKSPACE}
```
직접 docker-compose.yml를 변경할 필요는 없고, 환경 변수를 사용을 하기 때문에    
이 부분은 .env 파일의 WORKSPACE=/docker_ws 를 변경한다.  
현재 디폴트는 docker_ws

예: .env 파일
```
USER=my_user
USERHOME=/home/my_user
WORKSPACE=catkin_ws
```

Dockerfile에서는 .env파일의 변수를 사용 못하므로 위의 사항이 변경이 있다면   
**Dockerfile 의 ARG를 같은 값으로 변경**해준다  

> 만약 host컴의 workspace 위치를 하위 디렉토리가 아닌 다른 곳을 사용하려면   
compose.yml파일을 수정할 필요가 있어 보임    
(WORKSPACE는 같은 값을 사용하므로)

## 빌드

docker 빌드
```
docker-compose build
```

디스플레이 공유하기
```
xhost + local:docker
```
> Tinker Board2 에서는 안 해도 잘 실행 됨

docker실행
```
docker-compose up
```
이제 roscore가 실행이 되게 된다.  또는 roslaunch 
> roslanch 실행이 아직 없다면 docker-compose.yml 파일에서 command 부분을 주석처리  
(CMD roslaunch부분)


## docker-compose.yml의 command 사용해서 roslaunch 실행
중지하려면 ctrl+c 또는 `docker-compose stop`

현재는 docker-compose.yml 파일에 roslaunch가 실행되게 되어 있으므로   
다른 것은 수정할 필요가 없고 .env-example을 복사해서 사용하는 .env 파일을 수정해준다

.env파일의 ROS_PACKAGE, ROS_LAUNCH_FILE 변수에 실행패키지를 직접 입력해준다.

예
```
ROS_PACKAGE=camera_pub_pkg
ROS_LAUNCH_FILE=camera_pub_launch.launch
```
빌드 없이 바로 `docker-compose up` 해주면 실행된다

___   
실행할 런치 파일이 정해져 있다면 위의 Dockerfile의 ENTRYPOINT만 사용해도 되지만   
단점이 sh스크립트의 실행할 파일등이 바뀔 경우에는 다시 build를 해줘야한다

그래서 docker-compose 파일을 사용하게 되면 빌드 없이 수정이 가능하기 때문에 좀 더 편하다

대신에 ros의 자신의 워크 스페이스 setup.bash 파일이 로드가 안 되어 있기 때문에   
실행이 바로 안 됨에 주의.

그래서 command에 setup.bash 파일을 source 시켜준다음에 roslaunch나 rosrun을 해주게 된다 

```
command:
      ["bash", "-c", "source ${USERHOME}/${WORKSPACE}/devel/setup.bash && roslaunch ${ROS_PACKAGE} ${ROS_LAUNCH_FILE}"]
```

> 해당 변수들은 .env파일의 정의되어 있으므로 해당 변수만 수정한다

### docker_ws 에 접근 권한 거부 시 
```
sudo chown $USER:root -R docker_ws
```

## 추가
rosbridge pkg, web pkg 추가

### npm, vue 컨테이너 추가
- npm

- vue: vue는 vue 프레임워크는 아니고, vue-cli,   
기존 npm 컨테이너에서는 vue 명령을 할 수가 없으므로   
vue-cli 컨테이너 추가~ (npm과 같은 버전의 이미지 사용)
 


## 다른 터미널에서 docker 컨테이너 실행하기. catkin 빌드하기
```
docker exec -it ros bash
```
docker exec는 터미널 디렉토리 위치 상관없이 사용이 가능하고 컨테이너가 up이 된 상태에서 사용할 수가 있다

해당 컨테이너에 로그인(?)이 되면 보통 ros를 다루듯이 rosrun, roslaunch. 등이 가능하다   
특히 컨테이너에 실행에서 **ros패키지 빌드**가 가능하다 catkin build 또는 catkin_make 를 사용

docker-compose build와는 별개로 catkin 패키지를 구성할 수가 있다.   
docker-compose build를 해서 다시 리빌드를 하면 바뀐 내용이 있다면 빌드시에 초기화가 될 수가 있는데

ros관련 패키지를 catkin build등으로 빌드하면 ros패키지는 그대로 남아 있다.   
이유는 host컴퓨터의 자원을 공유해서 사용하기 때문이다.

그래서 짬뽕으로 vscode등을 이용해서 패키지 소스파일을 수정하고   
(단, 그냥 사용하면 ros등의 헤더파일은 못 찾는다, 실제 ros는 컨테이너에 설치되어 있으므로)

> vscode의 extensions 중에 Remote Development를 사용하면 실행 중인 도커 컨테이너에 붙여서 사용할 수 있어 편함   
header파일등 (ros/ros.h 같은 파일을 읽을 수가 있다)