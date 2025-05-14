terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "vnet" {
  name     = var.vnet_resource_group_name
  location = var.location
}

module "aks_network" {
  source              = "./modules/vnet"
  resource_group_name = azurerm_resource_group.vnet.name
  location            = var.location
  vnet_name           = var.aks_vnet_name
  address_space       = ["10.0.0.0/20"]
  subnets = [
    {
      name : "aks-subnet"
      address_prefixes : ["10.0.0.0/24"]
    }
  ]
}

data "azurerm_kubernetes_service_versions" "current" {
  location       = var.location
  version_prefix = var.kube_version_prefix
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                    = var.cluster_name
  location                = var.location
  kubernetes_version      = data.azurerm_kubernetes_service_versions.current.latest_version
  resource_group_name     = azurerm_resource_group.vnet.name
  dns_prefix              = "aks"
  private_cluster_enabled = false

  default_node_pool {
    name           = "default"
    node_count     = var.nodepool_nodes_count
    vm_size        = var.nodepool_vm_size
    vnet_subnet_id = module.aks_network.subnet_ids["aks-subnet"]
    type           = "VirtualMachineScaleSets"
    zones = ["1", "2", "3"]
    temporary_name_for_rotation = "rotation"
  }

  identity {
    type = "SystemAssigned"
  }

  linux_profile {
    admin_username = var.admin_username
    ssh_key {
      key_data = var.admin_ssh_key
    }
  }

  network_profile {
    network_plugin = "azure"
    service_cidr   = var.network_service_cidr
    dns_service_ip = var.network_dns_service_ip
  }
}
