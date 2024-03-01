#!/usr/bin/env bash

NODE_VERSIONS=("${NODE_VERSIONS}")
BOLD='\033[0;1m'
CODE='\033[36;40;1m'
RESET='\033[0m'

printf "${BOLD}Installing nvm!${RESET}\n"

output=$(curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh | NVM_DIR=${INSTALL_PREFIX} bash)
if [ $? -ne 0 ]; then
  echo "Failed to install nvm: $output"
  exit 1
fi
printf "🥳 nvm has been installed\n\n"

NVM="${INSTALL_PREFIX}/nvm.sh"

# Set up nvm in the current shell session
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install each node version...
IFS=',' read -r -a VERSIONLIST <<< "${NODE_VERSIONS}"
for version in "${VERSIONLIST[@]}"; do
  if [ -z "$version" ]; then
    continue
  fi
  printf "🛠️ Installing node version ${CODE}$version${RESET}...\n"
  output=$(nvm install "$version")
  if [ $? -ne 0 ]; then
    echo "Failed to install version: $version: $output"
    exit 1
  fi
done

# Set default if provided
if [ -n "${DEFAULT}" ]; then
  printf "🛠️ Setting default node version ${CODE}$DEFAULT${RESET}...\n"
  output=$(nvm alias default $DEFAULT)
fi
