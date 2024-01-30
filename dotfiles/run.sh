DOTFILES_URI="${DOTFILES_URI}"
ROOT="${ROOT}"

if [ -n "$${DOTFILES_URI// }" ]; then
  echo "✨ Applying dotfiles for user $USER"
  coder dotfiles "$DOTFILES_URI" -y 2>&1 | tee -a ~/.dotfiles.log
fi
