#!/usr/bin/env bash

EXTENSIONS=("${EXTENSIONS}")
BOLD='\033[0;1m'
CODE='\033[36;40;1m'
RESET='\033[0m'
CODE_SERVER="${INSTALL_PREFIX}/bin/code-server"

function run_code_server() {
  echo "👷 Running code-server in the background..."
  echo "Check logs at ${LOG_PATH}!"
  $CODE_SERVER --auth none --port "${PORT}" --app-name "${APP_NAME}" > "${LOG_PATH}" 2>&1 &
}

# Check if the settings file exists...
if [ ! -f ~/.local/share/code-server/User/settings.json ]; then
  echo "⚙️ Creating settings file..."
  mkdir -p ~/.local/share/code-server/User
  echo "${SETTINGS}" > ~/.local/share/code-server/User/settings.json
fi

# Check if code-server is already installed for offline or cached mode
if [ -f "$CODE_SERVER" ]; then
  if [ "${OFFLINE}" = true ] || [ "${USE_CACHED}" = true ]; then
    echo "🥳 Found a copy of code-server"
    run_code_server
    exit 0
  fi
fi
# Offline mode always expects a copy of code-server to be present
if [ "${OFFLINE}" = true ]; then
  echo "Failed to find a copy of code-server"
  exit 1
fi

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

# Install each extension...
IFS=',' read -r -a EXTENSIONLIST <<< "$${EXTENSIONS}"
for extension in "$${EXTENSIONLIST[@]}"; do
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

run_code_server
