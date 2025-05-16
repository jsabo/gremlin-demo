locals {
  # mirror var.name/region
  name   = var.name
  region = var.region

  # for GKE labels: lowercase key + hyphens in values
  sanitized_labels = {
    for k, v in var.tags :
    lower(k) => replace(lower(v), " ", "-")
  }
}
