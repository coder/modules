#!/usr/bin/env bash
set -o pipefail
set -u

# List of required environment variables
required_vars=(
    "INSTATUS_API_KEY"
    "INSTATUS_PAGE_ID"
    "INSTATUS_COMPONENT_ID"
    "VERCEL_API_KEY"
)

# Check if each required variable is set
for var in "${required_vars[@]}"; do
    if [[ -z "${!var:-}" ]]; then
        echo "Error: Environment variable '$var' is not set."
        exit 1
    fi
done

LATEST_REDEPLOY_FAILED="$LATEST_REDEPLOY_FAILED:-0"
if (LATEST_REDEPLOY_FAILED); do
    echo "Trying to re-run job when previous re-deploy failed"
    return 1
fi

REGISTRY_BASE_URL="${REGISTRY_BASE_URL:-https://registry.coder.com}"

status=0
declare -a modules=()
declare -a failures=()

# Collect all module directories containing a main.tf file
for path in $(find . -not -path '*/.*' -type f -name main.tf -maxdepth 2 | cut -d '/' -f 2 | sort -u); do
    modules+=("${path}")
done

echo "Checking modules: ${modules[*]}"

# Function to update the component status on Instatus
update_component_status() {
    local component_status=$1
    # see https://instatus.com/help/api/components
    (curl -X PUT "https://api.instatus.com/v1/$INSTATUS_PAGE_ID/components/$INSTATUS_COMPONENT_ID" \
        -H "Authorization: Bearer $INSTATUS_API_KEY" \
        -H "Content-Type: application/json" \
        -d "{\"status\": \"$component_status\"}")
}

# Function to create an incident
create_incident() {
    local incident_name="Testing Instatus"
    local message="The following modules are experiencing issues:\n"
    for i in "${!failures[@]}"; do
        message+="$(($i + 1)). ${failures[$i]}\n"
    done

    component_status="PARTIALOUTAGE"
    if (( ${#failures[@]} == ${#modules[@]} )); then
        component_status="MAJOROUTAGE"
    fi
    # see https://instatus.com/help/api/incidents
    response=$(curl -s -X POST "https://api.instatus.com/v1/$INSTATUS_PAGE_ID/incidents" \
        -H "Authorization: Bearer $INSTATUS_API_KEY" \
        -H "Content-Type: application/json" \
        -d "{
            \"name\": \"$incident_name\",
            \"message\": \"$message\",
            \"components\": [\"$INSTATUS_COMPONENT_ID\"],
            \"status\": \"INVESTIGATING\",
            \"notify\": true,
            \"statuses\": [
                {
                    \"id\": \"$INSTATUS_COMPONENT_ID\",
                    \"status\": \"PARTIALOUTAGE\"
                }
            ]
        }")

    incident_id=$(echo "$response" | jq -r '.id')
    echo "$incident_id"
}

force_redeploy_registry () {
    # These are not secret values; safe to just expose directly in script
    local VERCEL_TEAM_SLUG="codercom"
    local VERCEL_TEAM_ID="team_tGkWfhEGGelkkqUUm9nXq17r"
    local VERCEL_APP="registry"

    local latest_res=$(curl "https://api.vercel.com/v6/deployments?app=$VERCEL_APP&limit=1&slug=$VERCEL_TEAM_SLUG&teamId=$VERCEL_TEAM_ID" \
        --fail \
        --silent \
        -H "Authorization: Bearer $VERCEL_API_KEY" \
        -H "Content-Type: application/json"
    )

    # If we have zero deployments, something is VERY wrong. Make the whole
    # script exit with a non-zero status code
    local latest_id=$(echo $latest_res | jq '.deployments[0].uid')
    if (( latest_id == "null" )); do
        echo "Unable to pull any previous deployments for redeployment" 
        return 1
    fi

    local redeploy_res=$(curl -X POST "https://api.vercel.com/v13/deployments?forceNew=1&skipAutoDetectionConfirmation=1&slug=$VERCEL_TEAM_SLUG&teamId=$VERCEL_TEAM_ID" \
        --fail \
        --silent \
        --output "/dev/null" \
        -H "Authorization: Bearer $VERCEL_API_KEY" \
        -H "Content-Type: application/json" \
        -d "{
            "deploymentId": $latest_id,
        }"
    )

    echo $redeploy_res
}

# Check each module's accessibility
for module in "${modules[@]}"; do
    # Trim leading/trailing whitespace from module name
    module=$(echo "${module}" | xargs)
    url="${REGISTRY_BASE_URL}/modules/${module}"
    printf "=== Checking module %s at %s\n" "${module}" "${url}"
    status_code=$(curl --output /dev/null --head --silent --fail --location "${url}" --retry 3 --write-out "%{http_code}")
    # shellcheck disable=SC2181
    if (( status_code != 200 )); then
        printf "==> FAIL(%s)\n" "${status_code}"
        status=1
        failures+=("${module}")
    else
        printf "==> OK(%s)\n" "${status_code}"
    fi
done

# Determine overall status and update Instatus component
if (( status == 0 )); then
    echo "All modules are operational."
    # set to 
    update_component_status "OPERATIONAL"

    echo "LATEST_REDEPLOY_FAILED=0" >> $GITHUB_ENV
else
    echo "The following modules have issues: ${failures[*]}"
    # check if all modules are down 
    if (( ${#failures[@]} == ${#modules[@]} )); then
        update_component_status "MAJOROUTAGE"
    else
        update_component_status "PARTIALOUTAGE"
    fi

    # Create a new incident
    incident_id=$(create_incident)
    echo "Created incident with ID: $incident_id"
    
    # If a module is down, force a reployment to try getting things back online
    # ASAP
    status_code=$(force_redeploy_registry)
    # shellcheck disable=SC2181
    if (( status_code == 200 )); then
        echo "Reployment successful"
    else
        echo "Unable to redeploy automatically"
    fi

    # Update environment variable so that if automatic re-deployment fails, we
    # don't keep running the script over and over again. Note that even if a
    # re-deployment succeeds, that doesn't necessarily mean that everything is
    # fully operational
    echo "LATEST_REDEPLOY_FAILED=1" >> $GITHUB_ENV
fi

exit "${status}"
