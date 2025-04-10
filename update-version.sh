#!/usr/bin/env bash

# This script checks and verifies that README.md files have up-to-date versions
# for modules with module-specific tags in the format: release/module-name/v1.0.0
# It can be used in CI to verify versions are correct or to update versions locally.
# It is intended to be run from the root of the repository or by using the 
# `bun update-version` command.

set -euo pipefail

# Check for --check flag to run in verification mode without making changes
CHECK_ONLY=false
if [[ "$*" == *"--check"* ]]; then
  CHECK_ONLY=true
  echo "Running in check-only mode (no changes will be made)"
fi

# Parse other arguments
MODULE_NAME=""
for arg in "$@"; do
  if [[ "$arg" != "--check" ]]; then
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
    
    # Check for module-specific tag with format: release/module-name/v1.0.0
    latest_module_tag=$(git tag -l "release/$module_name/v*" | sort -V | tail -n 1)
    
    # Skip modules that don't have module-specific tags
    if [[ -z "$latest_module_tag" ]]; then
      echo "Skipping $dir: No module-specific tag found"
      continue
    fi
    
    # Extract version number from tag
    current_tag_version=$(echo "$latest_module_tag" | sed 's|release/'"$module_name"'/v||')
    
    # Get version from README.md
    readme_version=$(extract_readme_version "$dir/README.md")
    
    echo "Processing $dir: Tag version=$current_tag_version, README version=$readme_version"
    
    # Check if README version matches the current tag version
    if [[ "$readme_version" != "$current_tag_version" ]]; then
      if [[ "$CHECK_ONLY" == "true" ]]; then
        echo "ERROR: Version mismatch in $dir/README.md: Expected $current_tag_version, found $readme_version"
        EXIT_CODE=1
      else
        echo "Updating version in $dir/README.md from $readme_version to $current_tag_version"
        
        file="$dir/README.md"
        tmpfile=$(mktemp /tmp/tempfile.XXXXXX)
        awk -v tag="$current_tag_version" '
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
      fi
    else
      echo "Version in $dir/README.md is already correct ($readme_version)"
    fi
  fi
done

exit $EXIT_CODE
