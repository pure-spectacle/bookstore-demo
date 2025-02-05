terraform {
  # required_version = ">=1.7"
}

#
# backend is dynamically generated and injected by terragrunt
#

locals {
  decoded_demo_config      = jsondecode(var.demo_config)
  decoded_demo_definition  = jsondecode(var.demo_definition)
  github_instance_prefix   = var.github_instance_tenant_name != "" ? "${var.github_instance_type}-${var.github_instance_tenant_name}" : var.github_instance_type
  github_repository_string = "${var.github_repository.owner}--${var.github_repository.repo}"
}


module "azure" {
  source = "../modules/azure"

  azure_resource_prefix = "${local.github_instance_prefix}--${local.github_repository_string}"
  github_repository     = local.github_repository_string
  extra_tags            = lookup(local.decoded_demo_config, "azure_tags", null)
}


module "github" {
  source = "../modules/github"

  github_token      = var.github_token
  actor             = var.requestor_handle
  target_repository = var.github_repository

  create_project = lookup(local.decoded_demo_config, "create_project", false)

  azure = {
    service_plan_name   = module.azure.service_plan_name
    resource_group_name = module.azure.resource_group_name
  }
}
