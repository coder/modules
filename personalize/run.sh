#!/usr/bin/env sh

PERSONALIZE_PATH=${path}

# If the personalize script doesn't exist, educate
# the user how they can customize their environment!
if [ ! -f ${PERSONALIZE_PATH}/personalize.sh ]; then
    echo "✨ You don't have a personalize script!"
    echo "Run \`touch ${PERSONALIZE_PATH}\` to create one."
    echo "Developers typically install their favorite packages here that may not be included in the base image."
    exit 0
fi

# Check if the personalize script is executable, if not,
# try to make it executable and educate the user if it fails.
if [ ! -x ${PERSONALIZE_PATH}/personalize.sh ]; then
    echo "🔐 Your personalize script isn't executable!"
    echo "Run \`chmod +x ${PERSONALIZE_PATH}\` to make it executable."
    exit 0
fi

# Run the personalize script!
exec $PERSONALIZE_PATH
