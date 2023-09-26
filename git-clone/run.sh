#!/usr/bin/env sh

REPO_URL="${REPO_URL}"
CLONE_PATH="${CLONE_PATH}"
# Expand home if it's specified!
CLONE_PATH="$${CLONE_PATH/#\~/$${HOME}}"

# Check if the variable is empty...
if [ -z "$REPO_URL" ]; then
  echo "No repository specified!"
  exit 1
fi

# Check if the variable is empty...
if [ -z "$CLONE_PATH" ]; then
  echo "No clone path specified!"
  exit 1
fi

# Check if `git` is installed...
if ! command -v git >/dev/null; then
  echo "Git is not installed!"
  exit 1
fi

# Check if the directory exists...
if [ ! -d "$CLONE_PATH" ]; then
  echo "Creating directory $CLONE_PATH..."
  mkdir -p "$CLONE_PATH"
else
  echo "$CLONE_PATH already exists, skipping clone!"
  exit 0
fi

# Clone the repository...
echo "Cloning $REPO_URL to $CLONE_PATH..."
git clone "$REPO_URL" "$CLONE_PATH"

