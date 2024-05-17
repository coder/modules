#!/usr/bin/env sh

BOLD='\033[0;1m'

printf "$${BOLD}Installing jupyter-notebook!\n"

# check if jupyter-notebook is installed
if ! command -v jupyter-notebook > /dev/null 2>&1; then
  # install jupyter-notebook
  # check if python3 pip is installed
  if ! command -v pip3 > /dev/null 2>&1; then
    echo "pip3 is not installed"
    echo "Please install pip3 in your Dockerfile/VM image before running this script"
    exit 1
  fi
  # install jupyter-notebook
  pip3 install --upgrade --no-cache-dir --no-warn-script-location jupyter
  echo "🥳 jupyter-notebook has been installed\n\n"
else
  echo "🥳 jupyter-notebook is already installed\n\n"
fi

echo "👷 Starting jupyter-notebook in background..."
echo "check logs at ${LOG_PATH}"
$HOME/.local/bin/jupyter notebook --NotebookApp.ip='0.0.0.0' --ServerApp.port=${PORT} --no-browser --ServerApp.token='' --ServerApp.password='' > ${LOG_PATH} 2>&1 &
