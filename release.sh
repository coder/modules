#!/usr/bin/env bash
#
# release.sh - Creates annotated tags for module releases
#
# This script is used by maintainers to create annotated tags for module releases.
# It supports two main modes:
# 1. Creating a new tag for a module: ./release.sh module-name X.Y.Z
# 2. Listing all modules with their versions: ./release.sh --list
#
# When a tag is pushed, it triggers a GitHub workflow that updates README versions.

set -euo pipefail

# Handle --list option to show all modules and their versions
if [[ "$#" -eq 1 && "$1" == "--list" ]]; then
  # Function to extract version from README
  extract_version() {
    grep -o 'version *= *"[0-9]\+\.[0-9]\+\.[0-9]\+"' "$1" | head -1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' || echo "0.0.0"
  }

  # Display header for module listing
  echo "Listing all modules and their latest versions:"
  echo "--------------------------------------------------"
  printf "%-30s %-15s %s\n" "MODULE" "README VERSION" "LATEST TAG"
  echo "--------------------------------------------------"
  
  # Loop through all directories that look like modules
  for dir in */; do
    if [[ -d "$dir" && -f "${dir}README.md" && "$dir" != ".git/" ]]; then
      module_name="${dir%/}"
      # Get version from README
      readme_version=$(extract_version "${dir}README.md")
      # Get latest tag for this module
      latest_tag=$(git tag -l "release/${module_name}/v*" | sort -V | tail -n 1)
      tag_version=$([ -n "$latest_tag" ] && echo "$latest_tag" | sed 's|release/'"${module_name}"'/v||' || echo "none")
      # Display module info
      printf "%-30s %-15s %s\n" "$module_name" "$readme_version" "$tag_version"
    fi
  done
  
  echo "--------------------------------------------------"
  exit 0
fi

# Handle --dry-run option
DRY_RUN=false
if [[ "$1" == "--dry-run" ]]; then
  DRY_RUN=true
  shift
fi

# Validate arguments
if [[ "$#" -ne 2 ]]; then
  echo "Usage: ./release.sh [--dry-run] module-name X.Y.Z"
  echo "   or: ./release.sh --list"
  exit 1
fi

MODULE_NAME="$1"
VERSION="$2"

# Validate version format
if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Error: Version must be in format X.Y.Z"
  exit 1
fi

# Function to extract version from README
extract_version() {
  grep -o 'version *= *"[0-9]\+\.[0-9]\+\.[0-9]\+"' "$1" | head -1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' || echo "0.0.0"
}

# Check if module exists
if [[ ! -d "$MODULE_NAME" || ! -f "$MODULE_NAME/README.md" ]]; then
  echo "Error: Module directory not found or missing README.md"
  exit 1
fi

# Get current README version and construct tag name
README_VERSION=$(extract_version "$MODULE_NAME/README.md")
TAG_NAME="release/$MODULE_NAME/v$VERSION"

# Check if tag already exists
if git rev-parse -q --verify "refs/tags/$TAG_NAME" >/dev/null; then
  echo "Error: Tag $TAG_NAME already exists"
  exit 1
fi

# Display release information
echo "Module: $MODULE_NAME"
echo "Current README version: $README_VERSION"
echo "New tag version: $VERSION"
echo "Tag name: $TAG_NAME"

# Create the tag (or simulate in dry-run mode)
if [[ "$DRY_RUN" == "false" ]]; then
  # Create annotated tag
  git tag -a "$TAG_NAME" -m "Release $MODULE_NAME v$VERSION"
  echo "Success! Tag '$TAG_NAME' created."
  echo "To complete the release: git push origin $TAG_NAME"
  echo ""
  echo "When pushed, this will trigger the GitHub Action to:"
  echo "- Update the README.md version"
  echo "- Create a PR with the update"
  echo "- Auto-approve and merge the PR"
else
  echo "[DRY RUN] Would create tag: $TAG_NAME"
fi

exit 0