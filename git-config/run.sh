#!/usr/bin/env sh

# Convert templated variables to shell variables
GIT_EMAIL=${GIT_EMAIL}
GIT_USERNAME=${GIT_USERNAME}

BOLD='\033[0;1m'
printf "$${BOLD}Checking git-config!\n\n"

# Check if git is installed
command -v git > /dev/null 2>&1 || {
  echo "Git is not installed!"
  exit 1
}

# Set git username and email if missing
if [ -z "$(git config --get user.email)" ]; then
  printf "git-config: No user.email found, setting to %s\n" "$${GIT_EMAIL}"
  git config --global user.email "$${GIT_EMAIL}"
fi

if [ -z "$(git config --get user.name)" ]; then
  printf "git-config: No user.name found, setting to $${GIT_USERNAME}\n\n"
  git config --global user.name "$${GIT_USERNAME}"
fi

printf "$${BOLD}git-config: using email: $(git config --get user.email)\n"
printf "$${BOLD}git-config: using username: $(git config --get user.name)\n\n"
