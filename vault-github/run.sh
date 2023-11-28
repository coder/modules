#!/usr/bin/env bash

VAULT_ADDR=${VAULT_ADDR}
VERSION=${VERSION}
AUTH_PATH=${AUTH_PATH}
GITHUB_EXTERNAL_AUTH_ID=${GITHUB_EXTERNAL_AUTH_ID}

# Ensure curl is installed
if ! command -v curl &>/dev/null; then
    printf "curl is not installed. Please install curl in your image.\n"
    exit 1
fi

# Fetch latest version of Vault if VERSION is 'latest'
if [ "${VERSION}" = "latest" ]; then
    LATEST_VERSION=$(curl -s https://releases.hashicorp.com/vault/ | grep -oP 'vault/\K[0-9]+\.[0-9]+\.[0-9]+' | sort -V | tail -n 1)
    if [ -z "$LATEST_VERSION" ]; then
        printf "Failed to determine the latest Vault version.\n"
        exit 1
    fi
    VERSION=$LATEST_VERSION
fi

# Check if vault is installed and has the correct version
installation_needed=1
if command -v vault &>/dev/null; then
    CURRENT_VERSION=$(vault version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
    if [ "$CURRENT_VERSION" = "$VERSION" ]; then
        printf "Vault version $CURRENT_VERSION is already installed and up-to-date.\n\n"
        installation_needed=0
    fi
fi

if [ $installation_needed -eq 1 ]; then
    # Check if unzip or busybox is installed
    if ! command -v unzip &>/dev/null; then
        if command -v busybox &>/dev/null && busybox --list | grep -q '^unzip$'; then
            alias unzip='busybox unzip'
            printf "Using busybox unzip.\n"
        else
            printf "unzip is not installed and busybox unzip is not available. Please install unzip in your image.\n"
            exit 1
        fi
    fi

    # Download and install Vault
    printf "Installing or updating Vault CLI ...\n\n"
    curl -Lo vault.zip "https://releases.hashicorp.com/vault/${VERSION}/vault_${VERSION}_linux_amd64.zip"
    if [ ! -f vault.zip ]; then
        printf "Failed to download Vault.\n"
        exit 1
    fi
    unzip -o vault.zip
    if [ ! -f vault ]; then
        printf "Failed to unzip Vault.\n"
        exit 1
    fi
    if sudo mv vault /usr/local/bin/vault 2>/dev/null; then
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

# Authenticate with Vault
printf "🔑 Authenticating with Vault ...\n\n"
GITHUB_TOKEN=$(coder external-auth access-token $GITHUB_EXTERNAL_AUTH_ID)
if [ $? -ne 0 ]; then
    printf "Authentication with Vault failed. Please check your credentials.\n"
    exit 1
fi

export VAULT_ADDR=$VAULT_ADDR

# Login to Vault using GitHub token
printf "🔑 Logging in to Vault ...\n\n"
vault login -no-print -method=github -path=/$AUTH_PATH token=$GITHUB_TOKEN
printf "\n🥳 Vault authentication complete!\n\n"
printf "You can now use Vault CLI to access secrets.\n"
