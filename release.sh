#!/usr/bin/env bash
# release.sh - Creates annotated tags for module releases

set -euo pipefail

if [[ "$#" -eq 1 && "$1" == "--list" ]]; then
  extract_version() {
    grep -o 'version *= *"[0-9]\+\.[0-9]\+\.[0-9]\+"' "$1" | head -1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' || echo "0.0.0"
  }

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
  exit 0
fi

DRY_RUN=false
if [[ "$1" == "--dry-run" ]]; then
  DRY_RUN=true
  shift
fi

if [[ "$#" -ne 2 ]]; then
  echo "Usage: ./release.sh [--dry-run] module-name X.Y.Z"
  echo "   or: ./release.sh --list"
  exit 1
fi

MODULE_NAME="$1"
VERSION="$2"

if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Error: Version must be in format X.Y.Z"
  exit 1
fi

extract_version() {
  grep -o 'version *= *"[0-9]\+\.[0-9]\+\.[0-9]\+"' "$1" | head -1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' || echo "0.0.0"
}

if [[ ! -d "$MODULE_NAME" || ! -f "$MODULE_NAME/README.md" ]]; then
  echo "Error: Module directory not found or missing README.md"
  exit 1
fi

README_VERSION=$(extract_version "$MODULE_NAME/README.md")
TAG_NAME="release/$MODULE_NAME/v$VERSION"

if git rev-parse -q --verify "refs/tags/$TAG_NAME" >/dev/null; then
  echo "Error: Tag $TAG_NAME already exists"
  exit 1
fi

echo "Module: $MODULE_NAME"
echo "Current README version: $README_VERSION"
echo "New tag version: $VERSION"
echo "Tag name: $TAG_NAME"

if [[ "$DRY_RUN" == "false" ]]; then
  git tag -a "$TAG_NAME" -m "Release $MODULE_NAME v$VERSION"
  echo "Success! Tag '$TAG_NAME' created."
  echo "To complete the release: git push origin $TAG_NAME"
else
  echo "[DRY RUN] Would create tag: $TAG_NAME"
fi

exit 0