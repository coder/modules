#!/usr/bin/env sh

BOLD='\033[0;1m'
printf "$${BOLD}Installing filebrowser \n\n"

curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash

printf "🥳 Installation comlete! \n\n"

printf "👷 Starting filebrowser in background... \n\n"

ROOT_DIR=${FOLDER}
ROOT_DIR=$${ROOT_DIR/\~/$HOME}

if [ -z "${DB_PATH}" ]; then
  echo "DB_PATH is empty"
#   DB_PATH=$${ROOT_DIR}/filebrowser.db
fi

printf "📂 Serving $${ROOT_DIR} at http://localhost:${PORT} \n\n"

printf "Running 'filebrowser --noauth --root $ROOT_DIR --port ${PORT}' \n\n" #  -d ${DB_PATH}

filebrowser --noauth --root $ROOT_DIR --port ${PORT} >${LOG_PATH} 2>&1 & #  -d ${DB_PATH} 

printf "📝 Logs at ${LOG_PATH} \n\n"
