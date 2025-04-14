#!/usr/bin/env bash
# update-version.sh - Updates or checks README.md version

set -euo pipefail

CHECK_ONLY=false
if [[ "$1" == "--check" ]]; then
  CHECK_ONLY=true
  shift
fi

if [[ "$#" -ne 2 ]]; then
  echo "Usage: ./update-version.sh [--check] module-name X.Y.Z"
  exit 1
fi

MODULE_NAME="$1"
VERSION="$2"

if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Error: Version must be in format X.Y.Z"
  exit 1
fi

if [[ ! -d "$MODULE_NAME" || ! -f "$MODULE_NAME/README.md" ]]; then
  echo "Error: Module directory not found or missing README.md"
  exit 1
fi

extract_version() {
  grep -o 'version *= *"[0-9]\+\.[0-9]\+\.[0-9]\+"' "$1" | head -1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' || echo "0.0.0"
}

update_version() {
  local tmpfile=$(mktemp)
  awk -v tag="$2" '
    BEGIN { in_code_block = 0; in_nested_block = 0 }
    {
      if ($0 ~ /^```/) {
        in_code_block = !in_code_block
        if (!in_code_block) { in_nested_block = 0 }
      }
      if (in_code_block) {
        if ($0 ~ /{/ && !($1 == "module" || $1 ~ /^[a-zA-Z0-9_]+$/)) {
          in_nested_block++
        }
        if ($0 ~ /}/ && in_nested_block > 0) {
          in_nested_block--
        }
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

if [[ "$CHECK_ONLY" == "true" ]]; then
  if [[ "$README_VERSION" == "$VERSION" ]]; then
    exit 0
  else
    exit 1
  fi
fi

if [[ "$README_VERSION" != "$VERSION" ]]; then
  update_version "$README_PATH" "$VERSION"
fi

exit 0