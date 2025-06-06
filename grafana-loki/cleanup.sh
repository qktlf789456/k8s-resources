#!/bin/bash

echo "Cleaning up Grafana-Loki resources from Kubernetes..."

# Delete deployments and services
echo "Deleting Grafana resources..."
kubectl delete -f grafana-service.yaml --ignore-not-found=true
kubectl delete -f grafana-deployment.yaml --ignore-not-found=true

echo "Deleting Loki resources..."
kubectl delete -f loki-service.yaml --ignore-not-found=true
kubectl delete -f loki-deployment.yaml --ignore-not-found=true

echo "Deleting ConfigMaps..."
kubectl delete -f grafana-configmap.yaml --ignore-not-found=true
kubectl delete -f loki-configmap.yaml --ignore-not-found=true

# Delete PersistentVolumeClaims
echo "Deleting PersistentVolumeClaims..."
kubectl delete -f loki-volume.yaml --ignore-not-found=true
kubectl delete -f grafana-volume.yaml --ignore-not-found=true

# Wait for resources to be deleted
echo "Waiting for pods to terminate..."
kubectl wait --for=delete pod -l app=grafana -n monitoring --timeout=60s 2>/dev/null || true
kubectl wait --for=delete pod -l app=loki -n monitoring --timeout=60s 2>/dev/null || true

# Delete namespace (this will delete all remaining resources in the namespace)
echo "Deleting namespace..."
kubectl delete -f namespace.yaml --ignore-not-found=true

# Delete PersistentVolumes (these are not namespaced)
echo "Deleting PersistentVolumes..."
kubectl delete pv loki-pv grafana-pv --ignore-not-found=true

echo ""
echo "Cleanup completed!"
echo ""
echo "To verify all resources are removed:"
echo "  kubectl get all -n monitoring"
echo "  kubectl get namespace monitoring"
echo ""
echo "To remove data directories (optional):"
echo "  rm -rf ~/.grafana-loki"