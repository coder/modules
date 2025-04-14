#!/usr/bin/env bash

# modules-version: A tool for managing module versions in the Coder modules repository
#
# This script handles module versioning with support for module-specific tags in the format:
# release/module-name/v1.0.0
#
# Features:
# - Check that README.md versions match module tags (CI-friendly)
# - Create annotated tags for module releases
# - Bump module versions in README files
# - Set exact versions in README files
# - Support for module-specific tags and versioning
#
# Usage:
#   ./modules-version.sh                                  # Check all modules with changes
#   ./modules-version.sh module-name                      # Check a specific module
#   ./modules-version.sh --dry-run                        # Simulate updates without making changes
#   ./modules-version.sh --tag module-name                # Create annotated git tag
#   ./modules-version.sh --bump=patch module-name         # Bump patch version (default)
#   ./modules-version.sh --bump=minor module-name         # Bump minor version
#   ./modules-version.sh --bump=major module-name         # Bump major version
#   ./modules-version.sh --version=1.2.3 module-name      # Set exact version number

set -euo pipefail

# Default values
DRY_RUN=false
MODULE_NAME=""
VERSION_ACTION=""
VERSION_TYPE="patch"
EXACT_VERSION_CLI=""
CREATE_TAG=false
SHOW_HELP=false

# Function to show usage
show_help() {
  cat << EOF
modules-version: A tool for managing module versions

Usage:
  ./modules-version.sh [options] [module-name]

Options:
  --dry-run                Simulate updates without making changes
  --bump=patch|minor|major Bump version (patch is default)
  --version=X.Y.Z          Set an exact version number
  --tag                    Create annotated git tag
  --help                   Show this help message

Examples:
  ./modules-version.sh                         # Check all modules with changes
  ./modules-version.sh --dry-run               # Show what changes would be made (CI-friendly)
  ./modules-version.sh module-name             # Check a specific module
  ./modules-version.sh --tag module-name       # Create annotated tag for a module
  ./modules-version.sh --bump=minor module-name    # Bump minor version in README
  ./modules-version.sh --version=1.2.3 module-name # Set exact version in README
EOF
  exit 0
}

