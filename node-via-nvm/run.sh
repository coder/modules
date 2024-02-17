#!/usr/bin/env bash

NODE_VERSIONS=("${NODE_VERSIONS}")
BOLD='\033[0;1m'
CODE='\033[36;40;1m'
RESET='\033[0m'

printf "$${BOLD}Installing nvm!$${RESET}\n"

export NVM_DIR="${INSTALL_PREFIX}/nvm"

output=$(curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh | bash)
if [ $? -ne 0 ]; then
  echo "Failed to install nvm: $output"
  exit 1
fi
printf "🥳 nvm has been installed\n\n"

# Set up nvm in the current shell session
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install each node version...
IFS=',' read -r -a VERSIONLIST <<< "$${NODE_VERSIONS}"
for version in "$${VERSIONLIST[@]}"; do
  if [ -z "$version" ]; then
    continue
  fi
  printf "🛠️ Installing node version $${CODE}$version$${RESET}...\n"
  output=$(nvm install "$version")
  if [ $? -ne 0 ]; then
    echo "Failed to install version: $version: $output"
    exit 1
  fi
done

# Set default if provided
if [ -n "${DEFAULT}" ]; then
  printf "🛠️ Setting default node version $${CODE}$DEFAULT$${RESET}...\n"
  output=$(nvm alias default $DEFAULT)
fi
