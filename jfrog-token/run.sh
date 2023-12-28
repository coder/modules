#!/usr/bin/env bash

BOLD='\033[0;1m'

# check if JFrog CLI is already installed
if command -v jf > /dev/null 2>&1; then
  echo "✅ JFrog CLI is already installed, skipping installation."
else
  echo "📦 Installing JFrog CLI..."
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
  echo "🤔 no npm repository is set, skipping npm configuration."
  echo "You can configure an npm repository by providing the a key for 'npm' in the 'package_managers' input."
else
  # check if npm is installed and configure it to use the Artifactory "npm" repository.
  if command -v npm > /dev/null 2>&1; then
    echo "📦 Configuring npm..."
    jf npmc --global --repo-resolve "${REPOSITORY_NPM}"
  fi
  # if npm version is greater than or equal to 9.0.0, use the new npmrc format
  cat << EOF > ~/.npmrc
email=${ARTIFACTORY_EMAIL}
registry=${JFROG_URL}/artifactory/api/npm/${REPOSITORY_NPM}
EOF
  if [ "$(npm --version | cut -d. -f1)" -ge 9 ]; then
    echo "//${JFROG_HOST}/artifactory/api/npm/${REPOSITORY_NPM}/:_authToken=${ARTIFACTORY_ACCESS_TOKEN}" >> ~/.npmrc
  else
    echo "_auth=$(echo -n '${ARTIFACTORY_USERNAME}:${ARTIFACTORY_ACCESS_TOKEN}' | base64)" >> ~/.npmrc
    echo "always-auth=true" >> ~/.npmrc
  fi
fi
# Configure the `pip` to use the Artifactory "python" repository.
if [ -z "${REPOSITORY_PYPI}" ]; then
  echo "🤔 no pypi repository is set, skipping pip configuration."
  echo "You can configure a pypi repository by providing the a key for 'pypi' in the 'package_managers' input."
else
  echo "🐍 Configuring pip..."
  jf pipc --global --repo-resolve "${REPOSITORY_PYPI}"
  mkdir -p ~/.pip
  cat << EOF > ~/.pip/pip.conf
[global]
index-url = https://${ARTIFACTORY_USERNAME}:${ARTIFACTORY_ACCESS_TOKEN}@${JFROG_HOST}/artifactory/api/pypi/${REPOSITORY_PYPI}/simple
EOF
fi

# Configure Artifactory "go" repository.
if [ -z "${REPOSITORY_GO}" ]; then
  echo "🤔 no go repository is set, skipping go configuration."
  echo "You can configure a go repository by providing the a key for 'go' in the 'package_managers' input."
else
  echo "🐹 Configuring go..."
  jf goc --global --repo-resolve "${REPOSITORY_GO}"
fi
echo "🥳 Configuration complete!"

# Install the JFrog vscode extension for code-server.
if [ "${CONFIGURE_CODE_SERVER}" == "true" ]; then
  while ! [ -x /tmp/code-server/bin/code-server ]; do
    counter=0
    if [ $counter -eq 30 ]; then
      echo "Timed out waiting for /tmp/code-server/bin/code-server to be installed."
      exit 1
    fi
    echo "Waiting for /tmp/code-server/bin/code-server to be installed..."
    sleep 1
    ((counter++))
  done
  echo "📦 Installing JFrog extension..."
  /tmp/code-server/bin/code-server --install-extension jfrog.jfrog-vscode-extension
  echo "🥳 JFrog extension installed!"
else
  echo "🤔 Skipping JFrog extension installation. Set configure_code_server to true to install the JFrog extension."
fi
