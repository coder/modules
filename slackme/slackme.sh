#!/usr/bin/env node

PROVIDER_ID=${PROVIDER_ID}

BOT_TOKEN=\$(coder external-auth access-token $PROVIDER_ID)

if [ $? -ne 0 ]; then
  echo "Authenticate to run commands in the background:"
  # The output contains the URL if failed.
  echo $BOT_TOKEN
  exit 1
fi

USER_ID=\$(coder external-auth access-token $PROVIDER_ID --extra "authed_user.id")

if [ $? -ne 0 ]; then
  echo "Failed to get authenticated user ID:"
  echo $USER_ID
  exit 1
fi

echo "We'll notify you when done!"

# Run all arguments as a command
$@

curl --silent -o /dev/null --header "Authorization: Bearer $BOT_TOKEN" \
    "https://slack.com/api/chat.postMessage?channel=$USER_ID&text=Your%20command%20finished!&pretty=1"
