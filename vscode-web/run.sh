#!/usr/bin/env sh

BOLD='\033[0;1m'
# check if VS Code is installed
if
  ! command -v code &
  >/dev/null
then
  printf "$${BOLD}Installing VS Code!\n"
  output=$(curl -L "https://update.code.visualstudio.com/${VERSION}/linux-deb-x64/stable" -o /tmp/code.deb && sudo apt-get update && sudo apt-get install -y /tmp/code.deb)
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
