# docker로 ros 실행하기
docker로 ros 실행하기

## ros melodic / noetic (docker)
1. melodic 버전 ros 입니다

2. noetic ros 버전 추가 되었습니다. noetic 버전을 받으려면 -b 옵션으로 클론하세요 
```
git clone -b https://github.com/terrificmn/docker-ros.git
```

3. Dockerfile 내의 Mesa libraries 설치는 환경에 따라 삭제 가능 (현재 AMD용으로 작성되었습니다)

4. 현재는 도커 컨테이너를 root 권한으로 사용하기 때문에 /root/.bashrc 생성 후 사용함 ~~(일반 유저로 하는 것은 추후 업데이트할 예정)~~

5. noetic 버전에는 새로 root가 아닌 user를 추가했습니다. 자세한 사항은 아래를 참고

6. docker-compose.yml 파일의 volumes 옵션의 catkin_ws 경로를 원하는 곳으로 수정가능

5. docker, docker-compose 가 설치되어 있어야 합니다.  
[도커엔진 공식 사이트 - CentOS 기준](https://docs.docker.com/engine/install/centos/)  
- 리눅스 배포판에 따라서 왼쪽 메뉴에서 선택하면 됩니다.  
- docker-compose 도 해당 사이트 왼쪽 메뉴에서 찾을 수 있습니다

6. 실행방법 (Melodic)  
먼저 클론을 받은 후에 catkin_ws를 생성하는데 원하는 위치에 만들어 주면 됩니다.  
현재 디렉토리 안에다가 만든다고 하면 아래 처럼 사용 가능   
[(*noetic 버전은 아래 실행 방법을 참고 하세요)](#noetic-실행방법)
```
cd ~/docker-ros
mkdir catkin_ws
```

만약 다른 경로에 만들었다면 docker-compose.yml 파일의 volumes 옵션부분을 바꿔줘야함  
예:
```xml
volumes:
      - /home/ubun22/catkin_ws:/root/catkin_ws 
```

## noetic 실행방법
실행방법 (Noetic)  
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

디스플레이 공유하기
```
xhost + local:docker
```

docker실행
```
docker-compose up
```

다른 터미널에 docker 컨테이너 실행하기
```
docker exec -it ros bash
```

[도커 ros 관련 블로그 보기](http://54.180.113.157/tag/docker%20ros%20%ED%8A%9C%ED%86%A0%EB%A6%AC%EC%96%BC)

