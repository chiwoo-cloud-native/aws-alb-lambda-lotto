# aws-alb-lambda-lotto

이 프로젝트는 Terraform 을 사용하여 AWS 의 대표적인 서버리스 서비스인 Lambda 와 여기에 관련된 AWS 리소스를 한번에 프로비저닝하는 데모 입니다.

샘플 (lotto) 애플리케이션은 1 에서 45 까지의 숫자 중 6자리 숫자를 랜덤으로 추천하는 로또 번호 추천 서비스 입니다. 

## Architecture
 
![](architecture.svg)

### 주요 리소스 개요
- Route 53: 인터넷 사용자가 도메인 이름을 통해 서비스에 접근 합니다.
- VPC: 컴퓨팅 리소스를 배치하는 공간으로 네트워크 구성 및 네트워크 연결 리소스로 서로 통합 되어 있습니다.
- ALB: Route 53 으로부터 유입되는 트래픽을 요청에 대응하는 Lambda 애플리케이션 서비스로 라우팅 합니다.
- ECR: lotto 컨테이너 (도커) 이미지를 등록 관리하는 이미지 저장소 입니다.
- Lambda: lotto 애플리케이션 서비스 입니다.
- CloudWatch LogGroup: Lambda 애플리케이션 서비스의 로그를 수집합니다.
- IAM Role: Lambda 배치 및 실행을 위한 롤 및 정책이 구성 됩니다.

<br>

## Pre-requisite

AWS Lambda 서버리스 컴퓨팅 서비스를 프로비저닝 하기 위해 다음의 Tool 들을 설치 해야 합니다.

