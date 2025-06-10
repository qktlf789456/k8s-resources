#!/bin/bash

echo "Applying Grafana-Loki resources to Kubernetes..."

# Check if node name is provided
if [ -z "$1" ]; then
    echo "Error: Node name is required!"
    echo "Usage: $0 <node-name>"
    echo "Example: $0 docker-desktop"
    exit 1
fi

NODE_NAME=$1

# Create data directories in home directory
GRAFANA_LOKI_HOME="$HOME/.grafana-loki"
LOKI_DATA_PATH="$GRAFANA_LOKI_HOME/loki-data"
GRAFANA_DATA_PATH="$GRAFANA_LOKI_HOME/grafana-data"

echo "Creating data directories..."
mkdir -p "$LOKI_DATA_PATH"
mkdir -p "$GRAFANA_DATA_PATH"

echo "Data directories created:"
echo "  Loki: $LOKI_DATA_PATH"
echo "  Grafana: $GRAFANA_DATA_PATH"

# Set appropriate permissions for Grafana and Loki
echo "Setting directory permissions..."
chmod -R 777 "$LOKI_DATA_PATH" "$GRAFANA_DATA_PATH"
echo "Permissions set successfully"

# Apply namespace first
kubectl apply -f namespace.yaml

# Wait for namespace to be created
sleep 2

# Apply Volumes with path substitution
echo "Applying volumes with dynamic paths..."
cat loki-volume.yaml | \
  sed "s|\${LOKI_DATA_PATH}|$LOKI_DATA_PATH|g" | \
  kubectl apply -f -

cat grafana-volume.yaml | \
  sed "s|\${GRAFANA_DATA_PATH}|$GRAFANA_DATA_PATH|g" | \
  kubectl apply -f -

# Apply ConfigMaps
kubectl apply -f grafana-configmap.yaml
kubectl apply -f loki-configmap.yaml

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