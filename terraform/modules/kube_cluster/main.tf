resource "google_container_cluster" "primary" {
  name                      = "${var.prefix}-cluster"
  location                  = var.zone_name
  deletion_protection       = false
  remove_default_node_pool  = true
  initial_node_count        = var.kube_cluster_node_count
  network                   = var.vpc_self_link
  subnetwork                = var.subnet_self_link
  ip_allocation_policy {
    cluster_secondary_range_name  = "pod-ranges"
    services_secondary_range_name = "services-range"
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
    metadata = {
      startup-script = file("${path.module}/scripts/runner-setup.sh")
    }
  }

  upgrade_settings {
    strategy = "SURGE"
    max_surge = 1
    max_unavailable = 0
  }
}
