#!/bin/bash
set -e

# Variables
arc_namespace="arc"
cert_mgr_ver="v1.12.0"

# Add Helm Repos
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm repo add actions-runner-controller https://actions-runner-controller.github.io
helm repo add jetstack https://charts.jetstack.io
helm repo update

# Install Full Cert-Manager (Includes CRDs + Controllers)
echo "Installing Cert-Manager..."
kubectl apply -f "https://github.com/${cert_mgr_ver}/cert-manager.yaml"

# Wait for Cert-Manager pods to be ready
# Without this, ARC will fail to find the 'serving-cert' secret
echo "Waiting for Cert-Manager to be ready (this can take 2-3 minutes)..."
kubectl wait --for=condition=Available deployment --all -n cert-manager --timeout=300s

# 4. Prepare ARC Namespace and Secret
kubectl create namespace "$arc_namespace" || echo "Namespace exists"
kubectl create secret generic controller-manager -n "$arc_namespace" --from-literal=github_token="$GH_TOKEN" --dry-run=client -o yaml | kubectl apply -f -

# 5. Install ARC
echo "Installing Actions Runner Controller..."
helm upgrade --install arc actions-runner-controller/actions-runner-controller -n "$arc_namespace" --set installCRDs=false