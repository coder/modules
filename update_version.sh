#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 [OPTIONS] <MODULE> <VERSION>

Update or check the version in a module's README.md file.

Options:
  -c, --check  Check if README.md version matches VERSION without updating
  -h, --help   Display this help message and exit

Examples:
  $0 code-server 1.2.3          # Update version in code-server/README.md
  $0 --check code-server 1.2.3  # Check if version matches 1.2.3
EOF
  exit "${1:-0}"
}

is_valid_version() {
  if ! [[ $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: Version must be in format X.Y.Z (e.g., 1.2.3)" >&2
    return 1
  fi
}

update_version() {
  local file="$1" current_tag="$2" latest_tag="$3" tmpfile
  tmpfile=$(mktemp)

  echo "Updating version in $file from $current_tag to $latest_tag..."

  awk -v tag="$latest_tag" '
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
  ' "$file" >"$tmpfile" && mv "$tmpfile" "$file"
}

get_readme_version() {
  grep -o 'version *= *"[0-9]\+\.[0-9]\+\.[0-9]\+"' "$1" |
    head -1 |
    grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' ||
    echo "0.0.0"
}

# Set defaults.
check_only=false

# Parse command-line options.
while [[ $# -gt 0 ]]; do
  case "$1" in
  -c | --check)
    check_only=true
    shift
    ;;
  -h | --help)
    usage 0
    ;;
  -*)
    echo "Error: Unknown option: $1" >&2
    usage 1
    ;;
  *)
    break
    ;;
  esac
done

if [[ $# -ne 2 ]]; then
  echo "Error: MODULE and VERSION are required" >&2
  usage 1
fi

module_name="$1"
version="$2"

if [[ ! -d $module_name ]]; then
  echo "Error: Module directory '$module_name' not found" >&2
  echo >&2
  echo "Available modules:" >&2
  echo >&2
  find . -type d -mindepth 1 -maxdepth 1 -not -path "*/\.*" | sed 's|^./|\t|' | sort >&2
  exit 1
fi

if ! is_valid_version "$version"; then
  exit 1
fi

readme_path="$module_name/README.md"
if [[ ! -f $readme_path ]]; then
  echo "Error: README.md not found in '$module_name' directory" >&2
  exit 1
fi

readme_version=$(get_readme_version "$readme_path")

# In check mode, just return success/failure based on version match.
if [[ $check_only == true ]]; then
  if [[ $readme_version == "$version" ]]; then
    echo "✅ Success: Version in $readme_path matches $version"
    exit 0
  else
    echo "❌ Error: Version mismatch in $readme_path"
    echo "Expected: $version"
    echo "Found: $readme_version"
    exit 1
  fi
fi

if [[ $readme_version != "$version" ]]; then
  update_version "$readme_path" "$readme_version" "$version"
  echo "✅ Version updated successfully to $version"
else
  echo "ℹ️ Version in $readme_path already set to $version, no update needed"
fi
