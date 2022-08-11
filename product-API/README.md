# 제품 관리팀 API 서버 상황 요약
사내 정보 시스템은 모놀리틱으로 재품 관리팀과 함께 구현되어 있었습니다. 조직의 확장으로 시스템의 유지 보수가 힘들어짐에 따라 도메인 별로 분리를 한 상황입니다.
인증은 사내 정보 시스템의 통합 인증 과정을 거치도록 했습니다. 보안 강화를 위해서 가능한 리소스들은 프라이빗 서브넷에 위치하였습니다.
제품 관리팀의 API 서버는 별도의 ECS 클러스터에 이관한 상황입니다. 제품 관리팀 서버의 데이터는 AWS DynamoDB에 저장됩니다.

## Local환경에서 테스트 할 수 있는 방법
1. Dockerfile을 빌드하여 이미지 생성
![re1](https://user-images.githubusercontent.com/103503456/184066247-c1796deb-5724-412e-9bbd-cddf98bff675.JPG)
```bash
docker build --tag PM-API-Server
```
2. Dockerfile로 빌드한 이미지를 컨테이너로 실행
```bash
docker run -p 80:80 PM-API-Server
```
3. Docker Hub에서 dynamoDB-local이미지 다운로드 후 컨테이너로 실행
https://hub.docker.com/r/amazon/dynamodb-local
```bash
docker run -p 8000:8000 amazon/dynamodb-local:latest
```
4. NoSQL Workbench를 사용하여 local환경에서 Dynamodb를 사용할 수 있습니다.
https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/workbench.settingup.html
![re3](https://user-images.githubusercontent.com/103503456/184067071-dbf5d86c-2793-4891-847c-e4830b83d31c.JPG)
cf) DynamoDB 로컬로 띄울때 리전 변수 "무시"하는 방법(shareddb-option)

https://stackoverflow.com/questions/65990761/docker-dynamodb-shareddb-option

-> 리전 변수를 무시하는 이유 : 로컬상의 테이블과 데이터를 입력하고 aws cli로 명령을 내려도 local상의 테이블과 데이터를
인식하지 못함.
![shdbfalse](https://user-images.githubusercontent.com/103503456/184067332-81651eb5-bea0-4e75-b96b-42b619f2a42e.jpg)
![tbno](https://user-images.githubusercontent.com/103503456/184067393-51c174c6-9b9c-452e-a183-086d1a2003b5.jpg)

-> shareddb-option을 true로 해서 컨테이너를 실행시키면 아래의 사진과 같이 로컬에서 인식한다.
![shdbtrue](https://user-images.githubusercontent.com/103503456/184067402-4fb37330-28c8-4dc9-a655-0d0358cccc47.jpg)
![tbyes](https://user-images.githubusercontent.com/103503456/184067409-760a53cd-5f56-43f1-90e1-45255dc0e2e0.jpg)

5. fastify plugins dynamodb.js에서 endpoint를 수정하여 dynamodb 연결 가능
![re2](https://user-images.githubusercontent.com/103503456/184067731-6afe1ac1-3658-4687-b3c4-282e84f285b1.JPG)

6. 서버 실행 (localhost:80에서 동작)
```bash
npm start
```
![re4](https://user-images.githubusercontent.com/103503456/184067919-2fc63560-3669-4d68-8ba0-55a0be5c7367.JPG)


## 배포 지침
![re5](https://user-images.githubusercontent.com/103503456/184068168-ecd4bd50-2088-42e3-8848-a305506d71cf.JPG)
GitHub Actions 사용하여 배포자동화를 했습니다.
1. 개발자가 Proudct-API 코드 변경 사항을 Push합니다.
2. Push된 변경사항을 도커 이미지로 Build하여 ECR에 Push합니다.
3. ECR에 Push된 이미지를 이용하여 ECS에 Deploy합니다.
