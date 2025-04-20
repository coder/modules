#!/usr/bin/env sh
INSTALLER=""
check_available_installer() {
  # check if pipx is installed
  echo "Checking for a supported installer"
  if command -v pipx > /dev/null 2>&1; then
    echo "pipx is installed"
    INSTALLER="pipx"
    return
  fi
  # check if uv is installed
  if command -v uv > /dev/null 2>&1; then
    echo "uv is installed"
    INSTALLER="uv"
    return
  fi
  echo "No valid installer is not installed"
  echo "Please install pipx or uv in your Dockerfile/VM image before running this script"
  exit 1
}

if [ -n "${BASE_URL}" ]; then
  BASE_URL_FLAG="--base-url=${BASE_URL}"
fi

BOLD='\033[0;1m'

# check if marimo is installed
if ! command -v marimo > /dev/null 2>&1; then
  # install marimo
  check_available_installer
  printf "$${BOLD}Installing marimo!\n"
  case $INSTALLER in
    uv)
      uv pip install -q marimo[recommended] \
        && printf "%s\n" "🥳 marimo has been installed"
      MARIMOPATH="$HOME/.venv/bin/"
      ;;
    pipx)
      pipx install marimo[recommended] \
        && printf "%s\n" "🥳 marimo has been installed"
      MARIMOPATH="$HOME/.local/bin"
      ;;
  esac
else
  printf "%s\n\n" "🥳 marimo is already installed"
fi

printf "👷 Starting marimo in background..."
printf "check logs at ${LOG_PATH}"
$MARIMOPATH/marimo run \
  "$BASE_URL_FLAG" \
  --host="*" \
  --port="${PORT}" \
  --headless \
  --include-code \
  > "${LOG_PATH}" 2>&1 &