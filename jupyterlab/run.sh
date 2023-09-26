#!/usr/bin/env sh

BOLD='\033[0;1m'

echo "$${BOLD}Installing jupyterlab!\n"

# check if jupyterlab is installed
if ! command -v jupyterlab & >/dev/null; then
    # install jupyterlab
    # check if python3 pip is installed
    if ! command -v pip3 & >/dev/null; then
        echo "pip3 is not installed"
        echo "Installing pip3..."
        sudo apt-get update && sudo apt-get install python3-pip -y
    fi
    # install jupyterlab
    pip3 install --user -q --yes jupyterlab
    echo "🥳 jupyterlab has been installed\n\n"
else
    echo "🥳 jupyterlab is already installed\n\n"
fi

echo "👷 Starting jupyterlab in background..."
echo "check logs at ${LOG_PATH}"
$HOME/.local/bin/jupyter lab --no-browser --LabApp.token='' --LabApp.password='' >${LOG_PATH} 2>&1 &
