#!/usr/bin/env bash
#
# release.sh - Create and manage module releases
#
# This script is intended for maintainers to create and manage releases
# by creating annotated tags with appropriate version numbers.
#
# Usage:
#   ./release.sh module-name --version=X.Y.Z     # Create a tag with specific version
#   ./release.sh --help                          # Show this help message
#   ./release.sh --list                          # List modules with their latest versions

set -euo pipefail

# Default values
MODULE_NAME=""
VERSION=""
CREATE_TAG=true
LIST_MODULES=false
SHOW_HELP=false

# Function to show usage
show_help() {
  cat << EOF
release.sh - Create and manage module releases

Usage:
  ./release.sh [options] module-name

Options:
  --version=X.Y.Z          Version number for the new release (required)
  --dry-run                Show what would happen without making changes
  --list                   List all modules with their latest versions
  --help                   Show this help message

Examples:
  ./release.sh code-server --version=1.2.3   # Create release/code-server/v1.2.3 tag
  ./release.sh --list                        # List all modules and their versions

Notes:
  - This script creates annotated tags that trigger automated README updates
  - Tags follow the format: release/module-name/vX.Y.Z
  - After creating a tag, you need to push it manually with:
    git push origin release/module-name/vX.Y.Z
EOF
  exit 0
}

# Parse arguments
for arg in "$@"; do
  if [[ "$arg" == "--help" ]]; then
    SHOW_HELP=true
  elif [[ "$arg" == "--list" ]]; then
    LIST_MODULES=true
  elif [[ "$arg" == --version=* ]]; then
    VERSION="${arg#*=}"
    # Validate version format
    if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      echo "Error: Version must be in format X.Y.Z (e.g., 1.2.3)"
      exit 1
    fi
  elif [[ "$arg" == "--dry-run" ]]; then
    CREATE_TAG=false
  elif [[ "$arg" != --* ]]; then
    MODULE_NAME="$arg"
  fi
done

# Show help if requested
if [[ "$SHOW_HELP" == "true" ]]; then
  show_help
fi

# Function to extract version from README.md
extract_readme_version() {
  local file="$1"
  grep -o 'version *= *"[0-9]\+\.[0-9]\+\.[0-9]\+"' "$file" | head -1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' || echo "0.0.0"
}

# Function to list all modules and their latest versions
list_modules() {
  echo "Listing all modules and their latest versions:"
  echo "--------------------------------------------------"
  printf "%-30s %-15s %s\n" "MODULE" "README VERSION" "LATEST TAG"
  echo "--------------------------------------------------"
  
  for dir in */; do
    if [[ -d "$dir" && -f "${dir}README.md" && "$dir" != ".git/" ]]; then
      # Remove trailing slash
      module_name="${dir%/}"
      
      # Get version from README
      readme_version=$(extract_readme_version "${dir}README.md")
      
      # Get latest tag for this module
      latest_tag=$(git tag -l "release/${module_name}/v*" | sort -V | tail -n 1)
      if [[ -n "$latest_tag" ]]; then
        tag_version=$(echo "$latest_tag" | sed 's|release/'"${module_name}"'/v||')
      else
        tag_version="none"
      fi
      
      printf "%-30s %-15s %s\n" "$module_name" "$readme_version" "$tag_version"
    fi
  done
  
  echo "--------------------------------------------------"
  echo "To create a new release: ./release.sh module-name --version=X.Y.Z"
  exit 0
}

# Show list of modules if requested
if [[ "$LIST_MODULES" == "true" ]]; then
  list_modules
fi

# Validate required parameters
if [[ -z "$MODULE_NAME" ]]; then
  echo "Error: Module name is required"
  echo "Usage: ./release.sh module-name --version=X.Y.Z"
  echo "Run ./release.sh --help for more information"
  exit 1
fi

if [[ -z "$VERSION" ]]; then
  echo "Error: Version is required (--version=X.Y.Z)"
  echo "Usage: ./release.sh module-name --version=X.Y.Z"
  echo "Run ./release.sh --help for more information"
  exit 1
fi

# Verify module directory exists
if [[ ! -d "$MODULE_NAME" || ! -f "$MODULE_NAME/README.md" ]]; then
  echo "Error: Module directory '$MODULE_NAME' not found or missing README.md"
  echo "Available modules:"
  for dir in */; do
    if [[ -d "$dir" && -f "${dir}README.md" && "$dir" != ".git/" ]]; then
      echo "  ${dir%/}"
    fi
  done
  exit 1
fi

# Get current version from README
README_PATH="$MODULE_NAME/README.md"
README_VERSION=$(extract_readme_version "$README_PATH")

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
if [[ "$CREATE_TAG" == "true" ]]; then
  echo "Creating annotated tag..."
  git tag -a "$TAG_NAME" -m "Release $MODULE_NAME v$VERSION"
  echo -e "\nSuccess! Tag '$TAG_NAME' created."
  echo -e "\nTo complete the release:"
  echo "1. Push the tag to the repository:"
  echo "   git push origin $TAG_NAME"
  echo ""
  echo "2. The GitHub Action will automatically create a PR to update"
  echo "   the README.md version to match the tag."
else
  echo "[DRY RUN] Would create tag: $TAG_NAME"
  echo "[DRY RUN] Tag message: Release $MODULE_NAME v$VERSION"
fi

exit 0