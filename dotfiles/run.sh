#!/usr/bin/env bash
DOTFILES_URI="${DOTFILES_URI}"
DOTFILES_USER="${DOTFILES_USER}"

if [ -n "$${DOTFILES_URI// }" ]; then
  if [ -z "$DOTFILES_USER" ]; then
    DOTFILES_USER="$USER"
  fi

  echo "✨ Applying dotfiles for user $DOTFILES_USER"

  if [ "$DOTFILES_USER" = "$USER" ]; then
    coder dotfiles "$DOTFILES_URI" -y 2>&1 | tee ~/.dotfiles.log
  else
    # The "eval echo ~$DOTFILES_USER" part is used to dynamically get the home directory of the user, see https://superuser.com/a/484280
    # sudo -u coder sh -c 'eval echo ~$DOTFILES_USER' -> "/home/coder"
    # sudo sh -c 'eval echo ~$DOTFILES_USER'          -> "/root"

    sudo -u "$DOTFILES_USER" sh -c "$(which coder) dotfiles \"$DOTFILES_URI\" -y 2>&1 | tee -a $(eval echo ~\'$DOTFILES_USER\')/.dotfiles.log"
  fi
fi
