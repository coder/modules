#!/bin/bash

# Function to fetch AWS zones based on regions in `gcp_regions` variable in Terraform
fetch_aws_zones() {
  for region in $(awk -F\" '/var\.aws_regions/{flag=1; next} flag && /],/{flag=0} flag' your_terraform_file.tf); do
    aws ec2 describe-availability-zones --region "$region" --query 'AvailabilityZones[].ZoneName' --output text | tr '\t' '\n' | while read -r zone; do
      location="AWS $region"  # Adjust this as needed
      icon="/emojis/1f1fa-1f1f8.png"  # Adjust this as needed

      # Format the Terraform entry for this zone
      echo "    { zone = \"${zone}\", location = \"${location}\", icon = \"${icon}\" },"
    done
  done
}

# Temporary file to store the updated Terraform content
temp_file=$(mktemp)

# Print everything before the AWS zones list
awk '/locals {/,/aws_zones = \[/{print; exit}' your_terraform_file.tf > "$temp_file"

# Fetch and format the AWS zones, appending them to the temporary file
echo "  aws_zones = [" >> "$temp_file"
fetch_aws_zones >> "$temp_file"
echo "  ]" >> "$temp_file"

# Print everything after the AWS zones list
awk '/\],/{flag=1; next} flag' your_terraform_file.tf >> "$temp_file"

# Replace the original Terraform file with the updated one
mv "$temp_file" your_terraform_file.tf

# Clean up
rm -f "$temp_file"
