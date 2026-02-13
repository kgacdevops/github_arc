resource "google_compute_network" "vpc_network" {
  name                              = "${var.prefix}-vpc"
  auto_create_subnetworks           = false  
  delete_default_routes_on_create   = true
}

resource "google_compute_subnetwork" "gke_subnet" {
  name                     = "${var.prefix}-subnet"
  ip_cidr_range            = var.cidr_range
  region                   = var.region_name
  network                  = google_compute_network.vpc_network.id

  secondary_ip_range {
    range_name    = "${var.prefix}-pods"
    ip_cidr_range = var.pods_ip_range
  }

  secondary_ip_range {
    range_name    = "${var.prefix}-svc"
    ip_cidr_range = var.svc_ip_range
  }
}

resource "google_compute_global_address" "private_ip_range" {
  name            = "${var.prefix}-control-plane-ip"
  purpose         = "VPC_PEERING"
  address_type    = "INTERNAL"
  prefix_length   = 28
  network         = google_compute_network.vpc_network.id
}
