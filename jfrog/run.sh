#!/usr/bin/env sh

BOLD='\033[0;1m'
echo "$${BOLD}Installing JFrog CLI..."

# Install the JFrog CLI.
curl -fL https://install-cli.jfrog.io | sudo sh
sudo chmod 755 /usr/local/bin/jf

# The jf CLI checks $CI when determining whether to use interactive
# flows.
export CI=true
# Authenticate with the JFrog CLI.
jf c rm 0 || true
echo "${ARTIFACTORY_ACCESS_TOKEN}" | jf c add --access-token-stdin --url "https://${JFROG_HOST}" 0

# Configure the `npm` CLI to use the Artifactory "npm" repository.
if [ -z "${REPOSITORY_NPM}" ]; then
  echo "🤔 REPOSITORY_NPM is not set, skipping npm configuration."
else
  echo "📦 Configuring npm..."
  jf npmc --global --repo-resolve "https://${JFROG_HOST}/artifactory/api/npm/${REPOSITORY_NPM}"
  cat << EOF > ~/.npmrc
email = ${ARTIFACTORY_USERNAME}
registry = https://${JFROG_HOST}/artifactory/api/npm/${REPOSITORY_NPM}
EOF
  jf rt curl /api/npm/auth >> ~/.npmrc
fi

# Configure the `pip` to use the Artifactory "python" repository.
if [ -z "${REPOSITORY_PYPI}" ]; then
  echo "🤔 REPOSITORY_PYPI is not set, skipping pip configuration."
else
  echo "🐍 Configuring pip..."
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
  export GOPROXY="https://${ARTIFACTORY_USERNAME}:${ARTIFACTORY_ACCESS_TOKEN}@${JFROG_HOST}/artifactory/api/go/${REPOSITORY_GO}"
fi
echo "🥳 Configuration complete!"