- [Terraform 설치](https://learn.hashicorp.com/tutorials/terraform/install-cli)

- [AWS CLI 설치](https://docs.aws.amazon.com/ko_kr/cli/latest/userguide/install-cliv2.html) 가이드를 참고하여 구성해 주세요.

- [AWS Confiugre](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html) 가이드를 참고하여 프로파일을 설정 합니다.  
```
aws configure --profile terra
```

- [Docker 설치](https://docs.docker.com/desktop/mac/install/)


- 특히, Domain 서비스가 사전에 구성 되어 있어야 하며, Docker 이미지를 빌드 할 수 있도록 Docker Daemon 이 구동되어 있어야 합니다.
  아래 `docker images` 명령을 통해 아래와 같이 정상 동적 여부를 확인 하세요.  

![](docker-img.png)

- 인터넷 서비스를 위한 도메인을 발급 받고 Route 53 의 Public Host Zone 을 사전에 구성해 주세요.  
  [도메인 발급 및 Route53 구성](https://symplesims.github.io/devops/route53/acm/hosting/2022/01/11/aws-route53.html) 을 참고 하여 무료 도메인을 한시적으로 활용할 수 있습니다.

- Git, Terraform, AWS-CLI, NodeJS 등 주요 프로그램을 로컬 환경(PC) 에 설치 및 설정 하세요.  
  [Mac OS 개발자를 위한 로컬 개발 환경 구성](https://symplesims.github.io/development/setup/macos/2021/12/02/setup-development-environment-on-macos.html) 을 참고 하여 필요한 프로그램을 구성할 수 있습니다.

<br>

## Git
```
git clone https://github.com/chiwoo-cloud-native/aws-alb-lambda-lotto.git

# 프로젝트 기준 경로로 이동하세요.
cd aws-alb-lambda-lotto
```

<br>

## 애플리케이션 코드

Lambda 의 콜드 스타트 타임을 최소화 하기 위해 nodejs 로 구현 하였으며 핵심 로직은 다음과 같습니다.  
 
```javascript
exports.lambdaHandler = async (event, context, callback) => {
    const numbers = Array(45).fill(1).map((n, i) => n + i) // 1 부터 45 까지의 정수를 Array 로 생성 합니다.  
    numbers.sort(() => Math.random() - 0.5); // Array 순서를 셔플로 섞습니다.  
    const result = numbers.slice(0, 6); // 상위 6개의 Array 만 남깁니다. 
    console.log(result)
}
```

## Build
Terraform 모듈을 통해 AWS 클라우드 리소스를 한번에 구성 합니다.

서비스 구성을 위한 [context](./terraform.tfvars) 테라폼 변수는 본인의 환경에 맞게 구성 하세요.

```
# 테라폼 프로젝트 초기화
terraform init

# PLAN 확인 
terraform plan

# 프로비저닝
terraform apply 
```

<br>


## main 프로세스 

[main.tf](./main.tf) 파일을 통해 프로비저닝이 진행 됩니다. 

```hcl

# 네이밍 및 Tagging 속성 정보를 Context 정보로 구성 하며, 각 Module 은 이 Context 정보를 참조하여 일관성 있는 네이밍 및 태깅 정보를 유지하게 됩니다.  
module "ctx" {
  source  = "./modules/context/"
  context = var.context
}

# VPC 리소스 생성하며 CIDR 네트워크 대역 및 subnet 과 Availability 가용 영역 을 정의 합니다.  
module "vpc" {
  source = "registry.terraform.io/terraform-aws-modules/vpc/aws"
}

# IGW 의 트래픽을 라우팅하는 애플리케이션 로드 밸런서를 구성 합니다. 
module "alb" {
  source      = "./modules/alb/"
  ...
  depends_on = [module.vpc]
}

# Lambda 서비스 구성
module "lambda" {
  source = "./modules/lambda/"
  ...
  depends_on = [module.alb]
}

```


## Check
프로비저닝이 완료된 이후 `cURL` 명령을 통해 Lambda 가 정상적으로 동작하는지 확인 할 수 있습니다.

```
curl -v -X GET https://lotto.sympleops.ml/ 
...
...
* Mark bundle as not supporting multiuse
< HTTP/1.1 200 OK
< Server: awselb/2.0
< Date: Fri, 05 Aug 2022 01:55:40 GMT
< Content-Type: application/json
< Content-Length: 18
< Connection: keep-alive
< 
* Connection #0 to host lotto.sympleops.ml left intact
[13,28,39,38,19,8]  
```

<br>

CloudWatch 로그를 통해 Lambda 함수의 실행시간, 처리내역, Memory 사용내역 등 주요 정보를 확인 할 수 있습니다.
```
2022-08-05T01:55:40.379000+00:00 2022/08/05/[$LATEST]5bdb128046f34f24904d0e754adf11b0 START RequestId: afeb5180-e36c-4def-a21b-e0d8ec32f4d1 Version: $LATEST
2022-08-05T01:55:40.382000+00:00 2022/08/05/[$LATEST]5bdb128046f34f24904d0e754adf11b0 2022-08-05T01:55:40.382Z	afeb5180-e36c-4def-a21b-e0d8ec32f4d1	INFOCalled lambdaHandler: lotto
2022-08-05T01:55:40.382000+00:00 2022/08/05/[$LATEST]5bdb128046f34f24904d0e754adf11b0 2022-08-05T01:55:40.382Z	afeb5180-e36c-4def-a21b-e0d8ec32f4d1	INFOresult: [ 13, 28, 39, 38, 19, 8 ]
2022-08-05T01:55:40.383000+00:00 2022/08/05/[$LATEST]5bdb128046f34f24904d0e754adf11b0 END RequestId: afeb5180-e36c-4def-a21b-e0d8ec32f4d1
2022-08-05T01:55:40.383000+00:00 2022/08/05/[$LATEST]5bdb128046f34f24904d0e754adf11b0 REPORT RequestId: afeb5180-e36c-4def-a21b-e0d8ec32f4d1	Duration: 1.73 ms	Billed Duration: 2 ms	Memory Size: 128 MB	Max Memory Used: 58 MB
```


<br>


## Destroy

lotto 서비스와 관련된 모든 AWS 리소스를 한번에 제거 합니다.

경우에 따라서 Security-Group 이 제거되기까지 30분 정도 소요 될 수 있습니다.

```
terraform destroy
```
