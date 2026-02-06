data "google_service_accounts" "gcp_sa" {
  prefix   = "gh-gcp-runner-sa"
  project  = var.project_id
}

resource "google_project_iam_member" "gcp_sa_role" {
  project = var.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${data.google_service_accounts.gcp_sa.accounts[0].email}"
}

resource "google_container_cluster" "primary" {
  name                      = var.kube_cluster_name
  location                  = var.zone_name
  node_locations = [
    var.zone_name
  ]
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
    service_account = data.google_service_accounts.gcp_sa.accounts[0].email
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
