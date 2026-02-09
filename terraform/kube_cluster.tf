resource "google_container_cluster" "primary" {
  name                      = var.kube_cluster_name
  location                  = var.zone_name
  deletion_protection       = false
  remove_default_node_pool  = true
  initial_node_count        = var.kube_cluster_node_count
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = var.kube_cluster_node_pool_name
  location   = var.region_name
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
