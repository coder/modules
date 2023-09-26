#!/usr/bin/env sh

BOLD='\033[0;1m'

# Create install directory if it doesn't exist
mkdir -p ${INSTALL_DIR}

printf "$${BOLD}Installing vscode-cli!\n"

# Download and extract code-cli tarball
output=$(curl -Lk 'https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64' --output vscode_cli.tar.gz && tar -xf vscode_cli.tar.gz -C ${INSTALL_DIR} && rm vscode_cli.tar.gz)

if [ $? -ne 0 ]; then
  echo "Failed to install vscode-cli: $output"
  exit 1
fi
printf "🥳 vscode-cli has been installed.\n\n"

echo "👷 Running ${INSTALL_DIR}/bin/code serve-web --port ${PORT} --without-connection-token --accept-server-license-terms in the background..."
echo "Check logs at ${LOG_PATH}!"
${INSTALL_DIR}/code serve-web --port ${PORT} --without-connection-token --accept-server-license-terms >${LOG_PATH} 2>&1 &
