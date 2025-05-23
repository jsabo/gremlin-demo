resource "google_compute_instance" "scylla" {
  count                     = 3
  name                      = "scylla-node${count.index + 1}"
  machine_type              = "n2-standard-4"
  zone                      = "${var.region}-b"
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "projects/scylla-images/global/images/scylladb-5-2-1"
    }
  }

  scratch_disk {
    interface = "NVME"
  }

  network_interface {
    network    = google_compute_network.vpc.id
    subnetwork = google_compute_subnetwork.primary.id
    access_config {} # Optional: Add external IP. Remove for internal only.
  }

  tags = ["scylla", "db"]

  metadata = {
    # Optional: Provide SSH keys or startup script here
  }

  labels = {
    environment = "dev"
    owner       = "jonathan-sabo"
  }

  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

