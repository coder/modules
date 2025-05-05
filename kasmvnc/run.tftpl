#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

info()  { printf "💁 INFO: %s\n" "$@"; }
warn()  { printf "😱 WARNING: %s\n" "$@" ;}
error() { printf "💀 ERROR: %s\n" "$@"; exit 1; }
debug() {
  if [ "${DEBUG}" != "Y" ]; then return; fi
  printf "🦺 DEBUG: %s\n" "$@"
}

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
    # shellcheck disable=SC2034
    download_tool=(curl -fsSL)
  elif command -v wget &> /dev/null; then
    # shellcheck disable=SC2034
    download_tool=(wget -q -O-)
  elif command -v busybox &> /dev/null; then
    # shellcheck disable=SC2034
    download_tool=(busybox wget -O-)
  else
    error "No download tool available (curl, wget, or busybox required)"
  fi

  # shellcheck disable=SC2288
  "$${download_tool[@]}" "$url" > "$output" || {
    error "Failed to download $url"
  }
}

# Function to install kasmvncserver for debian-based distros
install_deb() {
  local url=$1
  local kasmdeb="/tmp/kasmvncserver.deb"

  download_file "$url" "$kasmdeb"

  CACHE_DIR="/var/lib/apt/lists/partial"
  # Check if the directory exists and was modified in the last 60 minutes
  if [[ ! -d "$CACHE_DIR" ]] || ! find "$CACHE_DIR" -mmin -60 -print -quit &> /dev/null; then
    echo "Stale package cache, updating..."
    # Update package cache with a 300-second timeout for dpkg lock
    sudo apt-get -o DPkg::Lock::Timeout=300 -qq update
  fi

  DEBIAN_FRONTEND=noninteractive sudo apt-get -o DPkg::Lock::Timeout=300 install --yes -qq --no-install-recommends --no-install-suggests "$kasmdeb"
  rm "$kasmdeb"
}

# Function to install kasmvncserver for rpm-based distros
install_rpm() {
  local url=$1
  local kasmrpm="/tmp/kasmvncserver.rpm"
  local package_manager

  if command -v dnf &> /dev/null; then
    # shellcheck disable=SC2034
    package_manager=(dnf localinstall -y)
  elif command -v zypper &> /dev/null; then
    # shellcheck disable=SC2034
    package_manager=(zypper install -y)
  elif command -v yum &> /dev/null; then
    # shellcheck disable=SC2034
    package_manager=(yum localinstall -y)
  elif command -v rpm &> /dev/null; then
    # Do we need to manually handle missing dependencies?
    # shellcheck disable=SC2034
    package_manager=(rpm -i)
  else
    error "No supported package manager available (dnf, zypper, yum, or rpm required)"
  fi

  download_file "$url" "$kasmrpm"

  # shellcheck disable=SC2288
  sudo "$${package_manager[@]}" "$kasmrpm" || {
    error "Failed to install $kasmrpm"
  }

  rm "$kasmrpm"
}

# Function to install kasmvncserver for Alpine Linux
install_alpine() {
  local url=$1
  local kasmtgz="/tmp/kasmvncserver.tgz"

  download_file "$url" "$kasmtgz"

  tar -xzf "$kasmtgz" -C /usr/local/bin/
  rm "$kasmtgz"
}

# Detect system information
if [[ ! -f /etc/os-release ]]; then
  error "Cannot detect OS: /etc/os-release not found"

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
elif [[ "$ID" == "fedora" ]]; then
  distro_version="$(grep -oP '\(\K[\w ]+' /etc/fedora-release | tr '[:upper:]' '[:lower:]' | tr -d ' ')"
fi

echo "🕵 Detected Operating System Information"
echo "   🔎 Distribution: $distro"
echo "   🔎      Version: $distro_version"
echo "   🔎     Codename: $codename"
echo "   🔎 Architecture: $arch"

# Map arch to package arch
case "$arch" in
  x86_64)
    if [[ "$distro" =~ ^(ubuntu|debian|kali)$ ]]; then
      arch="amd64"
    fi
    ;;
  aarch64)
    if [[ "$distro" =~ ^(ubuntu|debian|kali)$ ]]; then
      arch="arm64"
    fi
    ;;
  arm64)
    : # This is effectively a noop
    ;;
  *)
    error "Unsupported architecture: $arch"
    ;;
esac

# Check if vncserver is installed, and install if not
if ! check_installed; then
  # Check for NOPASSWD sudo (required)
  if ! command -v sudo &> /dev/null || ! sudo -n true 2> /dev/null; then
    error "sudo NOPASSWD access required!"
  fi

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

if command -v sudo &> /dev/null && sudo -n true 2> /dev/null; then
  kasm_config_file="/etc/kasmvnc/kasmvnc.yaml"
  SUDO=sudo
