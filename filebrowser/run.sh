#!/usr/bin/env bash

BOLD='\033[[0;1m'

printf "$${BOLD}Installing filebrowser \n\n"

# Check if filebrowser is installed
if ! command -v filebrowser &> /dev/null; then
  curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash
fi

printf "🥳 Installation complete! \n\n"

printf "🛠️  Configuring filebrowser \n\n"

ROOT_DIR=${FOLDER}
ROOT_DIR=$${ROOT_DIR/\~/$HOME}

DB_FLAG=""
if [[ "${DB_PATH}" != "filebrowser.db" ]]; then
  DB_FLAG=" -d ${DB_PATH}"
fi

# Check if filebrowser db exists
if [[ ! -f ${DB_PATH} ]]; then
  filebrowser $DB_FLAG config init  2>&1 | tee -a ${LOG_PATH}
  filebrowser $DB_FLAG users add admin "" --perm.admin=true --viewMode=mosaic 2>&1 | tee -a ${LOG_PATH} 
fi

filebrowser $DB_FLAG config set --baseurl=${SERVER_BASE_PATH} --port=${PORT} --auth.method=noauth --root=$ROOT_DIR 2>&1 | tee -a ${LOG_PATH} 

printf "👷 Starting filebrowser in background... \n\n"


printf "📂 Serving $${ROOT_DIR} at http://localhost:${PORT} \n\n"

printf "Running 'filebrowser %s' \n\n" "$DB_FLAG"

filebrowser $DB_FLAG >> ${LOG_PATH} 2>&1 &

printf "📝 Logs at ${LOG_PATH} \n\n"
