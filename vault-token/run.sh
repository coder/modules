#!/usr/bin/env sh

# Convert all templated variables to shell variables
INSTALL_VERSION=${INSTALL_VERSION}
VAULT_ADDR=${VAULT_ADDR}
VAULT_TOKEN=${VAULT_TOKEN}

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

unzip() {
  if command -v unzip > /dev/null 2>&1; then
    command unzip "$@"
  elif command -v busybox > /dev/null 2>&1; then
    busybox unzip "$@"
  else
    printf "unzip or busybox is not installed. Please install unzip in your image.\n"
    exit 1
  fi
}

# Fetch the latest version of Vault if INSTALL_VERSION is 'latest'
if [ "$${INSTALL_VERSION}" = "latest" ]; then
  LATEST_VERSION=$(curl -s https://releases.hashicorp.com/vault/ | grep -oP 'vault/\K[0-9]+\.[0-9]+\.[0-9]+' | sort -V | tail -n 1)
  printf "Latest version of Vault is %s.\n\n" "$${LATEST_VERSION}"
  if [ -z "$${LATEST_VERSION}" ]; then
    printf "Failed to determine the latest Vault version.\n"
    exit 1
  fi
  VERSION=$${LATEST_VERSION}
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
    printf "Upgrading Vault CLI from version %s to %s ...\n\n" "$${CURRENT_VERSION}" "$${VERSION}"
  fi
  fetch vault.zip "https://releases.hashicorp.com/vault/$${VERSION}/vault_$${VERSION}_linux_amd64.zip"
  if [ $? -ne 0 ]; then
    printf "Failed to download Vault.\n"
    exit 1
  fi
  unzip vault.zip
  if [ $? -ne 0 ]; then
    printf "Failed to unzip Vault.\n"
    exit 1
  fi
  rm vault.zip
  if sudo mv vault /usr/local/bin/vault 2> /dev/null; then
    printf "Vault installed successfully!\n\n"
  else
    mkdir -p ~/.local/bin
    mv vault ~/.local/bin/vault
    if [ ! -f ~/.local/bin/vault ]; then
      printf "Failed to move Vault to local bin.\n"
      exit 1
    fi
    printf "Please add ~/.local/bin to your PATH to use vault CLI.\n"
  fi
fi

# Login to vault using the configured token
export VAULT_ADDR="$${VAULT_ADDR}"
export VAULT_TOKEN="$${VAULT_TOKEN}"
printf "🔑 Authenticating with Vault ...\n\n"
vault login -no-print token="$${VAULT_TOKEN}"
printf "🥳 Vault authentication complete!\n\n"
printf "You can now use Vault CLI to access secrets.\n"