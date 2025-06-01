#!/bin/bash
set -e

# Navigate to the script directory
cd "$(dirname "$0")"

# Check if node name is provided
if [ -z "$1" ]; then
    echo "Error: Node name is required!"
    echo "Usage: $0 <node-name>"
    echo "Example: $0 docker-desktop"
    exit 1
fi

NODE_NAME=$1

echo "=== Jenkins Kubernetes Deployment Script ==="

# Create data directory in home directory
JENKINS_HOME="$HOME/.jenkins"
JENKINS_DATA_PATH="$JENKINS_HOME/data"

echo "Creating data directory..."
mkdir -p "$JENKINS_DATA_PATH"

echo "Data directory created:"
echo "  Jenkins: $JENKINS_DATA_PATH"

# Set appropriate permissions
echo "Setting directory permissions..."
chmod -R 755 "$JENKINS_DATA_PATH"
echo "Permissions set successfully"


# Create namespace (only if it doesn't exist)
echo "Checking and creating namespace..."
if ! kubectl get namespace devops-tools &> /dev/null; then
  kubectl apply -f namespace.yaml
  echo "devops-tools namespace created successfully"
else
  echo "devops-tools namespace already exists."
fi

# Apply volume with path substitution
echo "Applying volume with dynamic path..."
cat volume.yaml | \
  sed "s|\${JENKINS_DATA_PATH}|$JENKINS_DATA_PATH|g" | \
  kubectl apply -f -
echo "Volume configuration completed"

# Apply deployment
echo "Applying Jenkins deployment..."
kubectl apply -f deployment.yaml
echo "Jenkins deployment applied"

# Create/update service
echo "Applying Jenkins service..."
kubectl apply -f service.yaml
echo "Service configuration completed"

# Check deployment status
echo "Checking deployment status..."
kubectl rollout status deployment/jenkins -n devops-tools

echo "=== Jenkins Pod Status ==="
kubectl get pods -n devops-tools -l app=jenkins-server

echo "=== Jenkins Service Info ==="
kubectl get service jenkins-service -n devops-tools

NODE_PORT=$(kubectl get service jenkins-service -n devops-tools -o jsonpath='{.spec.ports[0].nodePort}')
echo "Jenkins is accessible at http://localhost:${NODE_PORT}"

# Wait a moment for Jenkins to initialize
echo "Waiting for Jenkins to initialize..."
sleep 10

# Get the pod name
JENKINS_POD=$(kubectl get pods -n devops-tools -l app=jenkins-server -o jsonpath='{.items[0].metadata.name}')

# Check for initial admin password
echo "=== Jenkins Initial Admin Password ==="
echo "Checking for password in container..."
kubectl exec -n devops-tools $JENKINS_POD -- cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null || echo "Password not available yet in container"

echo "Checking for password in volume directory..."
if [ -f "$JENKINS_DATA_PATH/secrets/initialAdminPassword" ]; then
  echo "Password from volume directory:"
  cat "$JENKINS_DATA_PATH/secrets/initialAdminPassword"
else
  echo "Password file not found in volume directory yet"
  echo "You can check it later with: cat $JENKINS_DATA_PATH/secrets/initialAdminPassword"
fi

echo "=== Deployment Complete ==="
