#!/bin/bash

echo "Cleaning up Jenkins resources from Kubernetes..."

# Delete service
echo "Deleting Jenkins service..."
kubectl delete -f service.yaml --ignore-not-found=true

# Delete deployment
echo "Deleting Jenkins deployment..."
kubectl delete -f deployment.yaml --ignore-not-found=true

# Delete PersistentVolumeClaim
echo "Deleting PersistentVolumeClaim..."
kubectl delete -f volume.yaml --ignore-not-found=true

# Wait for resources to be deleted
echo "Waiting for pods to terminate..."
kubectl wait --for=delete pod -l app=jenkins-server -n devops-tools --timeout=60s 2>/dev/null || true

# Delete namespace (this will delete all remaining resources in the namespace)
echo "Deleting namespace..."
kubectl delete -f namespace.yaml --ignore-not-found=true

# Delete PersistentVolume (not namespaced)
echo "Deleting PersistentVolume..."
kubectl delete pv jenkins-pv --ignore-not-found=true

echo ""
echo "Cleanup completed!"
echo ""
echo "To verify all resources are removed:"
echo "  kubectl get all -n devops-tools"
echo "  kubectl get namespace devops-tools"
echo ""
echo "To remove data directory (optional):"
echo "  rm -rf ~/.jenkins"