#!/usr/bin/env sh

# If @devcontainers/cli is already installed, we can skip
if command -v devcontainer > /dev/null 2>&1; then
  echo "🥳 @devcontainers/cli is already installed into $(which devcontainer)!"
  exit 0
fi

# Check if docker is installed
if ! command -v docker > /dev/null 2>&1; then
  echo "WARNING: Docker was not found but is required to use @devcontainers/cli, please make sure it is available."
fi

# Determine the package manager to use: npm, pnpm, or yarn
if command -v pnpm > /dev/null 2>&1; then
  PACKAGE_MANAGER="pnpm"
elif command -v yarn > /dev/null 2>&1; then
  PACKAGE_MANAGER="yarn"
elif command -v npm > /dev/null 2>&1; then
  PACKAGE_MANAGER="npm"
else
  echo "No supported package manager (npm, pnpm, yarn) is installed. Please install one first."
  exit 1
fi

echo "Installing @devcontainers/cli using $PACKAGE_MANAGER..."

# Install @devcontainers/cli using the selected package manager
if [ "$PACKAGE_MANAGER" = "npm" ] || [ "$PACKAGE_MANAGER" = "pnpm" ]; then
  $PACKAGE_MANAGER install -g @devcontainers/cli \
    && echo "🥳 @devcontainers/cli has been installed into $(which devcontainer)!"
elif [ "$PACKAGE_MANAGER" = "yarn" ]; then
  $PACKAGE_MANAGER global add @devcontainers/cli \
    && echo "🥳 @devcontainers/cli has been installed into $(which devcontainer)!"
fi

exit 0
