#!/usr/bin/env sh

BOLD='\033[0;1m'
printf "$${BOLD}Installing filebrowser \n\n"

curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash

echo "🥳 Installation comlete! \n\n"

echo "👷 Starting filebrowser in background... \n\n"

ROOT_DIR=${FOLDER}
ROOT_DIR=$${ROOT_DIR/\~/$HOME}

echo "📂 Serving $${ROOT_DIR} at http://localhost:${PORT} \n\n"

echo "Running 'filebrowser --noauth --root $ROOT_DIR --port ${PORT}' \n\n"

filebrowser --noauth --root $ROOT_DIR --port ${PORT} >${LOG_PATH} 2>&1 &

echo "📝 Logs at ${LOG_PATH} \n\n"
