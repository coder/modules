#!/usr/bin/env sh

echo "Instalalting MODULE_NAME..."
# Add code here
# Use varibles from the templatefile function in main.tf
# e.g. LOG_PATH, PORT, etc.

echo "Installation comlete!"

echo "Starting MODULE_NAME..."
# Start the app in here
# 1. Use & to run it in background
# 2. redirct stdout and stderr to log files

./app >${LOG_PATH} 2>&1 &

echo "MODULE_NAME Started!"
echo "check logs at ${LOG_PATH}"
