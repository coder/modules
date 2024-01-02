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
# Authenticate JFrog CLI with Artifactory.
echo "${ARTIFACTORY_ACCESS_TOKEN}" | jf c add --access-token-stdin --url "${JFROG_URL}" --overwrite 0
# Set the configured server as the default.
jf c use 0

# Configure npm to use the Artifactory "npm" repository.
if [ -z "${REPOSITORY_NPM}" ]; then
  echo "🤔 no npm repository is set, skipping npm configuration."
  echo "You can configure an npm repository by providing the a key for 'npm' in the 'package_managers' input."
else
  echo "📦 Configuring npm..."
  jf npmc --global --repo-resolve "${REPOSITORY_NPM}"
  cat << EOF > ~/.npmrc
email=${ARTIFACTORY_EMAIL}
registry=${JFROG_URL}/artifactory/api/npm/${REPOSITORY_NPM}
EOF
  # if npm version is greater than or equal to 9.0.0, use the new npmrc format
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

# Configure the JFrog CLI to use the Artifactory "docker" repository.
if [ -z "${REPOSITORY_DOCKER}" ]; then
  echo "🤔 no docker repository is set, skipping docker configuration."
  echo "You can configure a docker repository by providing the a key for 'docker' in the 'package_managers' input."
else
  echo "🐳 Configuring docker..."
  mkdir -p ~/.docker
  cat << EOF > ~/.docker/config.json
{
  "auths": {
    "${JFROG_HOST}": {
      "auth": "$(echo -n "${ARTIFACTORY_USERNAME}:${ARTIFACTORY_ACCESS_TOKEN}" | base64)",
      "email": "${ARTIFACTORY_EMAIL}"
    }
  }
}
EOF
fi

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

# Configure the JFrog CLI completion
echo "📦 Configuring JFrog CLI completion..."
## Get the user's shell
SHELLNAME=$(grep "^$USER" /etc/passwd | awk -F':' '{print $7}' | awk -F'/' '{print $NF}')
## Generate the completion script
jf completion $SHELLNAME --install
## Add the completion script to the user's shell profile
if [ "$SHELLNAME" == "bash" ] || [ "$SHELLNAME" == "zsh" ]; then
  if ! grep -q "source $HOME/.jfrog/jfrog_$${SHELLNAME}_completion" ~/.$${SHELLNAME}rc; then
    echo "source $HOME/.jfrog/jfrog_$${SHELLNAME}_completion" >> ~/.$${SHELLNAME}rc
  fi
fi
