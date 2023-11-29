#!/usr/bin/env sh

BOLD='\033[0;1m'

# Convert templated variables to shell variables
PORT=${PORT}
LOG_PATH=${LOG_PATH}
INSTALL_DIR=${INSTALL_DIR}


# Create install directory if it doesn't exist
mkdir -p "$${INSTALL_DIR}"

printf "$${BOLD}Installing vscode-cli!\n"

# Download and extract code-cli tarball
output=$(curl -Lk 'https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64' --output vscode_cli.tar.gz && tar -xf vscode_cli.tar.gz -C "$${INSTALL_DIR}" && rm vscode_cli.tar.gz)

if [ $? -ne 0 ]; then
  echo "Failed to install vscode-cli: $output"
  exit 1
fi
printf "🥳 vscode-cli has been installed.\n\n"

printf "Check logs at %s\n\n" "$${LOG_PATH}"
"$${INSTALL_DIR}/code" serve-web --port "$${PORT}" --without-connection-token --accept-server-license-terms > "$${LOG_PATH}" 2>&1 &
