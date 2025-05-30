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

# Apply Grafana deployment and service
kubectl apply -f grafana-deployment.yaml

echo "All resources have been applied successfully!"
echo ""
echo "To check the status of pods:"
echo "  kubectl get pods -n monitoring"
echo ""
echo "To access Grafana (after pods are running):"
echo "  kubectl port-forward -n monitoring svc/grafana 3000:3000"
echo "  Then open http://localhost:3000 in your browser"