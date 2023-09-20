#!/bin/bash

declare -A zone_to_location=(
  ["us-central1"]="Council Bluffs, Iowa, USA"
  ["us-east1"]="Moncks Corner, S. Carolina, USA"
)

declare -A zone_to_emoji=(
  ["us-central1"]="/emojis/1f1fa-1f1f8.png"
  ["us-east1"]="/emojis/1f1fa-1f1f8.png"
  # ... Add other mappings here
)

# Function to check if a zone has a GPU
has_gpu() {
  local zone=$1
  gcloud compute machine-types list --filter="zone:($zone) AND guestCpus:>=0" --format="csv[no-heading](name)" | grep -q "gpu"
}

# Function to fetch zones from GCP and format them for Terraform
fetch_zones() {
  gcloud compute zones list --format="csv[no-heading](name,region)" | while IFS=',' read -r zone region; do
    # Check if the zone has a GPU
    gpu_status=false
    if has_gpu "$zone"; then
      gpu_status=true
    fi

    # Fetch location and emoji from the mapping
    location=${zone_to_location[${zone%-*}]:-"TODO: Add Location"}
    emoji=${zone_to_emoji[${zone%-*}]:-"/emojis/TODO: Add Emoji"}

    # Format the Terraform entry for this zone
    echo "    { zone = \"${zone}\", has_gpu = ${gpu_status}, location = \"${location}\", icon = \"${emoji}\" },"
  done
}

# Temporary file to store the updated Terraform content
temp_file=$(mktemp)

# Print everything before the zone list
awk '/locals {/,/all_zones = \[/{print; exit}' your_terraform_file.tf > "$temp_file"

# Fetch and format the zones, appending them to the temporary file
echo "  all_zones = [" >> "$temp_file"
fetch_zones >> "$temp_file"
echo "  ]" >> "$temp_file"

# Print everything after the zone list
awk '/\],/{flag=1; next} flag' your_terraform_file.tf >> "$temp_file"

# Replace the original Terraform file with the updated one
mv "$temp_file" your_terraform_file.tf

# Clean up
rm -f "$temp_file"
