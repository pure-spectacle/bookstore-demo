terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.110.0"
    }
  }
}

locals {
  # Initialize the context filling in any missing value with defaults
  azure_context = merge(coalesce({}), {
    location = "UK West"
    service_plan = {
        sku_name = "B1"
    }
  })

  azure_tags = merge(
    {
      repository = var.github_repository
    },
    coalesce(var.extra_tags, {})
  )
}


provider "azurerm" {
  # Injection is required via the ARM_xxx environment variables

  features {
    # Allow the resource group to be deleted with things in it outside of this terraform
    # This allows us to deploy apps and other things to it via Actions
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}


resource "azurerm_resource_group" "demo" {
  name      = "${var.azure_resource_prefix}--bookstore-demo"
  location  = local.azure_context.location
  tags      = local.azure_tags
}

resource "random_id" "plan_name" {
  keepers = {
    resource_group_name = azurerm_resource_group.demo.name
  }
  byte_length = 16
}

resource "azurerm_service_plan" "demo" {
  name                = "plan-${random_id.plan_name.hex}"
  resource_group_name = azurerm_resource_group.demo.name
  location            = azurerm_resource_group.demo.location
  os_type             = "Linux"
  sku_name            = local.azure_context.service_plan.sku_name
}


output "resource_group_name" {
  value = azurerm_resource_group.demo.name
}

output "service_plan_name" {
  value = azurerm_service_plan.demo.name
}
