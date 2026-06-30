variable "location" {
  description = "Azure region"
  type        = string
  default     = "centralus"
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
  default     = "lab2026"
}

variable "aks_name" {
  description = "AKS cluster name"
  type        = string
  default     = "ai-workload"
}

variable "aks_dns_prefix" {
  description = "AKS DNS prefix"
  type        = string
  default     = "aksgithub"
}

variable "create_aks" {
  description = "Create new AKS cluster or use existing AKS cluster"
  type        = bool
  default     = true
}