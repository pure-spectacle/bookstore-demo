#! /bin/bash

#
# We can only do so much from Terraform with the initialization of the
# repository. This script will perform some extra setup steps necessary
# to initialize the repository state.
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
  -e DEMO_REPOSITORY_ID="${DEMO_REPOSITORY_ID}" \
  ghcr.io/octodemo/container-ansible-development:base-20210217 \
  ./finalize_create_activities.yml \
  -vvv