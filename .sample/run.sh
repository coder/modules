#!/usr/bin/env sh

BOLD='\033[0;1m'
echo "$${BOLD}Installing MODULE_NAME..."
# Add code here
# Use varibles from the templatefile function in main.tf
# e.g. LOG_PATH, PORT, etc.

echo "🥳 Installation comlete!"

echo "👷 Starting MODULE_NAME in background..."
# Start the app in here
# 1. Use & to run it in background
# 2. redirct stdout and stderr to log files

./app >${LOG_PATH} 2>&1 &

echo "check logs at ${LOG_PATH}"
