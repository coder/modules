#!/usr/bin/env sh

# BOLD='\033[0;1m'
# CODE='\033[36;40;1m'
# RESET='\033[0m'
# CODER_EMAIL="${CODER_EMAIL}"
# CODER_USERNAME="${CODER_USERNAME}"

echo "Running git-config script!\n\n"

# Check if git is installed
command -v git >/dev/null 2>&1 || {
    echo "git is not installed"
}

# Fetch and print user.name and user.email
git_username=$(git config --get user.name)
git_useremail=$(git config --get user.email)

# Set git username and email if not set
if [ -z $(git config --get user.name) ]; then
    echo "git-config: No user.email found, setting to ${CODER_EMAIL}"
    git config --global user.email "${CODER_EMAIL}"
fi

if [ -z $(git config --get user.email) ]; then
    echo "git-config: No user.name found, setting to ${CODER_USERNAME}"
    git config --global user.name "${CODER_USERNAME}"
fi

echo "git-config: using username: {$(git config --get user.name)}"
echo "git-config: using email: $(git config --get user.email)"
