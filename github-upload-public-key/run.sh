#!/usr/bin/env bash

set -e

CODER_ACCESS_URL="${CODER_ACCESS_URL}"
CODER_OWNER_SESSION_TOKEN="${CODER_OWNER_SESSION_TOKEN}"
GITHUB_EXTERNAL_AUTH_ID="${GITHUB_EXTERNAL_AUTH_ID}"

if [ -z "$CODER_ACCESS_URL" ]; then
  echo "No coder access url specified!"
  exit 1
fi

if [ -z "$CODER_OWNER_SESSION_TOKEN" ]; then
  echo "No coder owner session token specified!"
  exit 1
fi

if [ -z "$GITHUB_EXTERNAL_AUTH_ID" ]; then
  echo "No GitHub external auth id specified!"
  exit 1
fi

echo "Fetching GitHub token..."
GITHUB_TOKEN=$(coder external-auth access-token $GITHUB_EXTERNAL_AUTH_ID)
if [ $? -ne 0 ]; then
  echo "Failed to fetch GitHub token!"
  exit 1
fi
if [ -z "$GITHUB_TOKEN" ]; then
  echo "No GitHub token found!"
  exit 1
fi
echo "GitHub token found!"

echo "Fetching Coder public SSH key..."
PUBLIC_KEY_RESPONSE=$(
  curl -L -s \
    -w "%%{http_code}" \
    -H 'accept: application/json' \
    -H "cookie: coder_session_token=$CODER_OWNER_SESSION_TOKEN" \
    "$CODER_ACCESS_URL/api/v2/users/me/gitsshkey"
)
PUBLIC_KEY_RESPONSE_STATUS=$(tail -n1 <<< "$PUBLIC_KEY_RESPONSE")
PUBLIC_KEY_BODY=$(sed \$d <<< "$PUBLIC_KEY_RESPONSE")

if [ "$PUBLIC_KEY_RESPONSE_STATUS" -ne 200 ]; then
  echo "Failed to fetch Coder public SSH key with status code $PUBLIC_KEY_RESPONSE_STATUS!"
  echo "$PUBLIC_KEY_BODY"
  exit 1
fi

PUBLIC_KEY=$(jq -r '.public_key' <<< "$PUBLIC_KEY_BODY")
echo "Coder public SSH key found!"

if [ -z "$PUBLIC_KEY" ]; then
  echo "No Coder public SSH key found!"
  exit 1
fi

echo "Fetching GitHub public SSH keys..."
GITHUB_KEYS_RESPONSE=$(
  curl -L -s \
    -w "%%{http_code}" \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    https://api.github.com/user/keys
)
GITHUB_KEYS_RESPONSE_STATUS=$(tail -n1 <<< "$GITHUB_KEYS_RESPONSE")
GITHUB_KEYS_RESPONSE_BODY=$(sed \$d <<< "$GITHUB_KEYS_RESPONSE")

if [ "$GITHUB_KEYS_RESPONSE_STATUS" -ne 200 ]; then
  echo "Failed to fetch Coder public SSH key with status code $GITHUB_KEYS_RESPONSE_STATUS!"
  echo "$GITHUB_KEYS_RESPONSE_BODY"
  exit 1
fi

GITHUB_MATCH=$(jq -r --arg PUBLIC_KEY "$PUBLIC_KEY" '.[] | select(.key == $PUBLIC_KEY) | .key' <<< "$GITHUB_KEYS_RESPONSE_BODY")

if [ "$PUBLIC_KEY" = "$GITHUB_MATCH" ]; then
  echo "Coder public SSH key is already uploaded to GitHub!"
  exit 0
fi

echo "Coder public SSH key not found in GitHub keys!"
echo "Uploading Coder public SSH key to GitHub..."
CODER_PUBLIC_KEY_NAME="$CODER_ACCESS_URL Workspaces"
UPLOAD_RESPONSE=$(
  curl -L -s \
    -X POST \
    -w "%%{http_code}" \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    https://api.github.com/user/keys \
    -d "{\"title\":\"$CODER_PUBLIC_KEY_NAME\",\"key\":\"$PUBLIC_KEY\"}"
)
UPLOAD_RESPONSE_STATUS=$(tail -n1 <<< "$UPLOAD_RESPONSE")
UPLOAD_RESPONSE_BODY=$(sed \$d <<< "$UPLOAD_RESPONSE")

if [ "$UPLOAD_RESPONSE_STATUS" -ne 201 ]; then
  echo "Failed to upload Coder public SSH key with status code $UPLOAD_RESPONSE_STATUS!"
  echo "$UPLOAD_RESPONSE_BODY"
  exit 1
fi

echo "Coder public SSH key uploaded to GitHub!"
