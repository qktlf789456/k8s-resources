#!/bin/bash
set -e

# First assign the config name from parameter
K8S_CONFIG_NAME="$1"
USERNAME="$2"

# Navigate to the script directory
cd "$(dirname "$0")"

# Check if K8s config name is provided
if [ -z "$K8S_CONFIG_NAME" ]; then
  echo "Error: Kubernetes config name is required as first parameter"
  echo "Usage: $0 <kubernetes-config-name> [username]"
  exit 1
fi

# If username is not provided, get it automatically
if [ -z "$USERNAME" ]; then
  USERNAME=$(whoami)
  echo "Using detected username: $USERNAME"
fi

echo "=== Jenkins Kubernetes Deployment Script (Config: $K8S_CONFIG_NAME, User: $USERNAME) ==="

# Check if the specified context exists
if ! kubectl config get-contexts "$K8S_CONFIG_NAME" &> /dev/null; then
  echo "Error: Kubernetes config '$K8S_CONFIG_NAME' not found"
  echo "Available configs:"
  kubectl config get-contexts
  exit 1
fi

# Set the Kubernetes context to the specified config
echo "Setting Kubernetes context to: $K8S_CONFIG_NAME"
kubectl config use-context "$K8S_CONFIG_NAME"

# Determine OS type and set paths accordingly
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS path
  JENKINS_DATA_DIR="/Users/$USERNAME/jenkins-data"
else
  # Linux path (default)
  JENKINS_DATA_DIR="/home/$USERNAME/jenkins-data"
fi

echo "Using volume directory: $JENKINS_DATA_DIR"

# Create the directory if it doesn't exist
if [ ! -d "$JENKINS_DATA_DIR" ]; then
  mkdir -p "$JENKINS_DATA_DIR"
  chmod 755 "$JENKINS_DATA_DIR"
  echo "Created volume directory"
else
  echo "Volume directory already exists."
fi


# Update volume.yaml with the correct path
echo "Updating volume path in yaml..."
sed -i.bak "s|path: .*|path: $JENKINS_DATA_DIR|g" volume.yaml


# Create namespace (only if it doesn't exist)
echo "Checking and creating namespace..."
if ! kubectl get namespace devops-tools &> /dev/null; then
  kubectl apply -f namespace.yaml
  echo "devops-tools namespace created successfully"
else
  echo "devops-tools namespace already exists."
fi

# Create/update storage class and volume
echo "Applying storage class and volume..."
kubectl apply -f volume.yaml
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
if [ -f "$JENKINS_DATA_DIR/secrets/initialAdminPassword" ]; then
  echo "Password from volume directory:"
  cat "$JENKINS_DATA_DIR/secrets/initialAdminPassword"
else
  echo "Password file not found in volume directory yet"
  echo "You can check it later with: cat $JENKINS_DATA_DIR/secrets/initialAdminPassword"
fi

echo "=== Deployment Complete ==="
