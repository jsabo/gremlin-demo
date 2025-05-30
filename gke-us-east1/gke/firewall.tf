resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh-from-your-ip"
  network = google_compute_network.vpc.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # Restrict for best security:
  source_ranges = ["0.0.0.0/0"] # <-- Or your IP block

  target_tags = ["scylla"]
}

