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
    wget -O vault.zip https://releases.hashicorp.com/vault/$${INSTALL_VERSION}/vault_$${INSTALL_VERSION}_linux_amd64.zip
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

# Skip fetching secrets if SECRETS is {}
if [ "${SECRETS}" = "{}" ]; then
    exit 0
fi

printf "\n🔑 Fetching secrets ...\n\n"

# Check if jq is installed
if ! command -v jq >/dev/null; then
    echo "jq is not installed. Please install jq to automatically set the secrets."
    echo "You can manually set the secrets by using the following command in your workspace:"
    echo "vault kv get <path>"
    exit 0 
fi

# Decode the JSON string to a temporary file
echo "${SECRETS}" | jq '.' > temp.json

# Iterate through the keys and values in the JSON file
for key in $(jq -r 'keys[]' temp.json); do
    path=$(echo $key | tr -d \")
    # Fetch the secrets from Vault
    secrets=$(vault kv get -format=json $path)
    # Get the array of secret names from the JSON file
    sceret_names=$(jq -r ".$key[]" temp.json)
    # Convert the list of environment variables to an array
    IFS=', ' read -r -a sceret_array <<< "$sceret_names"
    # Set the environment variables with the secret values
    for secret_name in "$${sceret_array[@]}"; do
        # Remove quotes from the variable name
        secret_name=$(echo $secret_name | tr -d \")
        secret_value=$(echo $secrets | jq -r ".data.data.$secret_name")
        export $secret_name=$secret_value
    done
done

# Remove the temporary file
rm temp.json


