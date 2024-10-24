#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Function to check if vncserver is already installed
check_installed() {
  if command -v vncserver &> /dev/null; then
    echo "vncserver is already installed."
    return 0 # Don't exit, just indicate it's installed
  else
    return 1 # Indicates not installed
  fi
}

# Function to download a file using wget, curl, or busybox as a fallback
download_file() {
  local url="$1"
  local output="$2"
  local download_tool

  if command -v curl &> /dev/null; then
    download_tool="curl -fsSL"
  elif command -v wget &> /dev/null; then
    download_tool="wget -q -O-"
  elif command -v busybox &> /dev/null; then
    download_tool="busybox wget -O-"
  else
    echo "ERROR: No download tool available (curl, wget, or busybox required)"
    exit 1
  fi

  $download_tool "$url" > "$output" || {
    echo "ERROR: Failed to download $url"
    exit 1
  }
}

# Add user to group using available commands
add_user_to_group() {
  local user="$1"
  local group="$2"

  if command -v usermod &> /dev/null; then
    sudo usermod -aG "$group" "$user"
  elif command -v adduser &> /dev/null; then
    sudo adduser "$user" "$group"
  else
    echo "ERROR: At least one of 'adduser'(Debian) 'usermod'(RHEL) is required"
    exit 1
  fi
}

# Function to install kasmvncserver for debian-based distros
install_deb() {
  local url=$1
  download_file "$url" /tmp/kasmvncserver.deb
  # Define the directory to check
  CACHE_DIR="/var/lib/apt/lists/partial"
  # Check if the directory exists and was modified in the last 60 minutes
  if [ ! -d "$CACHE_DIR" ] || ! find "$CACHE_DIR" -mmin -60 -print -quit &> /dev/null; then
    echo "Stale Package Cache, updating..."
    # Update package cache with a 300-second timeout for dpkg lock
    sudo apt-get -o DPkg::Lock::Timeout=300 -qq update
  fi
  DEBIAN_FRONTEND=noninteractive sudo apt-get -o DPkg::Lock::Timeout=300 install --yes -qq --no-install-recommends --no-install-suggests /tmp/kasmvncserver.deb
  add_user_to_group "$USER" ssl-cert
  rm /tmp/kasmvncserver.deb
}

# Function to install kasmvncserver for rpm-based distros
install_rpm() {
  local url=$1
  download_file "$url" /tmp/kasmvncserver.rpm
  sudo rpm -i /tmp/kasmvncserver.rpm
  rm /tmp/kasmvncserver.rpm
}

# Function to install kasmvncserver for Alpine Linux
install_alpine() {
  local url=$1
  download_file "$url" /tmp/kasmvncserver.tgz
  tar -xzf /tmp/kasmvncserver.tgz -C /usr/local/bin/
  rm /tmp/kasmvncserver.tgz
}

# Check for sudo (required)
if ! command -v sudo &> /dev/null; then
  echo "ERROR: Required command 'sudo' not found"
  exit 1
fi

# Detect system information
if [[ ! -f /etc/os-release ]]; then
  echo "ERROR: Cannot detect OS: /etc/os-release not found"
  exit 1
fi

# shellcheck disable=SC1091
source /etc/os-release
distro="$ID"
distro_version="$VERSION_ID"
codename="$VERSION_CODENAME"
arch="$(uname -m)"
if [[ "$ID" == "ol" ]]; then
  distro="oracle"
  distro_version="$${distro_version%%.*}"
fi

echo "Detected Distribution: $distro"
echo "Detected Version: $distro_version"
echo "Detected Codename: $codename"
echo "Detected Architecture: $arch"

# Map arch to package arch
case "$arch" in
  x86_64)
    [[ "$distro" =~ ^(ubuntu|debian|kali)$ ]] && arch="amd64" || arch="x86_64"
    ;;
  aarch64 | arm64)
    [[ "$distro" =~ ^(ubuntu|debian|kali)$ ]] && arch="arm64" || arch="aarch64"
    ;;
  *)
    echo "ERROR: Unsupported architecture: $arch"
    exit 1
    ;;
esac

# Check if vncserver is installed, and install if not
if ! check_installed; then
  base_url="https://github.com/kasmtech/KasmVNC/releases/download/v${KASM_VERSION}"

  echo "Installing KASM version: ${KASM_VERSION}"
  case $distro in
    ubuntu | debian | kali)
      bin_name="kasmvncserver_$${codename}_${KASM_VERSION}_$${arch}.deb"
      install_deb "$base_url/$bin_name"
      ;;
    oracle | fedora | opensuse)
      bin_name="kasmvncserver_$${distro}_$${distro_version}_${KASM_VERSION}_$${arch}.rpm"
      install_rpm "$base_url/$bin_name"
      ;;
    alpine)
      bin_name="kasmvnc.alpine_$${distro_version//./}_$${arch}.tgz"
      install_alpine "$base_url/$bin_name"
      ;;
    *)
      echo "Unsupported distribution: $distro"
      exit 1
      ;;
  esac
else
  echo "vncserver already installed. Skipping installation."
fi

tee "$HOME/.vnc/kasmvnc.yaml" > /dev/null << EOF
network:
  protocol: http
  websocket_port: ${PORT}
  udp:
    public_ip: 127.0.0.1
EOF

# This password is not used since we start the server without auth.
# The server is protected via the Coder session token / tunnel
# and does not listen publicly
echo -e "password\npassword\n" | vncpasswd -wo -u "$USER"

# Start the server
printf "🚀 Starting KasmVNC server...\n"
# shellcheck disable=SC2024
vncserver -select-de "${DESKTOP_ENVIRONMENT}" -disableBasicAuth > /tmp/kasmvncserver.log 2>&1 &

# Wait for server to start
sleep 5
if ! pgrep -f vncserver > /dev/null; then
  echo "ERROR: Failed to start KasmVNC server. Check logs at /tmp/kasmvncserver.log"
  exit 1
fi
