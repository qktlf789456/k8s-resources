#!/bin/bash

echo "Starting Redis deployment to Kubernetes using Kustomization..."

# Create namespace first (kustomize doesn't create namespaces automatically)
echo "Creating namespace..."
kubectl create namespace dev-tools --dry-run=client -o yaml | kubectl apply -f -

# Apply all resources using kustomization
echo "Applying resources..."
kubectl apply -k .

# Wait for deployment to be ready
echo "Waiting for Redis to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/redis -n dev-tools

# Show status
echo ""
echo "Deployment status:"
kubectl get all -n dev-tools

echo ""
echo "Redis deployment completed!"
echo ""
echo "Access Redis:"
echo "- From within cluster: redis-service.dev-tools.svc.cluster.local:6379"
echo "- From outside cluster: <NODE_IP>:32103"
echo ""
echo "Get node IP with: kubectl get nodes -o wide"