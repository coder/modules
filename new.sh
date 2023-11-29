#!/usr/bin/env bash

# This scripts creates a new sample moduledir with requried files
# Run it like : ./new.sh my-module

MODULE_NAME=$1

# Check if module name is provided
if [ -z "$MODULE_NAME" ]; then
  echo "Usage: ./new.sh <module_name>"
  exit 1
fi

# Create module directory and exit if it alredy exists
if [ -d "$MODULE_NAME" ]; then
  echo "Module with name $MODULE_NAME already exists"
  echo "Please choose a different name"
  exit 1
fi
mkdir -p "${MODULE_NAME}"

# Copy required files from the sample module
cp -r .sample/* "${MODULE_NAME}"

# Change to module directory
cd "${MODULE_NAME}" || echo "Failed to change directory to ${MODULE_NAME}" && exit 1

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
  sed -i '' "s/MODULE_NAME/${MODULE_NAME}/g" main.tf
  sed -i '' "s/MODULE_NAME/${MODULE_NAME}/g" README.md
else
  # Linux
  sed -i "s/MODULE_NAME/${MODULE_NAME}/g" main.tf
  sed -i "s/MODULE_NAME/${MODULE_NAME}/g" README.md
fi

# Make run.sh executable
chmod +x run.sh
