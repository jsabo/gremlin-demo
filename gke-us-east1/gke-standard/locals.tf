locals {
  name                      = var.name
  region                    = var.region
  vpc_cidr                  = var.vpc_cidr
  cluster_service_ipv4_cidr = var.cluster_service_ipv4_cidr
  desired_size              = var.desired_size
  instance_type             = var.instance_type
  tags                      = var.tags

  # Convert keys to lowercase and replace spaces in values with hyphens for valid GCP label format
  sanitized_labels = { for k, v in var.tags : lower(k) => replace(lower(v), " ", "-") }
}

