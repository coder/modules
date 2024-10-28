#!/usr/bin/env bash

BOLD='\033[0;1m'

# Check if filebrowser is installed
if command -v filebrowser &> /dev/null; then
    printf "🥳 Filebrowser is already installed. Skipping installation.\n\n$"
else
    printf "$${BOLD}Installing Filebrowser...\n\n"

    # Install Filebrowser
    if curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash; then
        printf "🥳 Installation complete! Filebrowser is now installed.\n\n"
    else
        printf "❌ Installation failed! Please check the logs.\n\n"
        exit 1
    fi
fi

printf "👷 Starting filebrowser in background... \n\n"

ROOT_DIR=${FOLDER}
ROOT_DIR=$${ROOT_DIR/\~/$HOME}

DB_FLAG=""
if [ "${DB_PATH}" != "filebrowser.db" ]; then
  DB_FLAG=" -d ${DB_PATH}"
fi

# set baseurl to be able to run if sudomain=false; if subdomain=true the SERVER_BASE_PATH value will be ""
filebrowser config set --baseurl "${SERVER_BASE_PATH}"$${DB_FLAG} > ${LOG_PATH} 2>&1

printf "📂 Serving $${ROOT_DIR} at http://localhost:${PORT} \n\n"

printf "Running 'filebrowser --noauth --root $ROOT_DIR --port ${PORT}$${DB_FLAG}' \n\n"

filebrowser --noauth --root $ROOT_DIR --port ${PORT}$${DB_FLAG} > ${LOG_PATH} 2>&1 &

printf "📝 Logs at ${LOG_PATH} \n\n"
