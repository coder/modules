#!/usr/bin/env bash

# This script updates the version number in the README.md files of all modules
# to the latest tag in the repository. It is intended to be run from the root
# of the repository or by using the `bun update-version` command.

set -euo pipefail

LATEST_TAG=$(git describe --abbrev=0 --tags | sed 's/^v//') || exit $?

find . -name README.md | while read -r file; do
  tmpfile=$(mktemp /tmp/tempfile.XXXXXX)
  awk -v tag="$LATEST_TAG" '{
    if ($1 == "version" && $2 == "=") {
      sub(/"[^"]*"/, "\"" tag "\"")
      print
    } else {
      print
    }
  }' "$file" > "$tmpfile" && mv "$tmpfile" "$file"
done
