variable "name" {
  description = "Name of cluster"
  type        = string
  default     = "sabodotio-us-east-1"
}

variable "region" {
  description = "AWS Region of cluster"
  type        = string
  default     = "us-east-1"
}

variable "ssh_keyname" {
  description = "AWS SSH Keypair Name"
  type        = string
  default     = "sabo"
}

variable "vpc_cidr" {
  description = "AWS VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "secondary_vpc_cidr" {
  description = "AWS Secondary VPC CIDR"
  type        = string
  default     = "10.99.0.0/16"
}

variable "cluster_service_ipv4_cidr" {
  description = "Kubernetes Service CIDR"
  type        = string
  default     = "10.9.0.0/16"
}

variable "cluster_version" {
  description = "Kubernetes version for this cluster"
  type        = string
  default     = "1.30"
}

variable "calico_version" {
  description = "Calico Open Source release version"
  type        = string
  default     = "3.28.2"
}

variable "desired_size" {
  description = "Number of cluster nodes"
  type        = string
  default     = "4"
}

variable "instance_type" {
  description = "Cluster node AWS EC2 instance type"
  type        = string
  default     = "m5.large"
}

variable "ami_type" {
  description = "Type of Amazon Machine Image (AMI) associated with the EKS Node Group. Valid values are AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64, CUSTOM, BOTTLEROCKET_ARM_64, BOTTLEROCKET_x86_64"
  type        = string
  default     = "AL2_x86_64"
}

variable "tags" {
  description = "Tags to apply to the resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Terraform   = "true"
    Owner       = "Jonathan Sabo"
  }
}
