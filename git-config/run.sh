#!/usr/bin/env sh

BOLD='\033[0;1m'
printf "$${BOLD}Checking git-config!\n"

# Check if git is installed
command -v git >/dev/null 2>&1 || {
    echo "git is not installed! Install git to sync username and email.\n"
    exit 1
}

# Set git username and email if missing
if [ -z $(git config --get user.email) ]; then
    printf "git-config: No user.email found, setting to ${CODER_EMAIL}\n"
    git config --global user.email "${CODER_EMAIL}"
fi

if [ -z $(git config --get user.name) ]; then
    printf "git-config: No user.name found, setting to ${CODER_USERNAME}\n"
    git config --global user.name "${CODER_USERNAME}"
fi

printf "\n$${BOLD}git-config: using username: $(git config --get user.name)\n"
printf "$${BOLD}git-config: using email: $(git config --get user.email)\n\n"
