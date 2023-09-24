#!/usr/bin/env sh

BOLD='\033[0;1m'
# check if
printf "$${BOLD}Installing VS Code!\n"
output=$(curl -L "https://update.code.visualstudio.com/${VERSION}/linux-deb-x64/stable" -o /tmp/code.deb && sudo dpkg -i /tmp/code.deb && sudo apt-get install -f -y)
if [ $? -ne 0 ]; then
  echo "Failed to install VS Code: $output"
  exit 1
fi
printf "🥳 VS code has been installed.\n\n"

echo "👷 Running code serve-web in the background..."
echo "Check logs at ${LOG_PATH}!"
code serve-web --port ${PORT} --without-connection-token --accept-server-license-terms >${LOG_PATH} 2>&1 &
