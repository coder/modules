#!/usr/bin/env bash

# Convert templated variables to shell variables
ROOT_DIR=${FOLDER}
PORT=${PORT}
DB_PATH=${DB_PATH}
LOG_PATH=${LOG_PATH}

# Expand ~ to $HOME
ROOT_DIR=$${ROOT_DIR/#\~/$${HOME}}

BOLD='\033[0;1m'

printf "$${BOLD}Installing filebrowser \n\n"

curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash

printf "🥳 Installation complete! \n\n"

printf "👷 Starting filebrowser in background... \n\n"

DB_FLAG=""
if [ "$${DB_PATH}" != "filebrowser.db" ]; then
  DB_FLAG="-d $${DB_PATH}"
fi

printf "📂 Serving %s at http://localhost:%s \n\n" "$${ROOT_DIR}" "$${PORT}"

filebrowser --noauth --root "$${ROOT_DIR}" --port "$${PORT}" "$${DB_FLAG}" > "$${LOG_PATH}" 2>&1 &

printf "📝 Logs at %s \n\n" "$${LOG_PATH}"
