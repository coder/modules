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
fi



"

echo "Starting ${MODULE_NAME}..."
# Start the app in here
# 1. Use & to run it in background
# 2. redirct stdout and stderr to log files

./app >${LOG_PATH} 2>&1 &

echo "Sample app started!"
