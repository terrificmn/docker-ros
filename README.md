# docker로 ros 실행하기
1. ROS noetic 버전 - Windows10 wsl2 

2. env-example 파일을 .env 파일로 복사 후 사용

3. docker-compose.yml 파일의 volumes 옵션의 catkin_ws 경로를 원하는 곳으로 수정가능   
.env 파일의 변경, Dockerfile 의 ARG도 같은 값으로 변경 (Dockerfile에서 .env파일의 변수 호환 안됨)

4. docker, docker-compose 가 설치되어 있어야 합니다.  
[도커엔진 공식 사이트 - CentOS 기준](https://docs.docker.com/engine/install/centos/)  
- 리눅스 배포판에 따라서 왼쪽 메뉴에서 선택하면 됩니다.  
- docker-compose 도 해당 사이트 왼쪽 메뉴에서 찾을 수 있습니다

5. 실행방법  
먼저 클론을 받은 후에 워크스페이스(catkin_ws)를 생성   
현재 디렉토리 안에다가 만든다고 하면 아래 처럼 사용 가능
```
cd ~/docker-ros
mkdir catkin_ws
```

docker 빌드
```
docker compose build
```

디스플레이 공유하기
**XLaunch** 프로그램 사용해야함  

docker실행
```
docker compose up
```

다른 터미널에 docker 컨테이너 실행하기
```
docker exec -it ros bash
```

