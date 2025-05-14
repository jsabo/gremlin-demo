resource "google_container_cluster" "primary" {
  name     = local.name
  location = local.region

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc.id
  subnetwork = google_compute_subnetwork.primary.id

  ip_allocation_policy {
    cluster_ipv4_cidr_block = local.cluster_service_ipv4_cidr
  }

  deletion_protection = false
}

resource "google_container_node_pool" "primary_nodes" {
  name     = "primary-node-pool"
  cluster  = google_container_cluster.primary.id
  location = local.region

  node_config {
    machine_type = local.instance_type
    disk_size_gb = 100
    disk_type    = "pd-balanced"

    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
    tags         = ["gke-node", local.name]
    labels       = local.sanitized_labels
  }

  initial_node_count = 1

  autoscaling {
    min_node_count = 1
    max_node_count = 3
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}

resource "google_container_node_pool" "scylla_nodes" {
  name     = "scylla-cluster-pool"
  cluster  = google_container_cluster.primary.id
  location = local.region

  node_config {
    machine_type    = "n2-standard-4"
    disk_size_gb    = 100
    disk_type       = "pd-ssd"
    image_type      = "UBUNTU_CONTAINERD"
    local_ssd_count = 1 # Local NVMe SSDs for ScyllaDB
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
    tags            = ["gke-node", local.name, "scylla"]
    labels = {
      "scylla.scylladb.com/node-type" = "scylla"
    }

    kubelet_config {
      cpu_manager_policy = "static"
    }

    taint {
      key    = "scylla-operator.scylladb.com/dedicated"
      value  = "scyllaclusters"
      effect = "NO_SCHEDULE"
    }
  }

  initial_node_count = 1

  autoscaling {
    min_node_count = 1
    max_node_count = 3
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}


resource "google_container_node_pool" "rabbitmq_pool" {
  name     = "rabbitmq-pool"
  cluster  = google_container_cluster.primary.id
  location = local.region

  node_config {
    machine_type = "n2-standard-4" # (4 vCPU / 26 GiB RAM)
    disk_size_gb = 375             # attach PD‑SSD or use local_ssd_count
    disk_type    = "pd-ssd"
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
    tags         = ["gke-node", local.name, "rabbitmq"]
    labels = {
      "rabbitmq.com/node-type" = "rabbitmq"
    }

    taint {
      key    = "rabbitmq.com/node-type"
      value  = "rabbitmq"
      effect = "NO_SCHEDULE"
    }
  }

  initial_node_count = 1

  autoscaling {
    min_node_count = 1
    max_node_count = 3
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}
