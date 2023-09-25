#!/usr/bin/env sh

BOLD='\033[0;1m'

printf "$${BOLD} Installing vscode-server!\n"
# Download and extract vsode-server tarball
HASH=$(curl https://update.code.visualstudio.com/api/commits/stable/server-linux-x64-web | cut -d '"' -f 2)
output=$(wget -O- https://az764295.vo.msecnd.net/stable/$HASH/vscode-server-linux-x64-web.tar.gz | tar -xz -C ${INSTALL_DIR} --strip-components=1 >/dev/null 2>&1)
if [ $? -ne 0 ]; then
  echo "Failed to install vscode-server: $output"
  exit 1
fi
printf "🥳 vscode-server has been installed.\n\n"

echo "👷 Running ${INSTALL_DIR}/bin/code serve-web --port ${PORT} --without-connection-token --accept-server-license-terms in the background..."
echo "Check logs at ${LOG_PATH}!"
${INSTALL_DIR}/bin/code-server serve-local --port ${PORT} --without-connection-token --accept-server-license-terms >${LOG_PATH} 2>&1 &
