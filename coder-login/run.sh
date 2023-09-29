#!/usr/bin/env sh

# Logs the coder user in

echo "Logging into Coder..."

# Automatically authenticate the user if they are not
# logged in to another deployment
if ! coder list >/dev/null 2>&1; then
  set +x; coder login --token=$CODER_USER_TOKEN --url=$CODER_DEPLOYMENT_URL
else
  echo "You are already authenticated with coder"
fi
