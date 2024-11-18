#!/usr/bin/env bash
set -o pipefail
set -u

# List of required environment variables
required_vars=(
    "INSTATUS_API_KEY"
    "INSTATUS_PAGE_ID"
    "INSTATUS_COMPONENT_ID"
)

# Check if each required variable is set
for var in "${required_vars[@]}"; do
    if [[ -z "${!var:-}" ]]; then
        echo "Error: Environment variable '$var' is not set."
        exit 1
    fi
done

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
fi

exit "${status}"
