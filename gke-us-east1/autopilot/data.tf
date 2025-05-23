data "google_client_config" "current" {}

data "google_compute_default_service_account" "default" {
  project = var.project
}
