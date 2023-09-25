#!/usr/bin/env sh

BOLD='\033[0;1m'

# Check if VS Code is installed
if [ ! -d "${INSTALL_DIR}" ]; then
  printf "${BOLD}Installing VS Code!\n"
  # Download and extract VS Code tarball
  output=$(curl -L "https://update.code.visualstudio.com/latest/linux-x64/stable" -o /tmp/code.tar.gz &&
    mkdir -p ${INSTALL_DIR} &&
    tar -xzf /tmp/code.tar.gz -C ${INSTALL_DIR} --strip-components=1)
  if [ $? -ne 0 ]; then
    echo "Failed to install VS Code: $output"
    exit 1
  fi
  printf "🥳 VS code has been installed.\n\n"
else
  printf "🥳 VS code is already installed.\n\n"
fi

echo "👷 Running code serve-web in the background..."
echo "Check logs at ${LOG_PATH}!"
code serve-web --port ${PORT} --without-connection-token --accept-server-license-terms >${LOG_PATH} 2>&1 &
