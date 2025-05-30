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

### 4. 스크립트
- `apply-to-k8s.sh`: 모든 리소스를 순서대로 배포
- `cleanup.sh`: 모든 리소스 제거

## 배포 방법

### 1. 전체 배포
```bash
./apply-to-k8s.sh
```

### 2. 개별 배포
```bash
# Namespace 생성
kubectl apply -f namespace.yaml

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

# Loki API (외부 애플리케이션용)
http://localhost:32102/loki/api/v1/push
```

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

## 주요 설정

### Grafana
- 익명 접근 활성화 (GF_AUTH_ANONYMOUS_ENABLED=true)
- 익명 사용자 권한: Admin (GF_AUTH_ANONYMOUS_ORG_ROLE=Admin)
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
3. Grafana의 기본 admin 계정은 비활성화되어 있으며, 익명 접근만 가능합니다