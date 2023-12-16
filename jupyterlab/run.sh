#!/usr/bin/env sh

BOLD='\033[0;1m'

printf "$${BOLD}Installing jupyterlab!\n"

# check if jupyterlab is installed
if ! command -v jupyterlab >/dev/null 2>&1; then
    # install jupyterlab
    # check if python3 pip is installed
    if ! command -v pip3 >/dev/null 2>&1; then
        echo "pip3 is not installed"
        echo "Please install pip3 in your Dockerfile/VM image before running this script"
        exit 1
    fi
    # install jupyterlab
    pip3 install --upgrade --no-cache-dir --no-warn-script-location jupyterlab
    echo "🥳 jupyterlab has been installed\n\n"
else
    echo "🥳 jupyterlab is already installed\n\n"
fi

echo "👷 Starting jupyterlab in background..."
echo "check logs at ${LOG_PATH}"
$HOME/.local/bin/jupyter lab --ServerApp.ip='0.0.0.0' --ServerApp.port=${PORT} --no-browser --ServerApp.token='' --ServerApp.password='' >${LOG_PATH} 2>&1 &
