#!/bin/bash

# Check if password parameter is provided
if [ $# -eq 0 ]; then
    echo "Error: Redis password is required!"
    echo "Usage: $0 <password>"
    echo "Example: $0 mySecurePassword123!"
    exit 1
fi

REDIS_PASSWORD=$1

echo "Starting Redis deployment to Kubernetes using Kustomization..."

# Create namespace first (kustomize doesn't create namespaces automatically)
echo "Creating namespace..."
kubectl create namespace dev-tools --dry-run=client -o yaml | kubectl apply -f -

# Create a temporary directory for modified files
TEMP_DIR=$(mktemp -d)
cp -r . "$TEMP_DIR/"

# Replace placeholder with actual password in the temporary file
sed -i.bak "s/\${REDIS_PASSWORD}/$REDIS_PASSWORD/g" "$TEMP_DIR/redis-secret.yaml"

# Apply all resources using kustomization from temp directory
echo "Applying resources with custom password..."
kubectl apply -k "$TEMP_DIR"

# Clean up temporary directory
rm -rf "$TEMP_DIR"

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
echo "- Password: $REDIS_PASSWORD"
echo ""
echo "Get node IP with: kubectl get nodes -o wide"