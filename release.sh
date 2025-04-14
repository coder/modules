#!/usr/bin/env bash
#
# release.sh - Create module release tags
#
# This script creates annotated tags for module releases which trigger
# the GitHub Actions workflow to update README versions.
#
# Usage:
#   ./release.sh module-name X.Y.Z     # Create a tag with specific version
#   ./release.sh --list                # List modules with their latest versions
#   ./release.sh --dry-run module-name X.Y.Z  # Simulate tag creation

set -euo pipefail

# Check if --list is requested
if [[ "$#" -eq 1 && "$1" == "--list" ]]; then
  # Function to extract version from README.md
  extract_version() {
    local file="$1"
    grep -o 'version *= *"[0-9]\+\.[0-9]\+\.[0-9]\+"' "$file" | head -1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' || echo "0.0.0"
  }

  # List all modules and their versions
  echo "Listing all modules and their latest versions:"
  echo "--------------------------------------------------"
  printf "%-30s %-15s %s\n" "MODULE" "README VERSION" "LATEST TAG"
  echo "--------------------------------------------------"
  
  for dir in */; do
    if [[ -d "$dir" && -f "${dir}README.md" && "$dir" != ".git/" ]]; then
      module_name="${dir%/}"
      readme_version=$(extract_version "${dir}README.md")
      latest_tag=$(git tag -l "release/${module_name}/v*" | sort -V | tail -n 1)
      tag_version=$([ -n "$latest_tag" ] && echo "$latest_tag" | sed 's|release/'"${module_name}"'/v||' || echo "none")
      printf "%-30s %-15s %s\n" "$module_name" "$readme_version" "$tag_version"
    fi
  done
  
  echo "--------------------------------------------------"
  echo "To create a new release: ./release.sh module-name X.Y.Z"
  exit 0
fi

# Check for dry run
DRY_RUN=false
if [[ "$1" == "--dry-run" ]]; then
  DRY_RUN=true
  shift
fi

# Validate arguments
if [[ "$#" -ne 2 ]]; then
  echo "Error: Expected module name and version"
  echo "Usage: ./release.sh [--dry-run] module-name X.Y.Z"
  echo "   or: ./release.sh --list"
  exit 1
fi

# Extract arguments
MODULE_NAME="$1"
VERSION="$2"

# Validate version format
if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Error: Version must be in format X.Y.Z (e.g., 1.2.3)"
  exit 1
fi

# Function to extract version from README.md
extract_version() {
  local file="$1"
  grep -o 'version *= *"[0-9]\+\.[0-9]\+\.[0-9]\+"' "$file" | head -1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' || echo "0.0.0"
}

# Verify module directory exists
if [[ ! -d "$MODULE_NAME" || ! -f "$MODULE_NAME/README.md" ]]; then
  echo "Error: Module directory '$MODULE_NAME' not found or missing README.md"
  exit 1
fi

# Get current version from README
README_VERSION=$(extract_version "$MODULE_NAME/README.md")

# Construct tag name
TAG_NAME="release/$MODULE_NAME/v$VERSION"

# Check if tag already exists
if git rev-parse -q --verify "refs/tags/$TAG_NAME" >/dev/null; then
  echo "Error: Tag $TAG_NAME already exists"
  exit 1
fi

# Report what will happen
echo "Module: $MODULE_NAME"
echo "Current README version: $README_VERSION"
echo "New tag version: $VERSION"
echo "Tag name: $TAG_NAME"

# Create the tag
if [[ "$DRY_RUN" == "false" ]]; then
  git tag -a "$TAG_NAME" -m "Release $MODULE_NAME v$VERSION"
  echo "Success! Tag '$TAG_NAME' created."
  echo "To complete the release: git push origin $TAG_NAME"
else
  echo "[DRY RUN] Would create tag: $TAG_NAME"
fi

exit 0