#!/bin/bash

echo "Starting Redis cleanup from Kubernetes..."

# Delete all resources using kustomization
echo "Deleting all resources..."
kubectl delete -k . --ignore-not-found=true

echo ""
echo "Redis cleanup completed!"