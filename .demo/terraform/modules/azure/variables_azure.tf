variable "azure_resource_prefix" {
  type        = string
  description = "Prefix for Resources created in Azure"
}

variable "extra_tags" {
  type    = map(string)
  default = {}
}

variable "github_repository" {
  type        = string
  description = "The GitHub repository name the resources are associated with"
}
