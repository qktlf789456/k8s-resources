# k8s-resources

이 저장소는 Kubernetes(k8s)에 다양한 애플리케이션과 서비스를 배포하기 위한 리소스 정의 파일을 포함한다.

## 구성

- **jenkins/**: Jenkins CI/CD 서버를 Kubernetes에 배포하기 위한 리소스 정의 및 스크립트
  - 자세한 사용법은 [jenkins/README.md](jenkins/README.md) 참조

## 목적

이 저장소의 주요 목적은:
- 다양한 애플리케이션을 Kubernetes에 쉽게 배포할 수 있는 템플릿 제공
- 각 애플리케이션별 최적화된 설정과 배포 스크립트 제공
- Kubernetes 리소스 관리 예제 및 모범 사례 공유

## 사용법

각 디렉토리에는 해당 애플리케이션을 배포하는 방법에 대한 자체 README.md 파일이 포함되어 있습니다. 특정 애플리케이션을 배포하기 위해서는 해당 디렉토리로 이동하여 지침을 따르세요.

## 기여

추가적인 Kubernetes 리소스나 개선 사항은 Pull Request를 통해 제안해 주세요.