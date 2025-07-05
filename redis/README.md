# Redis on Kubernetes with Kustomization

This directory contains Kubernetes manifests for deploying Redis using Kustomization.

## Components

- **kustomization.yaml**: Kustomization configuration (includes namespace management)
- **redis-deployment.yaml**: Redis deployment with 1 replica (in-memory only)
- **redis-service.yaml**: NodePort service for external access

## Prerequisites

- Kubernetes cluster
- kubectl with kustomize support (kubectl 1.14+)
- Sufficient permissions to create resources

## Deployment

### Quick Deploy
```bash
kubectl apply -k .
```

### Using Scripts
1. Make the scripts executable:
   ```bash
   chmod +x apply-to-k8s.sh cleanup.sh
   ```

2. Deploy Redis:
   ```bash
   ./apply-to-k8s.sh
   ```

## Configuration

### Kustomization Features
- Namespace: All resources deployed to `redis-namespace`
- Common labels: `app: redis`, `environment: development`
- Image management: Easy to update Redis version in kustomization.yaml

### Resource Limits
- Memory: 128Mi (request) / 256Mi (limit)
- CPU: 100m (request) / 500m (limit)

### Service Configuration
- Type: NodePort
- Internal port: 6379
- External port: 32103

### Important Notes
- No authentication configured (runs without password)
- No persistence (data is lost when pod restarts)
- Single replica (no high availability)

This is a minimal setup suitable for development/testing environments.

## Access

### From outside the cluster
```bash
redis-cli -h <NODE_IP> -p 32103
```

### From within the cluster
```bash
redis-cli -h redis-service.redis-namespace.svc.cluster.local -p 6379
```

### Connect with kubectl
```bash
kubectl exec -it deployment/redis -n redis-namespace -- redis-cli
```

### Get Node IP
```bash
kubectl get nodes -o wide
```

## Customization

### Change Redis Version
Edit `kustomization.yaml`:
```yaml
images:
  - name: redis
    newTag: 7.2-alpine  # Change to desired version
```

### Add Environment Variables
Create a patch file or add to kustomization.yaml:
```yaml
patchesStrategicMerge:
  - redis-patch.yaml
```

## Monitoring

Check deployment status:
```bash
kubectl get all -n redis-namespace
```

Check logs:
```bash
kubectl logs deployment/redis -n redis-namespace
```

## Cleanup

### Quick Delete
```bash
kubectl delete -k .
```

### Using Script
```bash
./cleanup.sh
```

## Production Considerations

For production use, consider:
1. Enable authentication with password/ACL
2. Add persistent storage (PVC)
3. Configure replication or Redis Sentinel for HA
4. Enable TLS for encrypted connections
5. Set appropriate resource limits based on workload
6. Configure backup strategy
7. Use LoadBalancer or Ingress instead of NodePort