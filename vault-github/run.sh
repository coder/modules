#!/usr/bin/env bash

# Convert all templated variables to shell variables
INSTALL_VERSION=${INSTALL_VERSION}
GITHUB_EXTERNAL_AUTH_ID=${GITHUB_EXTERNAL_AUTH_ID}
AUTH_PATH=${AUTH_PATH}

fetch() {
  dest="$1"
  url="$2"
  if command -v curl > /dev/null 2>&1; then
    curl -sSL --fail "$${url}" -o "$${dest}"
  elif command -v wget > /dev/null 2>&1; then
    wget -O "$${dest}" "$${url}"
  elif command -v busybox > /dev/null 2>&1; then
    busybox wget -O "$${dest}" "$${url}"
  else
    printf "curl, wget, or busybox is not installed. Please install curl or wget in your image.\n"
    exit 1
  fi
}

unzip_safe() {
  if command -v unzip > /dev/null 2>&1; then
    command unzip "$@"
  elif command -v busybox > /dev/null 2>&1; then
    busybox unzip "$@"
  else
    printf "unzip or busybox is not installed. Please install unzip in your image.\n"
    exit 1
  fi
}

install() {
  # Fetch the latest version of Vault if INSTALL_VERSION is 'latest'
  if [ "$${INSTALL_VERSION}" = "latest" ]; then
    LATEST_VERSION=$(curl -s https://releases.hashicorp.com/vault/ | grep -v '-rc' | grep -oP 'vault/\K[0-9]+\.[0-9]+\.[0-9]+' | sort -V | tail -n 1)
    printf "Latest version of Vault is %s.\n\n" "$${LATEST_VERSION}"
    if [ -z "$${LATEST_VERSION}" ]; then
      printf "Failed to determine the latest Vault version.\n"
      return 1
    fi
    INSTALL_VERSION=$${LATEST_VERSION}
  fi

  # Check if the vault CLI is installed and has the correct version
  installation_needed=1
  if command -v vault > /dev/null 2>&1; then
    CURRENT_VERSION=$(vault version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
    if [ "$${CURRENT_VERSION}" = "$${INSTALL_VERSION}" ]; then
      printf "Vault version %s is already installed and up-to-date.\n\n" "$${CURRENT_VERSION}"
      installation_needed=0
    fi
  fi

  if [ $${installation_needed} -eq 1 ]; then
    # Download and install Vault
    if [ -z "$${CURRENT_VERSION}" ]; then
      printf "Installing Vault CLI ...\n\n"
    else
      printf "Upgrading Vault CLI from version %s to %s ...\n\n" "$${CURRENT_VERSION}" "${INSTALL_VERSION}"
    fi
    fetch vault.zip "https://releases.hashicorp.com/vault/$${INSTALL_VERSION}/vault_$${INSTALL_VERSION}_linux_amd64.zip"
    if [ $? -ne 0 ]; then
      printf "Failed to download Vault.\n"
      return 1
    fi
    if ! unzip_safe vault.zip; then
      printf "Failed to unzip Vault.\n"
      return 1
    fi
    rm vault.zip
    if sudo mv vault /usr/local/bin/vault 2> /dev/null; then
      printf "Vault installed successfully!\n\n"
    else
      mkdir -p ~/.local/bin
      if ! mv vault ~/.local/bin/vault; then
        printf "Failed to move Vault to local bin.\n"
        return 1
      fi
      printf "Please add ~/.local/bin to your PATH to use vault CLI.\n"
    fi
  fi
  return 0
}

TMP=$(mktemp -d)
if ! (
  cd "$TMP"
  install
); then
  echo "Failed to install Vault CLI."
  exit 1
fi
rm -rf "$TMP"

# Authenticate with Vault
printf "🔑 Authenticating with Vault ...\n\n"
GITHUB_TOKEN=$(coder external-auth access-token "$${GITHUB_EXTERNAL_AUTH_ID}")
if [ $? -ne 0 ]; then
  printf "Authentication with Vault failed. Please check your credentials.\n"
  exit 1
fi

# Login to vault using the GitHub token
printf "🔑 Logging in to Vault ...\n\n"
vault login -no-print -method=github -path=/$${AUTH_PATH} token="$${GITHUB_TOKEN}"
printf "🥳 Vault authentication complete!\n\n"
printf "You can now use Vault CLI to access secrets.\n"
