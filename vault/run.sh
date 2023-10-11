#!/usr/bin/env bash
set -x
BOLD='\033[0;1m'
PROVIDER_ID=${PROVIDER_ID}
VAULT_ADDR=${VAULT_ADDR}
VERSION=${VERSION}

# Check if vault is installed
if ! command -v vault &>/dev/null; then
    printf "$${BOLD}Installing vault CLI ...\n\n"
    # check if wget is installed
    if ! command -v wget &>/dev/null; then
        printf "wget is not installed. Please install wget in your image.\n"
        exit 1
    fi
    # check if unzip is installed
    if ! command -v unzip &>/dev/null; then
        printf "unzip is not installed. Please install unzip in your image.\n"
        exit 1
    fi
    # check if VERSION is latest
    if [ "${VERSION}" = "latest" ]; then
        INSTALL_VERSION=$(curl -s https://releases.hashicorp.com/vault/ | grep -oP '[0-9]+\.[0-9]+\.[0-9]' | tr -d '<>' | head -1)
    else
        INSTALL_VERSION=$VERSION
    fi

    # download vault
    wget -q -O vault.zip https://releases.hashicorp.com/vault/$${INSTALL_VERSION}/vault_$${INSTALL_VERSION}_linux_amd64.zip
    unzip vault.zip
    sudo mv vault /usr/local/bin
    rm vault.zip
fi

printf "🥳 Installation complete!\n\n"

# Set up Vault token
printf "🔑 Authenticating with Vault ...\n\n"
echo "PROVIDER_ID: $PROVIDER_ID"
VAULT_TOKEN=$(coder external-auth access-token $PROVIDER_ID)
if [ $? -ne 0 ]; then
    printf "Authenticate with Vault:\n$VAULT_TOKEN\n"
    exit 1
fi

export VAULT_ADDR=$VAULT_ADDR

# Verify Vault address and token
printf "🔎 Verifying Vault address and token ...\n\n"
vault status
vault login $VAULT_TOKEN

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
