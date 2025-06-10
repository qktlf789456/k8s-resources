# Grafana Loki Kubernetes Deployment

이 디렉토리는 Grafana와 Loki를 Kubernetes 클러스터에 배포하기 위한 매니페스트 파일들을 포함합니다.

## 개요

Grafana & Loki 구성으로 로그 집계 시스템을 구성합니다.

- **Loki**: 로그 수집 및 저장 서버
- **Grafana**: 로그 시각화 및 쿼리를 위한 대시보드

## 구성 요소

### 1. Namespace
- `namespace.yaml`: monitoring 네임스페이스 생성

### 2. Loki
- `loki-deployment.yaml`: Loki 서버 배포 (1개 레플리카)
- `loki-service.yaml`: Loki 서비스 (NodePort, 내부: 3100, 외부: 32102)

### 3. Grafana
- `grafana-deployment.yaml`: Grafana 대시보드 배포 (1개 레플리카)
- `grafana-service.yaml`: Grafana 외부 접근용 서비스 (NodePort, 포트: 32101)
- `grafana-configmap.yaml`: Loki 데이터소스 자동 설정

### 4. Volume
- `volume.yaml`: Loki와 Grafana의 데이터를 저장할 PersistentVolume/PVC 정의

### 5. 스크립트
- `apply-to-k8s.sh`: 모든 리소스를 순서대로 배포 (노드명 필수)
- `cleanup.sh`: 모든 리소스 제거

## 배포 방법

### 1. 전체 배포
```bash
# 노드명 필수 (예: docker-desktop)
./apply-to-k8s.sh <node-name>

# 예시
./apply-to-k8s.sh docker-desktop
```

**참고**: 
- 데이터는 `~/.grafana-loki` 디렉토리에 저장됩니다
- 스크립트가 자동으로 데이터 디렉토리를 생성합니다

### 2. 개별 배포
```bash
# Namespace 생성
kubectl apply -f namespace.yaml

# Volume 생성 (경로 치환 필요)
kubectl apply -f volume.yaml

# ConfigMap 생성
kubectl apply -f grafana-configmap.yaml

# Loki 배포
kubectl apply -f loki-deployment.yaml
kubectl apply -f loki-service.yaml

# Grafana 배포
kubectl apply -f grafana-deployment.yaml
kubectl apply -f grafana-service.yaml
```

## 접속 방법

```bash
# Grafana 대시보드
http://localhost:32101

# 초기 로그인 정보
Username: admin
Password: admin

# Loki API (외부 애플리케이션용)
http://localhost:32102/loki/api/v1/push
```

**중요**: 첫 로그인 후 반드시 admin 비밀번호를 변경하세요!

## 확인 명령어

### Pod 상태 확인
```bash
kubectl get pods -n monitoring
```

### Service 확인
```bash
kubectl get svc -n monitoring
```

### 로그 확인
```bash
# Loki 로그
kubectl logs -n monitoring deployment/loki

# Grafana 로그
kubectl logs -n monitoring deployment/grafana
```

## 정리 방법

모든 리소스를 제거하려면:
```bash
./cleanup.sh
```

데이터 디렉토리를 완전히 삭제하려면:
```bash
rm -rf ~/.grafana-loki
```

## 주요 설정

### Grafana
- 익명 접근 비활성화 (인증 필요)
- 기본 관리자 계정: admin / admin
- 로그인 후 비밀번호 변경 권장
- Loki 데이터소스 자동 구성

### Loki
- 기본 로컬 설정 사용 (-config.file=/etc/loki/local-config.yaml)
- 단일 인스턴스 모드

## 외부 애플리케이션에서 Loki 접근

Kubernetes 외부에서 Loki로 로그를 전송하려면 NodePort를 통해 접근:

- **Loki Push API**: `http://localhost:32102/loki/api/v1/push`
- **Health Check**: `http://localhost:32102/ready`

## 참고 사항

1. 이 구성은 개발/테스트 환경용입니다
2. 프로덕션 환경에서는 적절한 인증, 영구 스토리지, 고가용성 설정이 필요합니다
3. Grafana는 인증이 필요하며, 기본 계정(admin/admin)으로 로그인 후 비밀번호를 변경해야 합니다