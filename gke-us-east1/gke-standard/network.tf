resource "google_compute_network" "vpc" {
  name                    = "${local.name}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "primary" {
  name                     = "${local.name}-subnet"
  ip_cidr_range            = local.vpc_cidr
  region                   = local.region
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true
}

