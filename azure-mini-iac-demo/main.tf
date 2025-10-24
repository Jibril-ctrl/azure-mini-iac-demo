################################################################
# Mini Enterprise Infrastructure on Azure using Terraform
# Purpose:
#   - Demonstrate real DevOps/Sec IaC: Network + Secure Storage
#   - Foundation for future workloads or SIEM/log pipelines
# Cost:
#   - 100% free (no compute, no public services)
# Author: Jibril Anifowoshe
###############################################################

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "YOUR_SUBSCRIPTION_ID"  # GUID (not the human-readable name)
  tenant_id       = "YOUR_TENANT_ID"        # Directory (AAD) GUID
}

# -------- Variables --------
variable "location" {
  description = "Azure region for all resources"
  default     = "eastus"
}

variable "project" {
  description = "Short name to tag and prefix resources"
  default     = "mini-iac-azure-demo"
}

# Unique suffix for global storage account name
locals {
  sa_name_prefix       = lower(replace(var.project, "-", ""))
  sa_name_prefix_short = substr(local.sa_name_prefix, 0, 14)
}

resource "random_string" "suffix" {
  length  = 6
  lower   = true
  upper   = false
  numeric = true
  special = false
}

# =====================================
# NETWORK LAYER (Enterprise foundation)
# =====================================

resource "azurerm_resource_group" "rg" {
  name     = "${var.project}-rg"
  location = var.location
  tags = { project = var.project, env = "demo", cost = "free" }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.project}-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.10.0.0/16"]
  tags = { project = var.project, tier = "network" }
}

resource "azurerm_subnet" "subnet" {
  name                 = "app-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.project}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # Allow SSH and HTTP (for future workloads)
  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-http"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = { project = var.project, tier = "network" }
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# ==========================================
# STORAGE LAYER (for SIEM/logs or artifacts)
# ==========================================

resource "azurerm_storage_account" "sa" {
  name                              = "st${local.sa_name_prefix_short}${random_string.suffix.result}"
  resource_group_name               = azurerm_resource_group.rg.name
  location                          = azurerm_resource_group.rg.location
  account_tier                      = "Standard"
  account_replication_type          = "LRS"
  # allow_blob_public_access          = false
  min_tls_version                   = "TLS1_2"
  shared_access_key_enabled         = true

  blob_properties { versioning_enabled = true }

  tags = {
    project = var.project
    tier    = "storage"
    purpose = "siem-logs-or-artifacts"
  }
}

resource "azurerm_storage_container" "container" {
  name                  = "logs"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}

resource "azurerm_storage_management_policy" "cleanup" {
  storage_account_id = azurerm_storage_account.sa.id
  rule {
    name    = "cleanup-old-logs"
    enabled = true
    filters {
      blob_types  = ["blockBlob"]
      prefix_match = ["logs/"]
    }
    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = 30
      }
    }
  }
}

# ====================
# Outputs
# ====================

output "resource_group_name" {
  description = "Resource Group created by this demo"
  value       = azurerm_resource_group.rg.name
}

output "vnet_name" {
  description = "Virtual Network name"
  value       = azurerm_virtual_network.vnet.name
}

output "subnet_name" {
  description = "Subnet name"
  value       = azurerm_subnet.subnet.name
}

output "storage_account_name" {
  description = "Private Storage Account for SIEM/logs or artifacts"
  value       = azurerm_storage_account.sa.name
}

output "blob_container_name" {
  description = "Blob container for logs or artifacts"
  value       = azurerm_storage_container.container.name
}

output "blob_endpoint" {
  description = "Primary Blob service endpoint (private; requires auth)"
  value       = azurerm_storage_account.sa.primary_blob_endpoint
}