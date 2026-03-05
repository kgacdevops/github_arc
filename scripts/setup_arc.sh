#!/bin/bash
set -e

# Variables
arc_namespace="arc"
cert_mgr_namespace="cert-manager"
cert_mgr_ver="v1.12.0"

# Add Helm Repos
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm repo add actions-runner-controller https://actions-runner-controller.github.io/actions-runner-controller
helm repo add jetstack https://charts.jetstack.io
helm repo update

# Install Full Cert-Manager (Includes CRDs + Controllers)
echo "Installing Cert-Manager..."
kubectl create namespace "$cert_mgr_namespace" || echo "Namespace exists"
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/${cert_mgr_ver}/cert-manager.crds.yaml 
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/${cert_mgr_ver}/cert-manager.yaml 
sleep 30s

# Wait for Cert-Manager pods to be ready
echo "Waiting for Cert-Manager to be ready (this can take 2-3 minutes)..."
kubectl wait --for=condition=Available deployment --all -n "$cert_mgr_namespace" --timeout=300s

# Prepare ARC Namespace and Secret
kubectl create namespace "$arc_namespace" || echo "Namespace exists"
kubectl create secret generic controller-manager -n "$arc_namespace" --from-literal=github_token="$GH_TOKEN" || echo "Secrets already exist"

# Install ARC
echo "Installing Actions Runner Controller..."
helm install arc actions-runner-controller/actions-runner-controller -n "$arc_namespace" --set authSecret.name="controller-manager" --set authSecret.github_token="github_token" --set github_app_id="" --set github_app_installation_id="" --set github_app_priv_key=""