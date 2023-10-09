#!/usr/bin/env sh

BOLD='\033[0;1m'

# Check if vault is installed
if ! command -v vault &> /dev/null; then
    printf "$${BOLD}Installing vault CLI ...\n\n"
    # check if wget is installed
    if ! command -v wget &> /dev/null; then
        printf "wget is not installed. Please install wget in your image.\n"
        exit 1
    fi
    # check if unzip is installed
    if ! command -v unzip &> /dev/null; then
        printf "unzip is not installed. Please install unzip in your image.\n"
        exit 1
    fi
    # check if VERSION is latest
    if [ "${VERSION}" = "latest" ]; then
        INSTALL_VERSION=$(curl -s https://releases.hashicorp.com/vault/ | grep -oP '[0-9]+\.[0-9]+\.[0-9]' | tr -d '<>' | head -1)
    else
        INSTALL_VERSION=${VERSION}
    fi

    # download vault
    wget -q -O vault.zip https://releases.hashicorp.com/vault/$${INSTALL_VERSION}/vault_$${INSTALL_VERSION}_linux_amd64.zip
    unzip vault.zip
    sudo mv vault /usr/local/bin
    rm vault.zip
fi

printf "🥳 Installation comlete!\n\n"

# Set up Vault address and token
export VAULT_ADDR=${VAULT_ADDR}
export VAULT_TOKEN=${VAULT_TOKEN}

# Verify Vault address and token
printf "🔎 Verifying Vault address and token ...\n\n"
vault status

# Store token in .vault-token
printf "\nStoring token in .vault-token ...\n"
echo "${VAULT_TOKEN}" > ~/.vault-token

# Skip fetching secrets if SECRETS is {}
if [ "${SECRETS}" = "{}" ]; then
    exit 0
fi

printf "🔍 Fetching secrets ...\n\n"
for key in $(echo "${SECRETS}" | jq -r "keys[]" ); do
    secrets=$(echo "${SECRETS}" | jq -r ".$key.secrets[]")
    file=$(echo "${SECRETS}" | jq -r ".$key.file")
    printf "Fetching secrets from $${key} ...\n"
    for secret in $${secrets}; do
        value=$(vault kv get -format=json $${key} | jq -r ".data.data.$${secret}")
        # create directory if it doesn't exist
        mkdir -p $(dirname $${file})
        printf "$${secret}=$${value}\n" >> $${file}
    done
    printf "\n"
done
