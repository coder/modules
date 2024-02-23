#!/bin/bash

set -euo pipefail

# Function to run terraform init and validate in a directory
run_terraform() {
    local dir="$1"
    echo "Running terraform init and validate in $dir"
    pushd "$dir"
    terraform init -upgrade
    terraform validate
    popd
}

# Main script
main() {
    # Get the directory of the script
    script_dir=$(dirname "$(readlink -f "$0")")

    # Get all subdirectories in the repository
    subdirs=$(find "$script_dir" -mindepth 1 -maxdepth 1 -type d -not -name ".*" | sort)

    for dir in $subdirs; do
        run_terraform "$dir"
    done
}

# Run the main script
main
