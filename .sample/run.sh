#!/usr/bin/env sh

BOLD='\033[0;1m'
printf "$${BOLD}Installing MODULE_NAME ...\n\n"
# Add code here
# Use varibles from the templatefile function in main.tf
# e.g. LOG_PATH, PORT, etc.

printf "🥳 Installation comlete!\n\n"

printf "👷 Starting MODULE_NAME in background...\n\n"
# Start the app in here
# 1. Use & to run it in background
# 2. redirct stdout and stderr to log files

./app >${LOG_PATH} 2>&1 &

printf "check logs at ${LOG_PATH} \n\n"
