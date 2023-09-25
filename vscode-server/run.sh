#!/usr/bin/env sh

BOLD='\033[0;1m'

# Create install directory if it doesn't exist
mkdir -p ${INSTALL_DIR}

printf "$${BOLD}Installing vscode-server!\n"
# Fetch the latest commit hash for stable release
HASH=$(curl -s https://update.code.visualstudio.com/api/commits/stable/server-linux-x64-web | cut -d '"' -f 2)

# Download and extract vscode-server tarball
output=$(wget -O /tmp/vscode-server-linux-x64-web.tar.gz https://az764295.vo.msecnd.net/stable/$HASH/vscode-server-linux-x64-web.tar.gz &&
  tar -xzf /tmp/vscode-server-linux-x64-web.tar.gz -C ${INSTALL_DIR} --strip-components=1)

if [ $? -ne 0 ]; then
  echo "Failed to install vscode-server: $output"
  exit 1
fi
printf "🥳 vscode-server has been installed.\n\n"

echo "👷 Running ${INSTALL_DIR}/bin/code serve-web --port ${PORT} --without-connection-token --accept-server-license-terms in the background..."
echo "Check logs at ${LOG_PATH}!"
${INSTALL_DIR}/bin/code-server serve-local --port ${PORT} --without-connection-token --accept-server-license-terms --telemetry-level ${TELEMETRY} >${LOG_PATH} 2>&1 &
