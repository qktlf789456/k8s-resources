#!/bin/bash

echo "Applying Grafana-Loki resources to Kubernetes..."

# Apply namespace first
kubectl apply -f namespace.yaml

# Wait for namespace to be created
sleep 2

# Apply ConfigMap
kubectl apply -f grafana-configmap.yaml

# Apply Loki deployment and service
kubectl apply -f loki-deployment.yaml
kubectl apply -f loki-service.yaml

# Apply Grafana deployment and service
kubectl apply -f grafana-deployment.yaml
kubectl apply -f grafana-service.yaml

echo "All resources have been applied successfully!"
echo ""
echo "To check the status of pods:"
echo "  kubectl get pods -n monitoring"
echo ""
echo "To access services (after pods are running):"
echo ""
echo "  Grafana Dashboard: http://localhost:32101"
echo "  Loki API: http://localhost:32102"