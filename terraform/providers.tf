terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "kubernetes" {
  host                   = local.aks_host
  client_certificate     = base64decode(local.aks_client_certificate)
  client_key             = base64decode(local.aks_client_key)
  cluster_ca_certificate = base64decode(local.aks_cluster_ca_certificate)
}

provider "helm" {
  kubernetes = {
    host                   = local.aks_host
    client_certificate     = base64decode(local.aks_client_certificate)
    client_key             = base64decode(local.aks_client_key)
    cluster_ca_certificate = base64decode(local.aks_cluster_ca_certificate)
  }
}