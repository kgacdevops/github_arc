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
    impersonate_service_account = "gh-gcp-runner-sa@project-235e2136-7c2e-4409-bad.iam.gserviceaccount.com"
}
