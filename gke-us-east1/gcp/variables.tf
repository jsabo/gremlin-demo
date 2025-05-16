variable "project" {
  description = "GCP Project ID"
  type        = string
  default     = "gremlin-support"
}

variable "name" {
  description = "Name of the GKE cluster"
  type        = string
  default     = "sabodotio-gke"
}

variable "region" {
  description = "GCP Region for the cluster"
  type        = string
  default     = "us-east1"
}

variable "vpc_cidr" {
  description = "CIDR for the GCP subnet"
  type        = string
  default     = "10.1.0.0/16"
}

variable "cluster_service_ipv4_cidr" {
  description = "GKE cluster secondary CIDR"
  type        = string
  default     = "10.2.0.0/16"
}

variable "instance_type" {
  description = "Machine type for primary GKE nodes"
  type        = string
  default     = "e2-standard-2"
}

variable "tags" {
  description = "Labels to apply to GKE nodes"
  type        = map(string)
  default = {
    Environment = "dev"
    Terraform   = "true"
    Owner       = "Jonathan Sabo"
  }
}

