#!/usr/bin/env bash

# This script increments the version number in the README.md files of all modules
# by 1 patch version. It is intended to be run from the root
# of the repository or by using the `bun update-version` command.

set -euo pipefail

current_tag=$(git describe --tags --abbrev=0)

# Increment the patch version
LATEST_TAG=$(echo "$current_tag" | sed 's/^v//' | awk -F. '{print $1"."$2"."$3+1}') || exit $?

# List directories with changes that are not README.md or test files
mapfile -t changed_dirs < <(git diff --name-only "$current_tag" -- ':!**/README.md' ':!**/*.test.ts' | xargs dirname | grep -v '^\.' | sort -u)

echo "Directories with changes: ${changed_dirs[*]}"

# Iterate over directories and update version in README.md
for dir in "${changed_dirs[@]}"; do
  if [[ -f "$dir/README.md" ]]; then
    file="$dir/README.md"
    tmpfile=$(mktemp /tmp/tempfile.XXXXXX)
    awk -v tag="$LATEST_TAG" '
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

    # Check if the README.md file has changed
    if ! git diff --quiet -- "$dir/README.md"; then
      echo "Bumping version in $dir/README.md from $current_tag to $LATEST_TAG (incremented)"
    else
      echo "Version in $dir/README.md is already up to date"
    fi
  fi
done
