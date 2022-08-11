# 매우 간단한 Lambda Authorizer

프로젝트에서 Authorizer를 쓰기 위해 만든 매우 간단한 Lambda Authozier입니다.

JWT를 사용합니다.

bearer token으로 들어왔을 때의 기준으로 만들어진 Authorizer입니다.

## Installation
npm

```bash
npm init
npm install jsonwebtoken
```
AWS sam cli

https://docs.aws.amazon.com/ko_kr/serverless-application-model/latest/developerguide/serverless-sam-cli-install.html
## Local에서 테스트
로컬에서 테스트를 해보고 싶다면 
```bash
sam build
```
를 합니다.

Docker를 이용하여 'aws-sam/build'가 생기게 됩니다.

Docker가 실행중이여야 합니다.

```bash
sam local invoke -e events/event.json
```
events 폴더 안의 event.json 파일을 사용하여 event를 보내고 Lambda의 결과가 나옵니다.
