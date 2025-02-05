terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "6.2.2"
    }
  }
}


provider "github" {
  token = var.github_token
  owner = var.target_repository.owner
}


# Lookup the github repository that should have been created before this module run is called
data "github_repository" "repository" {
  full_name = "${var.target_repository.owner}/${var.target_repository.repo}"
}


# Set up any additonal GHAS security settings... Terraform does not seem to have a data resource for this


resource "github_team" "repository_admins" {
  name                      = "${data.github_repository.repository.name}-admins"
  description               = "Admins for the ${data.github_repository.repository.name} repository"
  create_default_maintainer = true
}

resource "github_team_repository" "repository_admins" {
  team_id = github_team.repository_admins.id
  repository = data.github_repository.repository.name
  permission = "admin"
}

resource "github_team_membership" "actor_repository_admin" {
  team_id = github_team.repository_admins.id
  username = var.actor
  role = "maintainer"
}

resource "github_issue_label" "deploy_to_qa" {
  repository  = data.github_repository.repository.name
  name        = "deploy to qa"
  description = "Trigger a deploy event targeting the qa environment"
  color       = "5755f2"
}

resource "github_issue_label" "deploy_to_staging" {
  repository  = data.github_repository.repository.name
  name        = "deploy to staging"
  description = "Trigger a deploy event targeting the staging environment"
  color       = "1dad00"
}

resource "github_issue_label" "deploy_to_test" {
  repository  = data.github_repository.repository.name
  name        = "deploy to test"
  description = "Trigger a deploy event targeting the test environment"
  color       = "7d5c01"
}

resource "github_actions_secret" "azure_app_plan" {
  repository      = data.github_repository.repository.name
  secret_name     = "AZURE_APP_PLAN_NAME"
  plaintext_value = var.azure.service_plan_name
}

resource "github_actions_secret" "azure_resource_group" {
  repository      = data.github_repository.repository.name
  secret_name     = "AZURE_RESOURCE_GROUP_NAME"
  plaintext_value = var.azure.resource_group_name
}

resource "github_branch_protection" "protect_default_branch" {
  repository_id  = data.github_repository.repository.name
  pattern        = "main"
  enforce_admins = false

  required_status_checks {
    strict = false
    # The following is tied into the workflow actions for the builds in the base template repository
    contexts = ["Build java 11 on ubuntu-20.04"]
  }
  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    required_approving_review_count = 1
  }
}
