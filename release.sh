#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 [OPTIONS] [<MODULE> <VERSION>]

Create annotated git tags for module releases.

This script is used by maintainers to create annotated tags for module 
releases. When a tag is pushed, it triggers a GitHub workflow that 
updates README versions.

Options:
  -l, --list     List all modules with their versions
  -n, --dry-run  Show what would be done without making changes
  -p, --push     Push the created tag to the remote repository
  -h, --help     Show this help message

Examples:
  $0 --list
  $0 nodejs 1.2.3
  $0 nodejs 1.2.3 --push
  $0 --dry-run nodejs 1.2.3
EOF
  exit "${1:-0}"
}

check_getopt() {
  # Check if we have GNU or BSD getopt.
  if getopt --test >/dev/null 2>&1; then
    # Exit status 4 means GNU getopt is available.
    if [[ $? -ne 4 ]]; then
      echo "Error: GNU getopt is not available." >&2
      echo "On macOS, you can install GNU getopt and add it to your PATH:" >&2
      echo
      echo $'\tbrew install gnu-getopt' >&2
      echo $'\texport PATH="$(brew --prefix gnu-getopt)/bin:$PATH"' >&2
      exit 1
    fi
  fi
}

maybe_dry_run() {
  if [[ $dry_run == true ]]; then
    echo "[DRY RUN] $*"
    return 0
  fi
  "$@"
}

get_readme_version() {
  grep -o 'version *= *"[0-9]\+\.[0-9]\+\.[0-9]\+"' "$1" |
    head -1 |
    grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' ||
    echo "0.0.0"
}

list_modules() {
  printf "\nListing all modules and their latest versions:\n"
  printf "%s\n" "--------------------------------------------------------------"
  printf "%-30s %-15s %-15s\n" "MODULE" "README VERSION" "LATEST TAG"
  printf "%s\n" "--------------------------------------------------------------"

  # Process each module directory.
  for dir in */; do
    # Skip non-module directories.
    [[ ! -d $dir || ! -f ${dir}README.md || $dir == ".git/" ]] && continue

    module="${dir%/}"
    readme_version=$(get_readme_version "${dir}README.md")
    latest_tag=$(git tag -l "release/${module}/v*" | sort -V | tail -n 1)
    tag_version="none"
    if [[ -n $latest_tag ]]; then
      tag_version="${latest_tag#"release/${module}/v"}"
    fi

    printf "%-30s %-15s %-15s\n" "$module" "$readme_version" "$tag_version"
  done

  printf "%s\n" "--------------------------------------------------------------"
}

is_valid_version() {
  if ! [[ $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: Version must be in format X.Y.Z (e.g., 1.2.3)" >&2
    return 1
  fi
}

get_tag_name() {
  local module="$1"
  local version="$2"
  local tag_name="release/$module/v$version"
  local readme_path="$module/README.md"

  if [[ ! -d $module || ! -f $readme_path ]]; then
    echo "Error: Module '$module' not found or missing README.md" >&2
    return 1
  fi

  local readme_version
  readme_version=$(get_readme_version "$readme_path")

  {
    echo "Module: $module"
    echo "Current README version: $readme_version"
    echo "New tag version: $version"
    echo "Tag name: $tag_name"
  } >&2

  echo "$tag_name"
}

# Ensure getopt is available.
check_getopt

# Set defaults.
list=false
dry_run=false
push=false
module=
version=

# Parse command-line options.
if ! temp=$(getopt -o ldph --long list,dry-run,push,help -n "$0" -- "$@"); then
  echo "Error: Failed to parse arguments" >&2
  usage 1
fi
eval set -- "$temp"

while true; do
  case "$1" in
  -l | --list)
    list=true
    shift
    ;;
  -d | --dry-run)
    dry_run=true
    shift
    ;;
  -p | --push)
    push=true
    shift
    ;;
  -h | --help)
    usage
    ;;
  --)
    shift
    break
    ;;
  *)
    echo "Error: Internal error!" >&2
    exit 1
    ;;
  esac
done

if [[ $list == true ]]; then
  list_modules
  exit 0
fi

if [[ $# -ne 2 ]]; then
  echo "Error: MODULE and VERSION are required when not using --list" >&2
  usage 1
fi

module="$1"
version="$2"

if ! is_valid_version "$version"; then
  exit 1
fi

if ! tag_name=$(get_tag_name "$module" "$version"); then
  exit 1
fi

if git rev-parse -q --verify "refs/tags/$tag_name" >/dev/null 2>&1; then
  echo "Notice: Tag '$tag_name' already exists" >&2
else
  maybe_dry_run git tag -a "$tag_name" -m "Release $module v$version"
  if [[ $push == true ]]; then
    maybe_dry_run echo "Tag '$tag_name' created."
  else
    maybe_dry_run echo "Tag '$tag_name' created locally. Use --push to push it to remote."
    maybe_dry_run "ℹ️ Note: Remember to push the tag when ready."
  fi
fi

if [[ $push == true ]]; then
  maybe_dry_run git push origin "$tag_name"
  maybe_dry_run echo "Success! Tag '$tag_name' pushed to remote."
fi
