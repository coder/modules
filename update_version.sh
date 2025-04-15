#!/usr/bin/env bash
#
# update-version.sh - Updates or checks README.md version in module documentation

set -eo pipefail

# Display help message
show_help() {
  echo "Usage: ./update-version.sh [--check|--help] MODULE_NAME VERSION"
  echo
  echo "Options:"
  echo "  --check     Check if README.md version matches VERSION without updating"
  echo "  --help      Display this help message and exit"
  echo
  echo "Examples:"
  echo "  ./update-version.sh code-server 1.2.3        # Update version in code-server/README.md"
  echo "  ./update-version.sh --check code-server 1.2.3 # Check if version matches 1.2.3"
  echo
}

# Handle help request
if [[ $# -eq 0 || "$1" == "--help" ]]; then
  show_help
  exit 0
fi

# Check if we're in check-only mode
CHECK_ONLY=false
if [[ "$1" == "--check" ]]; then
  CHECK_ONLY=true
  shift
fi

# Validate we have the right number of arguments
if [[ "$#" -ne 2 ]]; then
  echo "Error: Incorrect number of arguments"
  echo "Expected exactly 2 arguments (MODULE_NAME VERSION)"
  echo
  show_help
  exit 1
fi

MODULE_NAME="$1"
VERSION="$2"

# Validate version format (X.Y.Z)
if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Error: Version must be in format X.Y.Z (e.g., 1.2.3)"
  exit 1
fi

# Check if module directory exists
if [[ ! -d "$MODULE_NAME" ]]; then
  echo "Error: Module directory '$MODULE_NAME' not found"
  echo "Available modules:"
  find . -type d -mindepth 1 -maxdepth 1 -not -path "*/\.*" | sed 's|^./||' | sort
  exit 1
fi

# Check if README.md exists
if [[ ! -f "$MODULE_NAME/README.md" ]]; then
  echo "Error: README.md not found in '$MODULE_NAME' directory"
  exit 1
fi

# Extract version from README.md file
extract_version() {
  grep -o 'version *= *"[0-9]\+\.[0-9]\+\.[0-9]\+"' "$1" | head -1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' || echo "0.0.0"
}

# Update version in README.md file
update_version() {
  local file="$1" latest_tag=$2 tmpfile
  tmpfile=$(mktemp)
  echo "Updating version in $file from $(extract_version "$file") to $latest_tag..."

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
    echo "✅ Success: Version in $README_PATH matches $VERSION"
    exit 0
  else
    echo "❌ Error: Version mismatch in $README_PATH"
    echo "Expected: $VERSION"
    echo "Found: $README_VERSION"
    exit 1
  fi
fi

# Update the version if needed
if [[ "$README_VERSION" != "$VERSION" ]]; then
  update_version "$README_PATH" "$VERSION"
  echo "✅ Version updated successfully to $VERSION"
else
  echo "ℹ️ Version in $README_PATH already set to $VERSION, no update needed"
fi

exit 0
