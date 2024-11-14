#!/usr/bin/env bash
set -o pipefail
REGISTRY_BASE_URL="${REGISTRY_BASE_URL:-https://registry.coder.com}"
set -u

if [[ -n "${VERBOSE:-}" ]]; then
    set -x
fi

status=0
declare -a modules=()
declare -a failures=()
modules+=("doesnotexist")
for path in $(find . -not -path '*/.*' -type f -name main.tf -maxdepth 2 | cut -d '/' -f 2 | sort -u); do
    modules+=("${path}")
done
echo "Checking modules: ${modules[*]}"
for module in "${modules[@]}"; do
    # Trim leading/trailing whitespace from module name
    module=$(echo "${module}" | xargs)
    url="${REGISTRY_BASE_URL}/modules/${module}"
    printf "=== Check module %s at %s\n" "${module}" "${url}"
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

if (( status != 0 )); then
    echo "The following modules appear to have issues: ${failures[*]}"
fi
exit "${status}"
