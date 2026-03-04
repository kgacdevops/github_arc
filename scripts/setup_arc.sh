arc_namespace="arc"

# Install helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm repo add actions-runner-controller https://actions-runner-controller.github.io/actions-runner-controller
helm repo add jetstack https://charts.jetstack.io
helm repo update

# Clean up Webhooks
kubectl delete validatingwebhookconfiguration cert-manager-webhook || echo "No webhook found"
kubectl delete mutatingwebhookconfiguration cert-manager-webhook || echo "No webhook found"

# Create Cert manager
kubectl create namespace cert-manager || echo "Namespace exists"
# helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.12.0 --set installCRDs=true || { echo "Failed creating cert manager"; exit 1; }
# If time out errors when using helm, use below direct setup:
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.12.0/cert-manager.crds.yaml || { echo "Failed creating cert manager"; exit 1; }

# Create namespace
kubectl create namespace "$arc_namespace" || echo "Namespace exists"

# Create Secret
kubectl create secret generic controller-manager -n "$arc_namespace" --from-literal=github_token=$GITHUB_PAT || { echo "Failed creating secrets"; exit 1; }

# Install arc
helm install arc actions-runner-controller/actions-runner-controller -n "$arc_namespace" || { echo "Failed installing arc"; exit 1; }