#variable "create_aks" {
# type    = bool
#  default = true
#}

#resource "azurerm_resource_group" "rg" {
#  name     = var.resource_group_name
#  location = var.location
#}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}
data "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.acr_resource_group_name
}

data "azurerm_kubernetes_cluster" "existing_aks" {
  count               = var.create_aks ? 0 : 1
  name                = var.aks_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_kubernetes_cluster" "aks" {
  count               = var.create_aks ? 1 : 0
  name                = var.aks_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  dns_prefix          = var.aks_dns_prefix

  oidc_issuer_enabled       = true
  workload_identity_enabled = true


  default_node_pool {
    name                = "sysnp"
    vm_size             = "Standard_D2ps_v6"
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 1
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }

  tags = {
    environment = "dev"
  }
  lifecycle {
    ignore_changes = [
      oidc_issuer_enabled,
      workload_identity_enabled,
      default_node_pool[0].node_count
    ]
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "userpool" {
  count                 = var.create_aks ? 1 : 0
  name                  = "usernp01"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks[0].id
  vm_size               = "Standard_D2ps_v6"
  mode                  = "User"

  enable_auto_scaling = true
  min_count           = 1
  max_count           = 1

  orchestrator_version = azurerm_kubernetes_cluster.aks[0].kubernetes_version
}

locals {
  kubelet_object_id = (
    var.create_aks
    ? azurerm_kubernetes_cluster.aks[0].kubelet_identity[0].object_id
    : data.azurerm_kubernetes_cluster.existing_aks[0].kubelet_identity[0].object_id
  )

  aks_host = (
    var.create_aks
    ? azurerm_kubernetes_cluster.aks[0].kube_config[0].host
    : data.azurerm_kubernetes_cluster.existing_aks[0].kube_config[0].host
  )

  aks_client_certificate = (
    var.create_aks
    ? azurerm_kubernetes_cluster.aks[0].kube_config[0].client_certificate
    : data.azurerm_kubernetes_cluster.existing_aks[0].kube_config[0].client_certificate
  )

  aks_client_key = (
    var.create_aks
    ? azurerm_kubernetes_cluster.aks[0].kube_config[0].client_key
    : data.azurerm_kubernetes_cluster.existing_aks[0].kube_config[0].client_key
  )

  aks_cluster_ca_certificate = (
    var.create_aks
    ? azurerm_kubernetes_cluster.aks[0].kube_config[0].cluster_ca_certificate
    : data.azurerm_kubernetes_cluster.existing_aks[0].kube_config[0].cluster_ca_certificate
  )
}

/*
resource "azurerm_role_assignment" "acr_pull" {
  principal_id         = local.kubelet_object_id
  role_definition_name = "AcrPull"
  scope                = data.azurerm_container_registry.acr.id
}
*/

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }

  depends_on = [
    azurerm_kubernetes_cluster.aks,
    azurerm_role_assignment.acr_pull
  ]
}

resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  create_namespace = false

  values = [
    file("${path.module}/argocd-values.yaml")
  ]

  depends_on = [
    kubernetes_namespace.argocd
  ]
}