# Jenkins for k8s

쿠버네티스 클러스터에 Jenkins를 설정하기 위한 매니페스트 파일과 배포 스크립트를 정리한다.

## 구성 요소

- `namespace.yaml`: `devops-tools` 네임스페이스 생성
- `volume.yaml`: Jenkins 데이터를 위한 StorageClass, PersistentVolume 및 PersistentVolumeClaim 정의
- `deployment.yaml`: Jenkins 배포 구성
- `service.yaml`: NodePort 서비스를 통해 Jenkins 노출
- `apply-to-k8s.sh`: 배포 스크립트

## 적용 방법

use `apply-to-k8s.sh` to deploy.

```bash
# 기본 사용법
./apply-to-k8s.sh <쿠버네티스-설정-이름>

# e.g.,
./apply-to-k8s.sh my-context-name
```

**참고:** 스크립트 실행 전 `volume.yaml` 파일에서 다음 두 항목을 확인하자.
- `K8S_NODE_NAME_TO_BE_REPLACED` - Kubernetes 노드 이름으로 대체해야 함
  -  PersistentVolume이 특정 노드에 바인딩되는 것을 의미. 
  - **중요**: 이 노드가 클러스터에서 제거되거나 교체될 경우 볼륨 데이터가 완전히 손실될 수 있음에 유의

## 참고

- 배포 스크립트는 멱등성을 갖도록 구성되었음.
- Jenkins 데이터를 위한 볼륨은 Unix 기반 운영체제 환경에서 자동으로 구성됩니다:
  - macOS: `/Users/<사용자이름>/jenkins-data`
  - Linux: `/home/<사용자이름>/jenkins-data`


### 구성 후 사용

- Jenkins는 NodePort 서비스를 통해 노출된다. (기본 포트: 32000)
- 접근 URL: http://localhost:32000
- 초기 관리자 비밀번호는 다음 위치에서 확인할 수 있음.
  - `~/jenkins-data/secrets/initialAdminPassword`
  - `apply-to-k8s.sh` 를 사용하는 경우 구성 완료 시 초기 패스워드를 확인할 수 있음.

## k8s 리소스 정리

```bash
kubectl delete deployment jenkins -n devops-tools
kubectl delete service jenkins-service -n devops-tools
kubectl delete pvc jenkins-pv-claim -n devops-tools
kubectl delete pv jenkins-pv-hostpath
kubectl delete storageclass local-storage
```
