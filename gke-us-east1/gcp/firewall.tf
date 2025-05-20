resource "google_compute_firewall" "scylla" {
  name    = "scylla-allow-internal"
  network = google_compute_network.vpc.id

  allow {
    protocol = "tcp"
    ports = [
      "7000",  # Inter-node
      "7001",  # SSL inter-node
      "9042",  # CQL
      "9142",  # SSL CQL
      "9160",  # (Legacy)
      "9180",  # Prometheus
      "9100",  # node_exporter (optional)
      "10000", # REST API
      "19042", # Shard-aware CQL
      "19142"  # Shard-aware CQL (SSL)
    ]
  }

  source_ranges = [google_compute_subnetwork.primary.ip_cidr_range]
  target_tags   = ["scylla"]
}

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