else
  kasm_config_file="$HOME/.vnc/kasmvnc.yaml"
  SUDO=

  warn "Sudo access not available, using user config dir!"

  if [[ -f "$kasm_config_file" ]]; then
    warn "Custom user KasmVNC config exists, not overwriting!"
    warm "Ensure that you manually configure the appropriate settings."
    kasm_config_file="/dev/stderr"
  else
    warn "This may prevent custom user KasmVNC settings from applying!"
    mkdir -p "$HOME/.vnc"
  fi
fi

echo "Writing KasmVNC config to $kasm_config_file"
$SUDO tee "$kasm_config_file" > /dev/null << EOF
network:
  protocol: http
  websocket_port: ${PORT}
  ssl:
    require_ssl: false
    pem_certificate:
    pem_key:
  udp:
    public_ip: 127.0.0.1
logging:
  log_writer_name: all
  log_dest: logfile
  level: 30
EOF

get_http_dir() {
  # determine the served file path
  # Start with the default
  httpd_directory="/usr/share/kasmvnc/www"

  # Check the system configuration path
  if [[ -e /etc/kasmvnc/kasmvnc.yaml ]]; then
    d=($(grep -E "^\s*httpd_directory:.*$" /etc/kasmvnc/kasmvnc.yaml))
    # If this grep is successful, it will return:
    #     httpd_directory: /usr/share/kasmvnc/www
    if [[ $${#d[@]} -eq 2 && -d "$${d[1]}" ]]; then
      httpd_directory="$${d[1]}"
    fi
  fi

  # Check the home directory for overriding values
  if [[ -e "$HOME/.vnc/kasmvnc.yaml" ]]; then
    d=($(grep -E "^\s*httpd_directory:.*$" /etc/kasmvnc/kasmvnc.yaml))
    if [[ $${#d[@]} -eq 2 && -d "$${d[1]}" ]]; then
      httpd_directory="$${d[1]}"
    fi
  fi
  echo $httpd_directory
}

fix_server_index_file(){
    local fname=$${FUNCNAME[0]}  # gets current function name
    if [[ $# -ne 1 ]]; then
        error "$fname requires exactly 1 parameter:\n\tpath to KasmVNC httpd_directory"
    fi
    local httpdir="$1"
    if [[ ! -d "$httpdir" ]]; then
      error "$fname: $httpdir is not a directory"
    fi
    pushd "$httpdir" > /dev/null

    cat <<EOH > /tmp/path_vnc.html
${file(path.module)}
EOH
    $SUDO mv /tmp/path_vnc.html .
    # check for the switcheroo
    if [[ -f "index.html" && -L "vnc.html" ]]; then
      $SUDO mv $httpdir/index.html $httpdir/vnc.html
    fi
    $SUDO ln -s -f path_vnc.html index.html
    popd > /dev/null
}

patch_kasm_http_files(){
  homedir=$(get_http_dir)
  fix_server_index_file "$homedir"
}

if [[ "${SUBDOMAIN}" == "false" ]]; then
  info "🩹 Patching up webserver files to support path-sharing..."
  patch_kasm_http_files
fi


# This password is not used since we start the server without auth.
# The server is protected via the Coder session token / tunnel
# and does not listen publicly
echo -e "password\npassword\n" | vncpasswd -wo -u "$USER"

# Start the server
printf "🚀 Starting KasmVNC server...\n"
vncserver -select-de "${DESKTOP_ENVIRONMENT}" -disableBasicAuth > /tmp/kasmvncserver.log &

# Kasm writes the pid and the log into ~/.vnc. We can check them for liveness
is_started() {
  debug "ls for pidfile: $(ls -alh ~/.vnc/$(hostname):1.pid 2>&1)"

  pidfile="$${HOME}/.vnc/$(hostname):1.pid"
  if [[ ! -f $pidfile ]]; then
    debug "is_started(): no pidfile found"
    return 1
  fi
  pid=$(cat $${pidfile})
  debug "$(ps $pid)"
  if kill -0 $pid; then
    debug "is_started(): found a live PID, setting active"
    declare -gx active="Y"
    return 0
  else
    debug "is_started(): PID is not active"
    return 1
  fi
  warning "is_started(): REACHED THE END WITHOUT HITTING A CASE"
  return 1
}

# Use a sleep based polling timer to see when Kasm comes up.
waited=0
is_started && debug "is Started: true" || debug "is_started: false"
[[ waited -le 30 ]] && debug "waited -le 30: true" || debug "waited -le 30: false"
while [[ waited -le 30 ]] && ! is_started; do
  sleep 1
  waited=$((waited+1))
  if [[ waited -ne 0 && $((waited % 5)) -eq 0 ]]; then
    echo "⏳ Waiting for KasmVNC to start ($waited seconds...)"
  fi
is_started && debug  "is Started: true" || debug "is_started: false"
[[ waited -le 30 ]] && debug "waited -le 30: true" || debug "waited -le 30: false"
done

if [[ "$active" == "" ]]; then
  error "timed out waiting for KasmVNC to start."
fi

printf "🚀 KasmVNC server started successfully in $waited seconds!\n"