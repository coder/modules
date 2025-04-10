#!/usr/bin/env sh

echo "Installing @devcontainers/cli ..."

# If @devcontainers/cli is already installed, we can skip
if command -v devcontainers > /dev/null 2>&1; then
  echo "🥳 @devcontainers/cli is already installed"
  exit 1
fi

# If npm is not installed, we should skip
if ! command -v npm > /dev/null 2>&1; then
  echo "npm is not installed, please install npm first"
  exit 1
fi

# If @devcontainers/cli is not installed, we should install it
echo "Running npm install -g @devcontainers/cli ..."
npm install -g @devcontainers/cli \
  && echo "🥳 @devcontainers/cli has been installed !"

exit 0
