#!/usr/bin/env bash
#
# update-version.sh - Update README.md version to match module tag
#
# This script is primarily used by the GitHub Actions workflow
# to update README versions after a new tag is pushed.
#
# Usage:
#   ./update-version.sh module-name --version=X.Y.Z    # Update README version
#   ./update-version.sh --help                         # Show help message
#   ./update-version.sh --check module-name --version=X.Y.Z # Check version

set -euo pipefail

# Default values
MODULE_NAME=""
VERSION=""
CHECK_ONLY=false
SHOW_HELP=false

# Function to show usage
show_help() {
  cat << EOF
update-version.sh - Update README.md version to match module tag

Usage:
  ./update-version.sh [options] module-name

Options:
  --version=X.Y.Z          Version number to set in README.md
  --check                  Only check if README version matches specified version
  --help                   Show this help message

Examples:
  ./update-version.sh code-server --version=1.2.3   # Update version in code-server README
  ./update-version.sh --check code-server --version=1.2.3  # Check if versions match
EOF
  exit 0
}

# Parse arguments
for arg in "$@"; do
  if [[ "$arg" == "--help" ]]; then
    SHOW_HELP=true
  elif [[ "$arg" == "--check" ]]; then
    CHECK_ONLY=true
  elif [[ "$arg" == --version=* ]]; then
    VERSION="${arg#*=}"
    # Validate version format
    if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      echo "Error: Version must be in format X.Y.Z (e.g., 1.2.3)"
      exit 1
    fi
  elif [[ "$arg" != --* ]]; then
    MODULE_NAME="$arg"
  fi
done

# Show help if requested
if [[ "$SHOW_HELP" == "true" ]]; then
  show_help
fi

# Validate required parameters
if [[ -z "$MODULE_NAME" ]]; then
  echo "Error: Module name is required"
  echo "Usage: ./update-version.sh module-name --version=X.Y.Z"
  exit 1
fi

if [[ -z "$VERSION" ]]; then
  echo "Error: Version is required (--version=X.Y.Z)"
  echo "Usage: ./update-version.sh module-name --version=X.Y.Z"
  exit 1
fi

# Verify module directory exists
if [[ ! -d "$MODULE_NAME" || ! -f "$MODULE_NAME/README.md" ]]; then
  echo "Error: Module directory '$MODULE_NAME' not found or missing README.md"
  exit 1
fi

# Function to extract version from README.md
extract_version() {
  local file="$1"
  grep -o 'version *= *"[0-9]\+\.[0-9]\+\.[0-9]\+"' "$file" | head -1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' || echo "0.0.0"
}

# Function to update version in README.md
update_version() {
  local file="$1"
  local new_version="$2"
  local tmpfile
  
  tmpfile=$(mktemp /tmp/tempfile.XXXXXX)
  awk -v tag="$new_version" '
    BEGIN { in_code_block = 0; in_nested_block = 0 }
    {
      # Detect code blocks
      if ($0 ~ /^```/) {
        in_code_block = !in_code_block
        if (!in_code_block) { in_nested_block = 0 }
      }

      # Track nested blocks within code blocks
      if (in_code_block) {
        if ($0 ~ /{/ && !($1 == "module" || $1 ~ /^[a-zA-Z0-9_]+$/)) {
          in_nested_block++
        }
        if ($0 ~ /}/ && in_nested_block > 0) {
          in_nested_block--
        }

        # Update version only if not in nested block
        if (!in_nested_block && $1 == "version" && $2 == "=") {
          sub(/"[^"]*"/, "\"" tag "\"")
        }
      }

      print
    }
  ' "$file" > "$tmpfile" && mv "$tmpfile" "$file"
}

# Get current version from README
README_PATH="$MODULE_NAME/README.md"
README_VERSION=$(extract_version "$README_PATH")

# Report current status
echo "Module: $MODULE_NAME"
echo "Current README version: $README_VERSION"
echo "Target version: $VERSION"

# In check mode, just report if versions match
if [[ "$CHECK_ONLY" == "true" ]]; then
  if [[ "$README_VERSION" == "$VERSION" ]]; then
    echo "✅ Version in README.md matches target version: $VERSION"
    exit 0
  else
    echo "❌ Version mismatch: README.md has $README_VERSION, target is $VERSION"
    exit 1
  fi
fi

# Update README if versions differ
if [[ "$README_VERSION" == "$VERSION" ]]; then
  echo "Version in $README_PATH is already set to $VERSION"
else
  echo "Updating version in $README_PATH from $README_VERSION to $VERSION"
  update_version "$README_PATH" "$VERSION"
  echo "✅ Successfully updated version to $VERSION"
fi

exit 0