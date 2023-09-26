#!/usr/bin/env sh

BOLD='\033[0;1m'
# CODE='\033[36;40;1m'
# RESET='\033[0m'

printf "$${BOLD}Checking git-config!\n"

# Check if git is installed
command -v git >/dev/null 2>&1 || {
    echo "git is not installed! Install git to sync username and email."
    exit 1
}

# Set git username and email if not set
if [ -z $(git config --get user.email) ]; then
    printf "git-config: No user.email found, setting to ${CODER_EMAIL}"
    git config --global user.email ${CODER_EMAIL}
fi

if [ -z $(git config --get user.name) ]; then
    printf "git-config: No user.name found, setting to ${CODER_USERNAME}"
    git config --global user.name ${CODER_USERNAME}
fi

printf "$${BOLD}git-config: using username: $(git config --get user.name)"
printf "$${BOLD}git-config: using email: $(git config --get user.email)"
