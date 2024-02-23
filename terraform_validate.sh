#!/bin/bash

# Function to run terraform init and validate in a directory
run_terraform() {
  local dir="$1"
  echo "Running terraform init and validate in $dir"
  cd "$dir" || exit
  terraform init
  terraform validatecd 
  cd - || exit
}

# Main script
main() {
  # Get the current directory
  current_dir=$(pwd)

  # Find all subdirectories containing a main.tf file
  subdirs=$(find "$current_dir" -type f -name "main.tf" -exec dirname {} \;)

  # Run terraform init and validate in each subdirectory
  for dir in $subdirs; do
    run_terraform "$dir"
  done
}

# Run the main script
main
