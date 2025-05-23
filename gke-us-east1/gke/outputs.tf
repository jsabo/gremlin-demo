output "configure_kubectl" {
  description = "Configure kubectl: ensure gcloud CLI is installed and run this command"
  value       = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --region ${local.region} --project ${var.project}"
}

output "scylla_internal_dns" {
  description = "Internal zonal DNS for Scylla VMs"
  value = [
    for i in google_compute_instance.scylla :
    "${i.name}.${i.zone}.c.${var.project}.internal"
  ]
}

output "scylla_external_ips" {
  description = "External IP addresses for Scylla VMs"
  value = [
    for i in google_compute_instance.scylla :
    i.network_interface[0].access_config[0].nat_ip
  ]
}

output "scylla_ssh_hostnames" {
  description = "Hostnames for SSH (external IP form)"
  value = [
    for i in google_compute_instance.scylla :
    "${i.network_interface[0].access_config[0].nat_ip}.bc.googleusercontent.com"
  ]
}
