resource "google_compute_network" "vpc_network" {
  name                          = var.vpc_name
  project                       = var.project_id
  auto_create_subnetworks       = true
  mtu                           = var.mtu_val
  routing_mode                  = "GLOBAL"
  bgp_best_path_selection_mode  = "STANDARD"
}

resource "google_container_cluster" "primary" {
  name                      = var.kube_cluster_name
  location                  = var.zone_name
  deletion_protection       = false
  remove_default_node_pool  = true
  initial_node_count        = var.kube_cluster_node_count
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = var.kube_cluster_node_pool_name
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
