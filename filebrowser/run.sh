#!/usr/bin/env bash

BOLD='\033[0;1m'
printf "$${BOLD}Installing filebrowser \n\n"

curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash

printf "🥳 Installation complete! \n\n"

printf "👷 Starting filebrowser in background... \n\n"

ROOT_DIR=${FOLDER}
ROOT_DIR=$${ROOT_DIR/\~/$HOME}

DB_FLAG=""
if [ "${DB_PATH}" != "filebrowser.db" ]; then
  DB_FLAG=" -d ${DB_PATH}"
fi

# set baseurl if subdomain = false
if [ "${SUBDOMAIN}" == "false" ]; then
  filebrowser config set --baseurl "/@${OWNER_NAME}/${WORKSPACE_NAME}.${RESOURCE_NAME}/apps/filebrowser" > ${LOG_PATH} 2>&1
else
  filebrowser config set --baseurl "" > ${LOG_PATH} 2>&1
fi

printf "📂 Serving $${ROOT_DIR} at http://localhost:${PORT} \n\n"

printf "Running 'filebrowser --noauth --root $ROOT_DIR --port ${PORT}$${DB_FLAG}' \n\n"

filebrowser --noauth --root $ROOT_DIR --port ${PORT}$${DB_FLAG} > ${LOG_PATH} 2>&1 &

printf "📝 Logs at ${LOG_PATH} \n\n"
