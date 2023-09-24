#!/usr/bin/env sh

echo "Instalalting ${MODULE_NAME}..."

# check if jupyterlab is installed
if ! command -v jupyterlab &> /dev/null then
    #  install jupyterlab
    # check if python3 pip is installed
    if ! command -v pip3 &> /dev/null then
        echo "pip3 is not installed"
        echo "Please install pip3 and try again"
        exit 1
    fi
    pip3 install jupyterlab
    echo "jupyterlab installed!"
fi

echo "Starting ${MODULE_NAME}..."

$HOME/.local/bin/jupyter lab --no-browser --LabApp.token='' --LabApp.password='' >${LOG_PATH} 2>&1 &

echo "Started ${MODULE_NAME}!"
