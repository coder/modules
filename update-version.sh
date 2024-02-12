#!/usr/bin/env bash

# This script updates the version number in the README.md files of all modules
# to the latest tag in the repository. It is intended to be run from the root
# of the repository or by using the `bun update-version` command.

set -euo pipefail

current_tag=$(git describe --tags --abbrev=0)
previous_tag=$(git describe --tags --abbrev=0 $current_tag^)
changed_files=$(git diff --name-only "$previous_tag" "$current_tag")

changed_dirs=()
for file in $changed_files; do
  dir=$(dirname "$file")
  changed_dirs+=("$dir")
done
changed_dirs=($(printf "%s\n" "${changed_dirs[@]}" | sort -u))

LATEST_TAG=$(git describe --abbrev=0 --tags | sed 's/^v//') || exit $?

for dir in "${changed_dirs[@]}"; do
  if [[ -f "$dir/README.md" ]]; then
    echo "Bumping version in $dir/README.md"
    file="$dir/README.md"
    tmpfile=$(mktemp /tmp/tempfile.XXXXXX)
    awk -v tag="$LATEST_TAG" '{
      if ($1 == "version" && $2 == "=") {
        sub(/"[^"]*"/, "\"" tag "\"")
        print
      } else {
        print
      }
    }' "$file" > "$tmpfile" && mv "$tmpfile" "$file"
  fi
done