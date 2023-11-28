#!/usr/bin/env bash

BOLD='\033[0;1m'
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
        printf "${BOLD}Vault version $CURRENT_VERSION is already installed and up-to-date.\n\n"
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
    curl -sLo vault.zip "https://releases.hashicorp.com/vault/${VERSION}/vault_${VERSION}_linux_amd64.zip"
    unzip -o vault.zip
    sudo mv vault /usr/local/bin/vault || {
        mkdir -p ~/.local/bin
        mv vault ~/.local/bin/vault
        printf "Please add ~/.local/bin to your PATH to use vault CLI.\n"
    }
    rm vault.zip
    printf "🥳 Vault installed successfully!\n\n"
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

# Add VAULT_ADDR to shell login scripts if not already present
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
