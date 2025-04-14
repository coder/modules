#!/usr/bin/env bash
#
# update-version.sh - Updates or checks README.md version
#
# This script is used for two main purposes:
# 1. Update the version in a module's README.md file (normal mode)
# 2. Check if the version in README.md matches a specified version (--check mode)
#
# It's primarily used by the GitHub Actions workflow that runs when tags are pushed.

set -euo pipefail

# Check if we're in check-only mode
CHECK_ONLY=false
if [[ "$1" == "--check" ]]; then
  CHECK_ONLY=true
  shift
fi

# Validate we have the right number of arguments
if [[ "$#" -ne 2 ]]; then
  echo "Usage: ./update-version.sh [--check] module-name X.Y.Z"
  exit 1
fi

MODULE_NAME="$1"
VERSION="$2"

# Validate version format (X.Y.Z)
if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Error: Version must be in format X.Y.Z"
  exit 1
fi

# Check if module directory exists
if [[ ! -d "$MODULE_NAME" || ! -f "$MODULE_NAME/README.md" ]]; then
  echo "Error: Module directory not found or missing README.md"
  exit 1
fi

# Extract version from README.md file
extract_version() {
  # This finds version lines like: version = "1.2.3"
  grep -o 'version *= *"[0-9]\+\.[0-9]\+\.[0-9]\+"' "$1" | head -1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' || echo "0.0.0"
}

# Update version in README.md file
update_version() {
  local tmpfile=$(mktemp)
  # This awk script finds and updates version lines in code blocks
  # It's careful to only update version lines in the right context (not in nested blocks)
  awk -v tag="$2" '
    BEGIN { in_code_block = 0; in_nested_block = 0 }
    {
      # Track code blocks (```...```)
      if ($0 ~ /^```/) {
        in_code_block = !in_code_block
        if (!in_code_block) { in_nested_block = 0 }
      }
      
      # Inside code blocks, track nested {} blocks
      if (in_code_block) {
        if ($0 ~ /{/ && !($1 == "module" || $1 ~ /^[a-zA-Z0-9_]+$/)) {
          in_nested_block++
        }
        if ($0 ~ /}/ && in_nested_block > 0) {
          in_nested_block--
        }
        
        # Only update version if not in a nested block
        if (!in_nested_block && $1 == "version" && $2 == "=") {
          sub(/"[^"]*"/, "\"" tag "\"")
        }
      }
      print
    }
  ' "$1" > "$tmpfile" && mv "$tmpfile" "$1"
}

README_PATH="$MODULE_NAME/README.md"
README_VERSION=$(extract_version "$README_PATH")

# In check mode, just return success/failure based on version match
if [[ "$CHECK_ONLY" == "true" ]]; then
  if [[ "$README_VERSION" == "$VERSION" ]]; then
    # Success: versions match
    exit 0
  else
    # Failure: versions don't match
    exit 1
  fi
fi

# Update the version if needed
if [[ "$README_VERSION" != "$VERSION" ]]; then
  update_version "$README_PATH" "$VERSION"
fi

exit 0