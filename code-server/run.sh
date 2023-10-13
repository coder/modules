#!/usr/bin/env bash

EXTENSIONS=("${EXTENSIONS}")
BOLD='\033[0;1m'
CODE='\033[36;40;1m'
RESET='\033[0m'

printf "$${BOLD}Installing code-server!\n"

ARGS=(
  "--method=standalone"
  "--prefix=${INSTALL_PREFIX}"
)
if [ -n "${VERSION}" ]; then
  ARGS+=("--version=${VERSION}")
fi

output=$(curl -fsSL https://code-server.dev/install.sh | sh -s -- "$${ARGS[@]}")
if [ $? -ne 0 ]; then
  echo "Failed to install code-server: $output"
  exit 1
fi
printf "🥳 code-server has been installed in ${INSTALL_PREFIX}\n\n"

CODE_SERVER="${INSTALL_PREFIX}/bin/code-server"

# Install each extension...
for extension in "$${EXTENSIONS[@]}"; do
  if [ -z "$extension" ]; then
    continue
  fi
  printf "🧩 Installing extension $${CODE}$extension$${RESET}...\n"
  output=$($CODE_SERVER --install-extension "$extension")
  if [ $? -ne 0 ]; then
    echo "Failed to install extension: $extension: $output"
    exit 1
  fi
done

# Check if the settings file exists...
if [ ! -f ~/.local/share/code-server/Machine/settings.json ]; then
  echo "⚙️ Creating settings file..."
  mkdir -p ~/.local/share/code-server/Machine
  echo "${SETTINGS}" >~/.local/share/code-server/Machine/settings.json
fi

echo "👷 Running code-server in the background..."
echo "Check logs at ${LOG_PATH}!"
$CODE_SERVER --auth none --port ${PORT} >${LOG_PATH} 2>&1 &