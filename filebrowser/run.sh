#!/usr/bin/env sh

BOLD='\033[0;1m'
echo "$${BOLD}Installing filebrowser..."

curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash

echo "🥳 Installation comlete!"

echo "👷 Starting filebrowser in background..."

ROOT_DIR=${FOLDER}
ROOT_DIR=${ROOT_DIR/\~/$HOME}

filebrowser --noauth --root $ROOT_DIR --port ${PORT} >${LOG_PATH} 2>&1 &

echo "check logs at ${LOG_PATH}"
