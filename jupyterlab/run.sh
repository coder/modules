#!/usr/bin/env sh

if [ -n "${BASE_URL}" ]; then
  BASE_URL_FLAG="--ServerApp.base_url=${BASE_URL}"
fi

BOLD='\033[0;1m'

printf "$${BOLD}Installing jupyterlab!\n"

# check if jupyterlab is installed
if ! command -v jupyter-lab > /dev/null 2>&1; then
  # install jupyterlab
  # check if pipx is installed
  if ! command -v pipx > /dev/null 2>&1; then
    echo "pipx is not installed"
    echo "Please install pipx in your Dockerfile/VM image before running this script"
    exit 1
  fi
  # install jupyterlab
  pipx install -q jupyterlab
  printf "%s\n\n" "🥳 jupyterlab has been installed"
else
  printf "%s\n\n" "🥳 jupyterlab is already installed"
fi

printf "👷 Starting jupyterlab in background..."
printf "check logs at ${LOG_PATH}"
$HOME/.local/bin/jupyter-lab --no-browser \
  "$BASE_URL_FLAG" \
  --ServerApp.ip='*' \
  --ServerApp.port="${PORT}" \
  --ServerApp.token='' \
  --ServerApp.password='' \
  > "${LOG_PATH}" 2>&1 &
