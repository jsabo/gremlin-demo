output "get_wordpress_creds" {
  description = "Decode wordpress user creds from wordpress secrets created on firstboot"
  value       = "Run command: kubectl get secret --namespace <NAMESPACE>  wordpress -o jsonpath='{.data.wordpress-password}' | base64 -d"
}
