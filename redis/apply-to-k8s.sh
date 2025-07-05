#!/bin/bash

echo "Starting Redis deployment to Kubernetes using Kustomization..."

# Apply all resources using kustomization
echo "Applying resources..."
kubectl apply -k .

# Wait for deployment to be ready
echo "Waiting for Redis to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/redis -n redis-namespace

# Show status
echo ""
echo "Deployment status:"
kubectl get all -n redis-namespace

echo ""
echo "Redis deployment completed!"
echo ""
echo "Access Redis:"
echo "- From within cluster: redis-service.redis-namespace.svc.cluster.local:6379"
echo "- From outside cluster: <NODE_IP>:30379"
echo ""
echo "Get node IP with: kubectl get nodes -o wide"