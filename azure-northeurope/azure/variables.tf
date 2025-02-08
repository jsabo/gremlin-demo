variable "location" {
  description = "The resource group location"
  default     = "northeurope"
}

variable "vnet_resource_group_name" {
  description = "The resource group name to be created"
  default     = "sabodotio-azure-northeurope"
}

variable "admin_username" {
  description = "Admin username"
  default     = "azureuser"
}

variable "admin_ssh_key" {
  description = "Admin SSH public key"
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDthlM95OvXi99yrv4nxlafY0rixCEMFvw0uSnDImc17vfELnmbFZfz6PAFgBLYpnZOvh9M42Yt/5cN7MVPP9rrlOX/PzHz1LnOgb6GbPte2ca75d7RV0QEQn4u/MHPGuhezqSLzMZZm9EKixw43zH7QeG3HHfhup98+NGz8ZrsO9Vykh7yEzTWvk7RospkBoAScli44zAJlS3Hdz+KhwjKQzdNM/Vv/Z8ovF/tM9B2Wr+pQS/mFHnD2w6IgrluYoSMVVDXcAh70BgbtEfJLhobhYxoPDMJTasg0DgW3BJVVBl5L9z+JrYa+Pb/V5hg+Qzjbj3dz06BFpjdE2NSs0YWBWWOKFsrr2l+DX7pAM3+jeqUdoaiKsSzOqXgjM49EMQavmLcD5b5pihPgGrM3iq7nmmnKCN18NsFPXwtcxFKwtflPiUbBZxg68UvQWa0Z0HmrEXojF94QUNE1fo+BUUCB697/KI9v0Ohyuw9HK+c8T1xTg2IH3dhxW/MECwWx6s= sabo@sabos-mbp.lan"
}

variable "aks_vnet_name" {
  description = "VNET name"
  default     = "aks-vnet"
}

variable "cluster_name" {
  description = "AKS cluster name"
  default     = "sabodotio-azure-northeurope"
}

variable "kube_version_prefix" {
  description = "AKS Kubernetes version prefix. Formatted '[Major].[Minor]' like '1.18'. Patch version part (as in '[Major].[Minor].[Patch]') will be set to latest automatically."
  default     = "1.30"
}

variable "nodepool_nodes_count" {
  description = "Default nodepool nodes count"
  default     = 3
}

variable "nodepool_vm_size" {
  description = "Default nodepool VM size"
  default     = "Standard_B2ms"
}

variable "network_dns_service_ip" {
  description = "CNI DNS service IP"
  default     = "10.9.0.10"
}

variable "network_service_cidr" {
  description = "CNI service cidr"
  default     = "10.9.0.0/16"
}
