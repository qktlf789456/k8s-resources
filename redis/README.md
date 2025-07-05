# Redis on Kubernetes

Kustomization을 사용한 Redis 배포

## 구성 요소

- **kustomization.yaml**: Kustomization 설정
- **redis-deployment.yaml**: Redis 배포 (메모리 전용)
- **redis-service.yaml**: NodePort 서비스

## 배포

```bash
# 스크립트 사용 (패스워드 필수)
./apply-to-k8s.sh <password>

# 예시
./apply-to-k8s.sh mySecurePassword123!
```

## 접속 방법

```bash
# 클러스터 외부에서 (배포 시 지정한 패스워드 사용)
redis-cli -h <NODE_IP> -p 32103 -a <password>

# 클러스터 내부에서  
kubectl exec -it deployment/redis -n dev-tools -- redis-cli -a <password>
```

## 삭제

```bash
# 빠른 삭제
kubectl delete -k .

# 또는 스크립트 사용
./cleanup.sh
```

## 보안

- 배포 시 패스워드 필수 지정
- 패스워드는 Kubernetes Secret으로 관리됨

## 주의사항

- 데이터 영속성 없음 (재시작 시 데이터 손실)
- 개발/테스트 환경용 최소 구성
- 프로덕션에서는 더 강력한 패스워드 사용 권장