# Parse arguments
for arg in "$@"; do
  if [[ "$arg" == "--dry-run" ]]; then
    DRY_RUN=true
  elif [[ "$arg" == "--tag" ]]; then
    CREATE_TAG=true
  elif [[ "$arg" == "--help" ]]; then
    SHOW_HELP=true
  elif [[ "$arg" == --bump=* ]]; then
    VERSION_ACTION="bump"
    VERSION_TYPE="${arg#*=}"
    if [[ "$VERSION_TYPE" != "patch" && "$VERSION_TYPE" != "minor" && "$VERSION_TYPE" != "major" ]]; then
      echo "Error: Version bump type must be 'patch', 'minor', or 'major'"
      exit 1
    fi
  elif [[ "$arg" == --version=* ]]; then
    VERSION_ACTION="set"
    EXACT_VERSION_CLI="${arg#*=}"
    # Validate version format
    if ! [[ "$EXACT_VERSION_CLI" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
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

# Report mode
if [[ "$DRY_RUN" == "true" ]]; then
  echo "Running in dry-run mode (no changes will be made)"
fi

if [[ -n "$MODULE_NAME" ]]; then
  echo "Working with module: $MODULE_NAME"
fi

if [[ "$VERSION_ACTION" == "bump" ]]; then
  echo "Will bump $VERSION_TYPE version"
elif [[ "$VERSION_ACTION" == "set" ]]; then
  echo "Will set version to $EXACT_VERSION_CLI"
fi

if [[ "$CREATE_TAG" == "true" ]]; then
  echo "Will create annotated tag"
fi

# Function to extract version from README.md
extract_readme_version() {
  local file="$1"
  grep -o 'version *= *"[0-9]\+\.[0-9]\+\.[0-9]\+"' "$file" | head -1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' || echo "0.0.0"
}

# Function to determine version
# Supports:
# 1. Exact version from --version command-line option
# 2. Bumping version based on type (major, minor, patch)
get_version() {
  local current_version="$1"
  local bump_type="$2"
  
  # Priority 1: Use the command-line --version option if specified
  if [[ "$VERSION_ACTION" == "set" && -n "$EXACT_VERSION_CLI" ]]; then
    echo "$EXACT_VERSION_CLI"
    return
  fi
  
  # Priority 2: Bump the version according to semantic versioning
  IFS='.' read -r major minor patch <<< "$current_version"
  
  if [[ "$bump_type" == "major" ]]; then
    echo "$((major + 1)).0.0"
  elif [[ "$bump_type" == "minor" ]]; then
    echo "$major.$((minor + 1)).0"
  else # Default to patch
    echo "$major.$minor.$((patch + 1))"
  fi
}

# Function to update version in README.md
update_version_in_readme() {
  local file="$1"
  local new_version="$2"
  local tmpfile
  
  tmpfile=$(mktemp /tmp/tempfile.XXXXXX)
  awk -v tag="$new_version" '
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

# Iterate over directories and process versions
for dir in "${changed_dirs[@]}"; do
  if [[ -f "$dir/README.md" ]]; then
    # Get the module name from the directory
    module_name=$(basename "$dir")
    
    # Get version from README.md
    readme_version=$(extract_readme_version "$dir/README.md")
    
    # Check for module-specific tag with format: release/module-name/v1.0.0
    latest_module_tag=$(git tag -l "release/$module_name/v*" | sort -V | tail -n 1)
    if [[ -n "$latest_module_tag" ]]; then
      latest_tag_version=$(echo "$latest_module_tag" | sed 's|release/'"$module_name"'/v||')
      echo "Module $module_name: Latest tag=$latest_tag_version, README version=$readme_version"
    else
      echo "Module $module_name: No module-specific tags found, README version=$readme_version"
    fi
    
    # Update version if requested and not in dry-run mode
    if [[ "$DRY_RUN" == "false" && "$VERSION_ACTION" == "bump" ]]; then
      # Start with the latest tag version if available, otherwise use README version
      base_version=""
      if [[ -n "$latest_module_tag" ]]; then
        base_version="$latest_tag_version"
      else
        base_version="$readme_version"
      fi
      target_version=$(get_version "$base_version" "$VERSION_TYPE")
      
      # Update README if needed
      if [[ "$readme_version" == "$target_version" ]]; then
        echo "Version in $dir/README.md is already set to $target_version"
      else
        echo "Updating version in $dir/README.md from $readme_version to $target_version"
        update_version_in_readme "$dir/README.md" "$target_version"
        
        # Create annotated tag if requested
        if [[ "$CREATE_TAG" == "true" ]]; then
          tag_name="release/$module_name/v$target_version"
          echo "Creating annotated tag: $tag_name"
          git tag -a "$tag_name" -m "Release $module_name v$target_version"
          echo "Remember to push the tag with: git push origin $tag_name"
          echo "A GitHub Action will automatically create a PR to update README files when the tag is pushed."
        else
          echo "To tag this release, use: git tag -a release/$module_name/v$target_version -m \"Release $module_name v$target_version\""
        fi
      fi
      continue
    elif [[ "$DRY_RUN" == "true" && "$VERSION_ACTION" == "bump" ]]; then
      # Show what would happen in dry-run mode
      base_version=""
      if [[ -n "$latest_module_tag" ]]; then
        base_version="$latest_tag_version"
      else
        base_version="$readme_version"
      fi
      target_version=$(get_version "$base_version" "$VERSION_TYPE")
      
      echo "[DRY RUN] Would update version in $dir/README.md from $readme_version to $target_version"
      if [[ "$CREATE_TAG" == "true" ]]; then
        echo "[DRY RUN] Would create annotated tag: release/$module_name/v$target_version"
        echo "[DRY RUN] A GitHub Action would create a PR when the tag is pushed"
      fi
      continue
    fi
    
    # Only do version checking if we're not updating
    if [[ "$VERSION_ACTION" != "bump" ]]; then
      # Get all tags for the module
      module_tags=$(git tag -l "release/$module_name/v*" | sort -V)
      
      # Skip modules that don't have module-specific tags
      if [[ -z "$module_tags" ]]; then
        echo "Skipping version check for $dir: No module-specific tags found"
        continue
      fi
      
      # Check if README version matches any of the module's tags
      version_found=false
      for tag in $module_tags; do
        tag_version=$(echo "$tag" | sed 's|release/'"$module_name"'/v||')
        if [[ "$readme_version" == "$tag_version" ]]; then
          version_found=true
          echo "✅ Version in $dir/README.md ($readme_version) matches tag $tag"
          break
        fi
      done
      
      if [[ "$version_found" == "false" ]]; then
        echo "❌ ERROR: Version in $dir/README.md ($readme_version) does not match any existing tag"
        echo "Available tags:"
        echo "$module_tags"
        EXIT_CODE=1
      fi
    fi
  fi
done

if [[ $EXIT_CODE -eq 0 ]]; then
  echo "✅ All checked modules have valid versions"
else
  echo "❌ Some modules have version mismatches - see errors above"
fi

exit $EXIT_CODE
