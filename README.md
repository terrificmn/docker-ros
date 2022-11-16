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
최초 .env_example을 .env 파일로 복사 사용 해야하며, 유저, 홈 등..변경 가능함      
단, Dockerfile파일의 ARG 에도 설정 해줘야함(같은 값으로..)  

4. docker-compose.yml 파일의 volumes 옵션의 catkin_ws 경로를 원하는 곳으로 수정가능  
실제 host 컴퓨터에서도 접근 가능하므로 catkin workspace를 만들고 src 디렉토리에   
원하는 ros 패키지를 넣어서 공유가능. (catkin_make, catkit build는 컨테이너 안에서 빌드 실행)  
> 현재 기본값은 docker_ws로 되어 있음

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

docker 컨테이너에서 사용할 유저 관련은 위를 참고  
catkin_ws를 다른 위치에 만들려면 docker-compose.yml 파일의 volumes 옵션부분을 바꿔줘야하는데     
이 부분은 .env 파일의 WORKSPACE=/docker_ws 를 변경하면 됨
> 디폴트는 docker_ws

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
이제 roscore가 실행이 되게 된다.  
다른 터미널창을 실행한 후 docker 컨테이너 실행하기
```
docker exec -it ros bash
```

### docker_ws 에 접근 권한 거부 시 
```
sudo chown $USER:root -R docker_ws
```

