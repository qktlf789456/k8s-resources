# Redis on Kubernetes

Kustomization을 사용한 Redis 배포

## 구성 요소

- **kustomization.yaml**: Kustomization 설정
- **redis-deployment.yaml**: Redis 배포 (메모리 전용)
- **redis-service.yaml**: NodePort 서비스

## 배포

```bash
# 빠른 배포
kubectl apply -k .

# 또는 스크립트 사용
./apply-to-k8s.sh
```

## 접속 방법

```bash
redis-cli -h <NODE_IP> -p 32103
```

## 삭제

```bash
# 빠른 삭제
kubectl delete -k .

# 또는 스크립트 사용
./cleanup.sh
```

## 주의사항

- 인증 없음 (비밀번호 미설정)
- 데이터 영속성 없음 (재시작 시 데이터 손실)
- 개발/테스트 환경용 최소 구성