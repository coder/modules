#!/usr/bin/env bash

# This script checks that README.md files have versions that match module-specific
# tags in the format: release/module-name/v1.0.0
# It can be used in CI to verify versions are correct.
#
# It also supports updating a README with a new version that will be tagged in the future.
#
# Usage:
#   ./check-version.sh                   # Check all modules with changes
#   ./check-version.sh module-name       # Check only the specified module
#   ./check-version.sh --version=1.2.3 module-name  # Update module README to version 1.2.3

set -euo pipefail

# Parse arguments
MODULE_NAME=""
NEW_VERSION=""

for arg in "$@"; do
  if [[ "$arg" == --version=* ]]; then
    NEW_VERSION="${arg#*=}"
    echo "Will update to version: $NEW_VERSION"
  elif [[ "$arg" != --* ]]; then
    MODULE_NAME="$arg"
    echo "Focusing on module: $MODULE_NAME"
  fi
done

# Function to extract version from README.md
extract_readme_version() {
  local file="$1"
  grep -o 'version *= *"[0-9]\+\.[0-9]\+\.[0-9]\+"' "$file" | head -1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' || echo "0.0.0"
}

# List directories with changes that are not README.md or test files
if [[ -n "$MODULE_NAME" ]]; then
  # If a specific module is provided, only check that directory
  if [[ ! -d "$MODULE_NAME" ]]; then
    echo "Error: Module directory '$MODULE_NAME' not found."
    exit 1
  fi
  mapfile -t changed_dirs < <(echo "$MODULE_NAME")
else
  # Get the latest tag for the repository
  latest_repo_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
  
  # Find directories with changes since the latest tag
  mapfile -t changed_dirs < <(git diff --name-only "$latest_repo_tag" -- ':!**/README.md' ':!**/*.test.ts' | xargs dirname | grep -v '^\.' | sort -u)
  
  echo "Directories with changes: ${changed_dirs[*]}"
fi

EXIT_CODE=0

# Iterate over directories and check/update versions in README.md
for dir in "${changed_dirs[@]}"; do
  if [[ -f "$dir/README.md" ]]; then
    # Get the module name from the directory
    module_name=$(basename "$dir")
    
    # Get version from README.md
    readme_version=$(extract_readme_version "$dir/README.md")
    
    # If a new version was provided, update the README
    if [[ -n "$NEW_VERSION" ]]; then
      if [[ "$readme_version" == "$NEW_VERSION" ]]; then
        echo "Version in $dir/README.md is already set to $NEW_VERSION"
      else
        echo "Updating version in $dir/README.md from $readme_version to $NEW_VERSION"
        
        file="$dir/README.md"
        tmpfile=$(mktemp /tmp/tempfile.XXXXXX)
        awk -v tag="$NEW_VERSION" '
          BEGIN { in_code_block = 0; in_nested_block = 0 }
          {
            # Detect the start and end of Markdown code blocks.
            if ($0 ~ /^```/) {
              in_code_block = !in_code_block
              # Reset nested block tracking when exiting a code block.
              if (!in_code_block) {
                in_nested_block = 0
              }
            }

            # Handle nested blocks within a code block.
            if (in_code_block) {
              # Detect the start of a nested block (skipping "module" blocks).
              if ($0 ~ /{/ && !($1 == "module" || $1 ~ /^[a-zA-Z0-9_]+$/)) {
                in_nested_block++
              }

              # Detect the end of a nested block.
              if ($0 ~ /}/ && in_nested_block > 0) {
                in_nested_block--
              }

              # Update "version" only if not in a nested block.
              if (!in_nested_block && $1 == "version" && $2 == "=") {
                sub(/"[^"]*"/, "\"" tag "\"")
              }
            }

            print
          }
        ' "$file" > "$tmpfile" && mv "$tmpfile" "$file"
        
        echo "Remember to tag this release with: git tag release/$module_name/v$NEW_VERSION"
      fi
      # Skip the version check when updating
      continue
    fi
    
    # Check for module-specific tag with format: release/module-name/v1.0.0
    module_tags=$(git tag -l "release/$module_name/v*" | sort -V)
    
    # Skip modules that don't have module-specific tags
    if [[ -z "$module_tags" ]]; then
      echo "Skipping $dir: No module-specific tags found"
      continue
    fi
    
    # Check if README version matches any of the module's tags
    version_found=false
    for tag in $module_tags; do
      tag_version=$(echo "$tag" | sed 's|release/'"$module_name"'/v||')
      if [[ "$readme_version" == "$tag_version" ]]; then
        version_found=true
        echo "Version in $dir/README.md ($readme_version) matches tag $tag"
        break
      fi
    done
    
    if [[ "$version_found" == "false" ]]; then
      echo "ERROR: Version in $dir/README.md ($readme_version) does not match any existing tag"
      echo "Available tags:"
      echo "$module_tags"
      EXIT_CODE=1
    fi
  fi
done

if [[ $EXIT_CODE -eq 0 ]]; then
  echo "All checked modules have valid versions"
else
  echo "Some modules have version mismatches - see errors above"
fi

exit $EXIT_CODE
