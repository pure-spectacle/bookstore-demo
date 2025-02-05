#! /bin/bash

#
# Due to the GitHub repository being able to build and create extra cloud
# resources that Terraform is blind to, we need to remove these before
# a terraform destroy activity can be processed.
#
# Using Ansible here to discover and remove any existing web apps.
#

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

docker run \
  -v $DIR/ansible:/ansible \
  -w /ansible \
  -e WORKFLOW_GITHUB_ACTIONS_TOKEN="${WORKFLOW_GITHUB_ACTIONS_TOKEN}" \
  -e WORKFLOW_GITHUB_DEMO_ORGANIZATION_TOKEN="${WORKFLOW_GITHUB_DEMO_ORGANIZATION_TOKEN}" \
  -e DEMO_PARAMETERS_JSON_BASE64="${DEMO_PARAMETERS_JSON_BASE64}" \
  -e GITHUB_SERVER_URL="${GITHUB_SERVER_URL}" \
  -e GITHUB_API_URL="${GITHUB_API_URL}" \
  -e AZURE_CLIENT_ID="${ARM_CLIENT_ID}" \
  -e AZURE_SECRET="${ARM_CLIENT_SECRET}" \
  -e AZURE_SUBSCRIPTION_ID="${ARM_SUBSCRIPTION_ID}" \
  -e AZURE_TENANT="${ARM_TENANT_ID}" \
  ghcr.io/octodemo/container-ansible-development:base-20220520 \
  ./destroy_azure_apps.yml \
  -vvv
