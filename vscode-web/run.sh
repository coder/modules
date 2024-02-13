#!/usr/bin/env bash

BOLD='\033[0;1m'
EXTENSIONS=("${EXTENSIONS}")

# Create install prefix
mkdir -p ${INSTALL_PREFIX}

printf "$${BOLD}Installing Microsoft Visual Studio Code Server!\n"

# Download and extract vscode-server
ARCH=$(uname -m)
case "$ARCH" in
  x86_64) ARCH="x64" ;;
  aarch64) ARCH="arm64" ;;
  *)
    echo "Unsupported architecture"
    exit 1
    ;;
esac

HASH=$(curl https://update.code.visualstudio.com/api/commits/stable/server-linux-$ARCH-web | cut -d '"' -f 2)
outut=$(curl -sL https://vscode.download.prss.microsoft.com/dbazure/download/stable/$HASH/vscode-server-linux-$ARCH-web.tar.gz | tar -xz -C ${INSTALL_PREFIX} --strip-components 1 && rm -rf vscode-server-linux-$ARCH-web.tar.gz)

if [ $? -ne 0 ]; then
  echo "Failed to install vscode-server: $output"
  exit 1
fi
printf "🥳 vscode-server has been installed in ${INSTALL_PREFIX}"

VSCODE_SERVER="${INSTALL_PREFIX}/bin/code-server"

# Install each extension...
IFS=',' read -r -a EXTENSIONLIST <<< "$${EXTENSIONS}"
for extension in "$${EXTENSIONLIST[@]}"; do
  if [ -z "$extension" ]; then
    continue
  fi
  printf "🧩 Installing extension $${CODE}$extension$${RESET}...\n"
  output=$($VSCODE_SERVER --install-extension "$extension" --force)
  if [ $? -ne 0 ]; then
    echo "Failed to install extension: $extension: $output"
    exit 1
  fi
done

echo "👷 Running ${INSTALL_PREFIX}/bin/code-server

echo "Check logs at ${LOG_PATH}!"
${INSTALL_PREFIX}/code serve-local --port ${PORT} --accept-server-license-terms serve-local --without-connection-token --telemetry-level ${TELEMETRY_LEVEL} > ${LOG_PATH} 2>&1 &


