# Jenkins for Kubernetes

Kubernetes 클러스터에 Jenkins를 배포하기 위한 매니페스트 파일과 배포 스크립트를 포함함

## 구성 요소

- `namespace.yaml`: `devops-tools` 네임스페이스 생성
- `volume.yaml`: Jenkins 데이터를 위한 PersistentVolume 및 PersistentVolumeClaim 정의
- `deployment.yaml`: Jenkins 배포 구성
- `service.yaml`: NodePort 서비스를 통해 Jenkins 노출
- `apply-to-k8s.sh`: 배포 스크립트
- `cleanup.sh`: 리소스 정리 스크립트

## 배포 방법

`apply-to-k8s.sh` 스크립트를 사용하여 배포함

```bash
# 기본 사용법
./apply-to-k8s.sh <node-name>

# e.g.,
./apply-to-k8s.sh docker-desktop
```

**참고:** 
- Jenkins 데이터는 `~/.jenkins/data`에 저장됨
- PersistentVolume은 hostPath를 사용하여 노드의 로컬 디스크에 데이터를 저장함
- **중요**: hostPath는 프로덕션 환경에 권장되지 않음. 필요시 다른 스토리지 드라이버 사용 권장

## 참고

- 배포 스크립트는 멱등성을 갖도록 구성됨
- Jenkins 데이터 디렉토리: `~/.jenkins/data`

### 배포 후 사용

- Jenkins는 NodePort 서비스를 통해 노출됨 (기본 포트: 32000)
- 접근 URL: http://localhost:32000
- 초기 관리자 비밀번호는 다음 위치에서 확인할 수 있음:
  - `~/.jenkins/data/secrets/initialAdminPassword`
  - `apply-to-k8s.sh`를 사용하는 경우 배포 완료 시 초기 비밀번호가 표시됨

## Kubernetes 리소스 정리

간편한 정리를 위한 cleanup 스크립트 사용:

```bash
./cleanup.sh
```

또는 수동으로 정리:

```bash
kubectl delete deployment jenkins -n devops-tools
kubectl delete service jenkins-service -n devops-tools
kubectl delete pvc jenkins-pvc -n devops-tools
kubectl delete pv jenkins-pv
kubectl delete namespace devops-tools
```

## 데이터 디렉토리 제거 (선택사항)

```bash
rm -rf ~/.jenkins
```
