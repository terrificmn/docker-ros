# docker로 ros 실행하기
1. melodic 버전 ros 입니다

2. Dockerfile 내의 Mesa libraries 설치는 환경에 따라 삭제 가능

3. 현재는 도커 컨테이너를 root 권한으로 사용하기 때문에 /root/.bashrc 생성 후 사용함

4. docker-compose.yml 파일의 volumes 옵션의 catkin_ws 경로를 원하는 곳으로 수정가능

5. 실행방법  
먼저 클론을 받은 후에 catkin_ws를 생성하는데 원하는 위치에 만들어 주면 됩니다.  
현재 디렉토리 안에다가 만든다고 하면 아래 처럼 사용 가능
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

