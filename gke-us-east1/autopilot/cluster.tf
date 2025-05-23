resource "google_container_cluster" "primary" {
  name     = local.name
  location = local.region

  enable_autopilot = true

  network    = google_compute_network.vpc.id
  subnetwork = google_compute_subnetwork.primary.id

  ip_allocation_policy {
    cluster_ipv4_cidr_block = var.cluster_service_ipv4_cidr
  }

  deletion_protection = false

}

