#!/usr/bin/env bash

BOLD='\033[0;1m'

# check if JFrog CLI is already installed
if command -v jf > /dev/null 2>&1; then
  echo "✅ JFrog CLI is already installed, skipping installation."
else
  echo "📦 Installing JFrog CLI..."
  # Install the JFrog CLI.
  curl -fL https://install-cli.jfrog.io | sudo sh
  sudo chmod 755 /usr/local/bin/jf
fi

# The jf CLI checks $CI when determining whether to use interactive
# flows.
export CI=true
# Authenticate with the JFrog CLI.
jf c rm 0 || true
echo "${ARTIFACTORY_ACCESS_TOKEN}" | jf c add --access-token-stdin --url "${JFROG_URL}" 0

if [ -z "${REPOSITORY_NPM}" ]; then
  echo "🤔 REPOSITORY_NPM is not set, skipping npm configuration."
else
  # check if npm is installed and configure it to use the Artifactory "npm" repository.
  if command -v npm > /dev/null 2>&1; then
    echo "📦 Configuring npm..."
    jf npmc --global --repo-resolve "${REPOSITORY_NPM}"
  fi
  cat << EOF > ~/.npmrc
email = ${ARTIFACTORY_EMAIL}
registry = ${JFROG_URL}/artifactory/api/npm/${REPOSITORY_NPM}
EOF
  jf rt curl /api/npm/auth >> ~/.npmrc
fi

# Configure the `pip` to use the Artifactory "python" repository.
if [ -z "${REPOSITORY_PYPI}" ]; then
  echo "🤔 REPOSITORY_PYPI is not set, skipping pip configuration."
else
  echo "🐍 Configuring pip..."
  jf pipc --global --repo-resolve "${REPOSITORY_PYPI}"
  mkdir -p ~/.pip
  cat << EOF > ~/.pip/pip.conf
[global]
index-url = https://${ARTIFACTORY_USERNAME}:${ARTIFACTORY_ACCESS_TOKEN}@${JFROG_HOST}/artifactory/api/pypi/${REPOSITORY_PYPI}/simple
EOF
fi

# Set GOPROXY to use the Artifactory "go" repository.
if [ -z "${REPOSITORY_GO}" ]; then
  echo "🤔 REPOSITORY_GO is not set, skipping go configuration."
else
  echo "🐹 Configuring go..."
  jf go-config --global --repo-resolve "${REPOSITORY_GO}"
fi
echo "🥳 Configuration complete!"

# Install the JFrog vscode extension for code-server.
if [ "${CONFIGURE_CODE_SERVER}" == "true" ]; then
  if command -v code-server > /dev/null 2>&1; then
    echo "📦 Installing JFrog extension..."
    code-server --install-extension jfrog.jfrog-vscode-extension
    echo "🥳 JFrog extension installed!"
  elif command /tmp/coder-server/bin/code-server > /dev/null 2>&1; then
    echo "📦 Installing JFrog extension..."
    /tmp/coder-server/bin/code-server --install-extension jfrog.jfrog-vscode-extension
    echo "🥳 JFrog extension installed!"
  else
    echo "🤔 code-server is not installed, skipping JFrog extension installation."
  fi
else
  echo "🤔 Skipping JFrog extension installation. Set configure_code_server to true to install the JFrog extension."
fi
