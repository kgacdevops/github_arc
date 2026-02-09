terraform {
    required_providers {
        google = {
            source = "hashicorp/google"
            version = "~> 6.0"
        }
    }
}

provider "google" {
    project = var.project_id
    region = var.region_name
    workload_identity_pool = "projects/390209572226/locations/global/workloadIdentityPools/github-pool"
    workload_identity_provider = "github-provider"
}
