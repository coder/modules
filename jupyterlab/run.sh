#!/usr/bin/env sh

echo "Installing jupyterlab..."

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
    pip3 install --user -q -y jupyterlab
    echo "jupyterlab installed."
else
    echo "jupyterlab is already installed."
fi

echo "Starting jupyterlab..."

$HOME/.local/bin/jupyter lab --no-browser --LabApp.token='' --LabApp.password='' >${LOG_PATH} 2>&1 &

echo "jupyterlab Started!"

echo "check logs at ${LOG_PATH}"
