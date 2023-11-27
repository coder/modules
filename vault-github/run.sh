#!/usr/bin/env bash

BOLD='\033[0;1m'
VAULT_ADDR=${VAULT_ADDR}
VERSION=${VERSION}
AUTH_PATH=${AUTH_PATH}
GITHUB_EXTERNAL_AUTH_ID=${GITHUB_EXTERNAL_AUTH_ID}

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
        printf "${BOLD}Vault version $CURRENT_VERSION is already installed and up-to-date.\n\n"
        installation_needed=0
    fi
fi

if [ $installation_needed -eq 1 ]; then
    printf "${BOLD}Installing or updating Vault CLI ...\n\n"

    # Check if curl is installed
    if ! command -v curl &>/dev/null; then
        printf "curl is not installed. Please install curl in your image.\n"
        exit 1
    fi

    # Check if unzip is installed
    if ! command -v unzip &>/dev/null; then
        # Check if busybox is installed and can provide unzip
        if command -v busybox &>/dev/null && busybox --list | grep -q '^unzip$'; then
            alias unzip='busybox unzip'
            printf "Using busybox unzip.\n"
        else
            printf "unzip is not installed and busybox unzip is not available. Please install unzip in your image.\n"
            exit 1
        fi
    fi

    # Download and install Vault
    curl -sLo vault.zip https://releases.hashicorp.com/vault/${VERSION}/vault_${VERSION}_linux_amd64.zip
    unzip vault.zip
    # Try to move vault to /usr/local/bin with sudo if possible otherwise to .local/bin and add to PATH
    if sudo mv vault /usr/local/bin/vault 2>/dev/null; then
        printf "🥳 Vault installed successfully!\n\n"
    else
        mkdir -p ~/.local/bin
        mv vault ~/.local/bin/vault
        printf "🥳 Vault installed successfully!\n\n"
        printf "Please add ~/.local/bin to your PATH to use vault CLI.\n"
    fi
fi

# Set up Vault token
printf "🔑 Authenticating with Vault ...\n\n"
echo "AUTH_PATH: $AUTH_PATH"
echo "GITHUB_EXTERNAL_AUTH_ID: $GITHUB_EXTERNAL_AUTH_ID"
GITHUB_TOKEN=$(coder external-auth access-token $GITHUB_EXTERNAL_AUTH_ID)
if [ $? -ne 0 ]; then
    printf "Authentication with Vault failed. Please check your credentials.\n"
    exit 1
fi

export VAULT_ADDR=$VAULT_ADDR

# Verify Vault address
printf "🔎 Verifying Vault address...\n\n"
vault status

# Login to Vault to using GitHub token
printf "🔑 Logging in to Vault ...\n\n"
vault login -no-print -method=github -path=/$AUTH_PATH token=$GITHUB_TOKEN

# Add VAULT_ADDR to shell login scripts if not already present e.g. .bashrc, .zshrc
# This is a temporary fix and will be replaced with https://github.com/coder/coder/issues/10166
# bash
if [[ -f ~/.bashrc ]] && ! grep -q "VAULT_ADDR" ~/.bashrc; then
    printf "\nAdding VAULT_ADDR to ~/.bashrc ...\n"
    echo "export VAULT_ADDR=$VAULT_ADDR" >>~/.bashrc
fi

# zsh
if [[ -f ~/.zshrc ]] && ! grep -q "VAULT_ADDR" ~/.zshrc; then
    printf "\nAdding VAULT_ADDR to ~/.zshrc ...\n"
    echo "export VAULT_ADDR=$VAULT_ADDR" >>~/.zshrc
fi

# fish
if [[ -f ~/.config/fish/config.fish ]] && ! grep -q "VAULT_ADDR" ~/.config/fish/config.fish; then
    printf "\nAdding VAULT_ADDR to ~/.config/fish/config.fish ...\n"
    echo "set -x VAULT_ADDR $VAULT_ADDR" >>~/.config/fish/config.fish
fi

printf "\n🥳 Vault authentication complete!\n\n"
printf "You can now use Vault CLI to access secrets.\n"
