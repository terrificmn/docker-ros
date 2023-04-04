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

## host ip를 사용할 경우..
**ROS master**를 따로 사용하는 경우에만 활성화 시켜야 한다     

> **아직 미 해결** master와 연결을 되고, 서브스크라이브도 가능하지만,  
퍼블리쉬를 하면 master에서 받지 못하는 상황에 있음   
windows에서는 좀 더 연구가 필요할 듯하다. 리눅스 도커에서는 ROS_MASTER_URI, ROS_IP 등으로  
설정하면 가능하지만, windows 에서는 같은 설정으로 안됨   
- 방화벽, hosts 파일 등 시도했지만 안됨

docker-compose.yml  파일의  
```yaml
network_mode: host  ## master가 따로 있을 경우만 사용
    ...생략...
environment:
    - ROS_MASTER_URI=http://${MASTER_IP}:11311
    - ROS_IP=${HOST_COM_IP}
```
`networ_mode: host` 로 주석을 해제해서 사용하고, environment 전체를 주석해제해서 사용  
환경 변수는 .env 파일에서 ip주소로 각각 셋팅(master, host ip)


## 독립된 master로 사용할 경우
위의 `network_mode, environment` 부분을 전부 주석 처리하고 사용한다  
roscore로 바로 실행할 경우 `command: -roscore` 부분을 주석해제하고 사용하면 됨    

> 독립된 docker 만의 master로 사용할 경우 netword를  host로 하게 되면 서버에 접속할 수가 없다  
아마도 host ip여서 그런 듯 하다.. 


## 일단 windows  docker는 
독립적으로 사용하거나, master를 따로 두고 ROS_MASTER_URI를 사용할 경우에는 제한적으로 사용 밖에 안된다   on Apr4 2023

> 추후 아주아주 시간이 날 경우 ㅜ;;; 시도해 볼것 ㅋ