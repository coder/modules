#!/usr/bin/env sh

# Convert templated variables to shell variables
CODER_AGENT_URL=${CODER_AGENT_URL}
CODER_AGENT_TOKEN=${CODER_AGENT_TOKEN}

if ! command -v git > /dev/null; then
  echo "git is not installed"
  exit 1
fi

if ! command -v curl > /dev/null; then
  echo "curl is not installed"
  exit 1
fi

if ! command -v jq > /dev/null; then
  echo "jq is not installed"
  exit 1
fi

mkdir -p ~/.ssh/git-commit-signing

echo "Downloading SSH key"

ssh_key=$(curl --request GET \
  --url "$${CODER_AGENT_URL}api/v2/workspaceagents/me/gitsshkey" \
  --header "Coder-Session-Token: $${CODER_AGENT_TOKEN}")

jq --raw-output ".public_key" > ~/.ssh/git-commit-signing/coder.pub << EOF
$ssh_key
EOF

jq --raw-output ".private_key" > ~/.ssh/git-commit-signing/coder << EOF
$ssh_key
EOF

chmod -R 400 ~/.ssh/git-commit-signing/coder
chmod -R 400 ~/.ssh/git-commit-signing/coder.pub

echo "Configuring git to use the SSH key"

git config --global gpg.format ssh
git config --global commit.gpgsign true
git config --global user.signingkey ~/.ssh/git-commit-signing/coder
