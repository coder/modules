#!/usr/bin/env sh

PROVIDER_ID=${PROVIDER_ID}
SLACK_MESSAGE="${SLACK_MESSAGE}"
SLACK_URL=$${SLACK_URL:-https://slack.com}

usage() {
  cat <<EOF
slackme — Send a Slack notification when a command finishes
Usage: slackme <command>

Example: slackme npm run long-build
EOF
}

if [ $# -eq 0 ]; then
    usage
    exit 1
fi

BOT_TOKEN=$(coder external-auth access-token $PROVIDER_ID)
if [ $? -ne 0 ]; then
  printf "Authenticate with Slack to be notified when a command finishes:\n$BOT_TOKEN\n"
  exit 1
fi

USER_ID=$(coder external-auth access-token $PROVIDER_ID --extra "authed_user.id")
if [ $? -ne 0 ]; then
  printf "Failed to get authenticated user ID:\n$USER_ID\n"
  exit 1
fi

# Run all arguments as a command
$@

set -e
curl --silent -o /dev/null --header "Authorization: Bearer $BOT_TOKEN" \
    "$SLACK_URL/api/chat.postMessage?channel=$USER_ID&text=$SLACK_MESSAGE&pretty=1"
