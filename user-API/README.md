# 사내 정보 시스템
terraform을 사용해서 프로젝트에서 필요한 사내 정보 시스템 aws 스택이 생성된 후 필요한 작업입니다.

## Deployment Instructions

이제 퍼블릭 EC2에서 프라이빗 EC2로 접속이 필요합니다.

그러기 위해서는 기존 자신의 키페어를 `scp` 명령어를 이용해서 퍼블릭 EC2에 복사해 줍니다.

```
scp -i {/Users/키페어의 위치한 경로/키페어} {키페어} {본인의 퍼블릭EC2} {엔드포인트:/퍼블릭EC2에 키페어를 저장할 경로}

ex) scp -i /Users/mymacbook/downloads/mykeypair.pem mykeypair.pem ubuntu@ec2-00-000-000-000.ap-northeast-2.compute.amazonaws.com:/home/ubuntu/
```

본인의 키페어가 제대로 복사 되었으면 이제 프라이빗 EC2에 접속해 줍니다.

접속한 프라이빗 EC2는 아직 어떤한 데이터도 없는 상태입니다.

두 가지의 작업이 필요합니다.

공식 문서를 통헤서 mysql 설치가 필요합니다.

사내 정보 시스템을 가져오기 위해서 이 리포지토리를 프라이빗 EC2에 GitHub를 통해서 복제가 필요합니다. 

- mysql 설치 https://dev.mysql.com/doc/mysql-shell/8.0/en/mysql-shell-install-linux-quick.html
- Git   설치 https://git-scm.com/book/en/v2/Getting-Started-Installing-Git

mysql 과 Git이 제대로 설치되었는지 확인하려면 `mysql --version`, `Git --version` 명령어를 사용합니다.

이제 아레의 명령어를 이용해 원격지에서 mysql에 접속해 줍니다. 

```
명령어 mysql -h 호스트주소{ip} -P 포트번호 -u 계정명{마스터 사용자 이름} -p


# 이때, -p, -P 구분을 해야합니다.
# -P는 포트번호, -p는 비밀번호입니다. (비밀번호를 안치고 엔터를 누르면 비밀번호를 입력하라는 안내가 나옵니다.)

ex) mysql -h database-2.cxc85prjtqqq.ap-northeast-2.rds.amazonaws.com -P 3306 -u admin -p
```

설치가 완료된 mysql을 확인하면 아직 아무 데이터도 없을겁니다.

![스크린샷 2022-08-22 오후 11 35 08](https://user-images.githubusercontent.com/103646195/185949018-7c8183a8-645b-49d1-a081-46f2fd3676bd.png)

기존 dump된 파일을 Import하는 작업이 필요합니다.

Import전 `CREATE DATABASE 데이터베이스 이름;` 명령어를 통해 미리 데이터베이스를 만들어 줍니다.

이제 프라이빗 EC2에 복제된 리포지토리중 uer-API폴더에 있는 dump파일 aacompany_dump.sql을 명령어를 통해서 mysql에 Import해야 합니다.


```
{mysql -h 호스트주소 -P 포트번호 -u 사용자이름 -p} {데이터베이스 이름} {< 덤프파일이 저장된 경로 및 덤프파일}
ex) mysql -h database-2.cxc85prjtqqq.ap-northeast-2.rds.amazonaws.com -P 3306 -u admin -p aacompany < /home/ubuntu/mysql/aacompany_dump.sql
```

이제 다시 mysql을 확인하면 database안에 users가 있고 그 안에 사용자 정보가 있습니다.

![스크린샷 2022-08-23 오전 1 39 25](https://user-images.githubusercontent.com/103646195/185973893-3455c588-37fe-41da-8359-3512786da4e3.png)

![스크린샷 2022-08-23 오전 1 35 32](https://user-images.githubusercontent.com/103646195/185973009-c3df4b38-ce2a-42b4-9faf-496c58a4d44e.png)

![스크린샷 2022-08-23 오전 1 37 11](https://user-images.githubusercontent.com/103646195/185973378-91fc0d9e-32cb-4175-979d-f93f3cb5f8f3.png)




