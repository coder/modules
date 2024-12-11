#!/usr/bin/env bash
set -o pipefail
set -u

VERBOSE="${VERBOSE:-0}"
if [[ "${VERBOSE}" -ne "0" ]]; then
    set -x
fi

# List of required environment variables
required_vars=(
    "GCLOUD_API_KEY"
    "GCLOUD_PROD_DEPLOY_SECRET"
    "GCLOUD_DEV_DEPLOY_SECRET"
)

# Check if each required variable is set
for var in "${required_vars[@]}"; do
    if [[ -z "${!var:-}" ]]; then
        echo "Error: Environment variable '$var' is not set."
        exit 1
    fi
done

# Trigger a build for dev 
curl -X POST "https://cloudbuild.googleapis.com/v1/projects/coder-registry-1/triggers/http-build-registry-v2-dev:webhook?key=${GCLOUD_API_KEY}&secret=${GCLOUD_DEV_DEPLOY_SECRET}" \
-H "Content-Type: application/json" \
-d '{}'

# Trigger a build for prod
curl -X POST "https://cloudbuild.googleapis.com/v1/projects/coder-registry-1/triggers/http-build-registry-v2-trigger:webhook?key=${GCLOUD_API_KEY}&secret=${GCLOUD_PROD_DEPLOY_SECRET}" \
-H "Content-Type: application/json" \
-d '{}'

# Testing now with the secrets set to nonsense strings to make sure they're never logged by the github action.