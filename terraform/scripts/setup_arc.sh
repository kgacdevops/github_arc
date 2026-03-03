arc_namespace="arc"

# Install helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm repo add actions-runner-controller https://actions-runner-controller.github.io/actions-runner-controller
helm repo update

# Create Cert namespace
kubectl create namespace cert-manager

helm repo add jetstack https://charts.jetstack.io
helm repo update

helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --version v1.12.0 \
  --set installCRDs=true

# Create namespace
kubectl create namespace "$arc_namespace"

# Create Secret
kubectl create secret generic controller-manager -n "$arc_namespace" --from-literal=github_token=$GITHUB_PAT

# Install arc
helm install arc actions-runner-controller/actions-runner-controller -n "$arc_namespace"