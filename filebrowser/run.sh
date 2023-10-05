#!/usr/bin/env sh

BOLD='\033[0;1m'
printf "$${BOLD}Installing filebrowser \n\n"

curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash

printf "🥳 Installation comlete! \n\n"

printf "👷 Starting filebrowser in background... \n\n"

ROOT_DIR=${FOLDER}
ROOT_DIR=$${ROOT_DIR/\~/$HOME}

# Set the database flag if DB_PATH is set
DB_FLAG=""
if [ -z "${DB_PATH}" ]; then
  echo "DB_PATH is empty"
else
  DB_FLAG="-d ${DB_PATH}"
fi

printf "📂 Serving $${ROOT_DIR} at http://localhost:${PORT} \n\n"

printf "Running 'filebrowser --noauth --root $ROOT_DIR --port ${PORT}$${DB_FLAG}' \n\n" #  -d ${DB_PATH}

filebrowser --noauth --root $ROOT_DIR --port ${PORT} >${LOG_PATH}$${DB_FLAG} 2>&1 & #  -d ${DB_PATH} 

printf "📝 Logs at ${LOG_PATH} \n\n"
