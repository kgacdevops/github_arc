resource "google_container_cluster" "primary" {
  name                      = "${var.prefix}-cluster"
  location                  = var.zone_name
  deletion_protection       = false
  remove_default_node_pool  = true
  initial_node_count        = var.kube_cluster_node_count
  network                   = var.vpc_self_link
  subnetwork                = var.subnet_self_link
  ip_allocation_policy {
    cluster_secondary_range_name  = "${var.prefix}-pods"
    services_secondary_range_name = "${var.prefix}-svc"
  }
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "${var.prefix}-node-pool"
  location   = google_container_cluster.primary.location
  cluster    = google_container_cluster.primary.name
  node_count = var.kube_cluster_node_count

  node_config {
    preemptible  = true
    machine_type = var.kube_cluster_machine_type
    service_account = var.svc_account_mail
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  upgrade_settings {
    strategy = "SURGE"
    max_surge = 1
    max_unavailable = 0
  }
}

# Create namespace
resource "kubernetes_namespace_v1" "arc" {
  metadata {
    name = "arc"
  }
}

resource "kubernetes_namespace_v1" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

# Create Secret
resource "kubernetes_secret" "controller_manager" {
  metadata {
    name      = "controller-manager"
    namespace = kubernetes_namespace_v1.arc.metadata[0].name
  }

  data = {
    github_token = var.gh_token # Ensure GH_TOKEN is defined as a variable
  }

  type = "Opaque"
}


# Install Cert-Manager (required for ARC)
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = kubernetes_namespace_v1.cert_manager.metadata[0].name
  version    = "v1.12.0"

  set = [{
    name  = "installCRDs"
    value = "true"
  }]
}

# Install Actions Runner Controller
resource "helm_release" "actions_runner_controller" {
  depends_on = [helm_release.cert_manager, kubernetes_secret.controller_manager]
  
  name       = "actions-runner-controller"
  repository = "https://actions-runner-controller.github.io/actions-runner-controller"
  chart      = "actions-runner-controller"
  namespace  = kubernetes_namespace_v1.arc.metadata[0].name
}