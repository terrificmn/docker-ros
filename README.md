# docker로 ros2 실행하기
docker로 ros 실행하기  
ROS2 jazzy 버전

## requirements 
docker, docker-compose, git 등이 필요 합니다.    
리눅스 배포판의 디스트로 종류에 따라 docker engine을 선택해서 설치 후 (공식 사이트 참고)  

요새는 docker-compose도 plugin으로 처음부터 바로 설치가 가능한 듯 하다. (Nov 16 2022)

## JAZZY ROS2
1. jazzy-dev 브랜치   
ros2 jazzy desktop 버전  

## 빌드 및 디스플레이 공유 docker up
docker 빌드
```
docker compose build
```

디스플레이 공유하기
```
xhost + local:docker
```
> nvidia-docker2 가 필요하고, xhost 명령은 안해도 상관은 없는 듯 하다.   

docker실행
```
docker compose up
```

다른 터미널에 docker 컨테이너 실행하기
```
docker exec -it ros2 bash
```
> ros2 대신에 컨테이너 이름


## 최초 docker 빌드 시
1. docker-sr 설정

2. .env 설정

3. build & up 후 생성된 workspace 권한 변경
일단 docker_ws 는 유저로 통일 $USER:$UESR
(mysqldata 는 변경하지 않는다.)

home_monitor는 sudo chown $USER:33 -R home_monitor/

구조
docker_ws 이하 camera_pub_cpp  servo_ros

web_ws 이하 home_monitor


