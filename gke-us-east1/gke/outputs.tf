output "configure_kubectl" {
  description = "Configure kubectl: ensure gcloud CLI is installed and run this command"
  value       = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --region ${local.region} --project ${var.project}"
}
